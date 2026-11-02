import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/reminder.dart';
import '../models/session_config.dart';
import '../services/stretch_suggester.dart';

enum SessionStatus { idle, running, paused, finished }

typedef ReminderCallback = void Function(Reminder reminder);

/// Runs a focus session and decides when to remind the user.
///
/// Elapsed time is measured with the wall clock, not by counting timer ticks,
/// so it stays correct when the PC sleeps or the UI thread lags. [now] can be
/// replaced in tests.
class SessionController extends ChangeNotifier {
  SessionController({DateTime Function()? now, this.onReminder})
      : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  /// Called every time a new reminder is created (used for system toasts).
  final ReminderCallback? onReminder;

  SessionConfig? _config;
  Timer? _ticker;
  SessionStatus _status = SessionStatus.idle;

  DateTime? _runningSince;
  Duration _banked = Duration.zero;
  Duration _lastChecked = Duration.zero;

  Reminder? _pending;
  final Queue<Reminder> _queue = Queue();
  StretchSuggester _suggester = StretchSuggester();

  SessionStatus get status => _status;
  SessionConfig? get config => _config;

  /// The reminder currently waiting for the user (null if none).
  Reminder? get pending => _pending;

  Duration get elapsed {
    final since = _runningSince;
    final live = since == null ? Duration.zero : _now().difference(since);
    final total = _banked + live;
    final length = _config?.length;
    return (length != null && total > length) ? length : total;
  }

  Duration get remaining {
    final c = _config;
    if (c == null) return Duration.zero;
    final left = c.length - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  double get progress {
    final c = _config;
    if (c == null || c.length.inSeconds == 0) return 0;
    return (elapsed.inSeconds / c.length.inSeconds).clamp(0.0, 1.0).toDouble();
  }

  void start(SessionConfig config) {
    _ticker?.cancel();
    _config = config;
    _banked = Duration.zero;
    _lastChecked = Duration.zero;
    _runningSince = _now();
    _pending = null;
    _queue.clear();
    _suggester = StretchSuggester();
    _status = SessionStatus.running;
    _startTicker();
    notifyListeners();
  }

  void pause() {
    if (_status != SessionStatus.running) return;
    _banked = elapsed;
    _runningSince = null;
    _ticker?.cancel();
    _status = SessionStatus.paused;
    notifyListeners();
  }

  void resume() {
    if (_status != SessionStatus.paused) return;
    _runningSince = _now();
    _status = SessionStatus.running;
    _startTicker();
    notifyListeners();
  }

  void stop() {
    _ticker?.cancel();
    _runningSince = null;
    _banked = Duration.zero;
    _lastChecked = Duration.zero;
    _pending = null;
    _queue.clear();
    _status = SessionStatus.idle;
    notifyListeners();
  }

  /// Call after the user confirms OR skips the current reminder.
  void resolveReminder() {
    _pending = _queue.isEmpty ? null : _queue.removeFirst();
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  /// Checks the clock. Called by the timer; public so tests can drive it.
  @visibleForTesting
  void tick() {
    final c = _config;
    if (c == null || _status != SessionStatus.running) return;

    final now = elapsed;

    if (now >= c.length) {
      _ticker?.cancel();
      _banked = c.length;
      _runningSince = null;
      _pending = null;
      _queue.clear();
      _status = SessionStatus.finished;
      notifyListeners();
      return;
    }

    if (_crossed(c.waterEvery, _lastChecked, now)) {
      _enqueue(const Reminder.water());
    }
    if (_crossed(c.stretchEvery, _lastChecked, now)) {
      _enqueue(Reminder.stretch(_suggester.next(sessionMinutes: c.minutes)));
    }

    _lastChecked = now;
    notifyListeners();
  }

  /// True if a multiple of [every] lies in (previous, current].
  /// Works even if several seconds passed between two ticks.
  bool _crossed(Duration every, Duration previous, Duration current) {
    final secs = every.inSeconds;
    return secs > 0 && current.inSeconds ~/ secs > previous.inSeconds ~/ secs;
  }

  void _enqueue(Reminder r) {
    final alreadyWaiting =
        _pending?.type == r.type || _queue.any((q) => q.type == r.type);
    if (alreadyWaiting) return;

    if (_pending == null) {
      _pending = r;
    } else {
      _queue.add(r);
    }
    onReminder?.call(r);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
