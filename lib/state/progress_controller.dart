import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/day_key.dart';
import '../models/user_stats.dart';
import '../services/firestore_service.dart';

/// Holds the bottle and muscle progress, saves it to disk, and (when a user is
/// signed in) syncs it to Firestore.
///
/// Water resets every day (the bottle empties overnight).
/// Muscles are permanent: every confirmed stretch counts forever.
///
/// Local storage stays the source the UI reads from, so the app still works
/// offline. Every change is pushed to the cloud in the background.
class ProgressController extends ChangeNotifier {
  ProgressController(this._prefs, this._cloud, {DateTime Function()? now})
      : _now = now ?? DateTime.now {
    _load();
  }

  static const _kDay = 'water_day';
  static const _kGlasses = 'water_glasses';
  static const _kStretches = 'total_stretches';

  final SharedPreferences _prefs;
  final FirestoreService _cloud;
  final DateTime Function() _now;
  UserStats _stats = const UserStats();
  String? _uid;

  UserStats get stats => _stats;

  void drinkWater() {
    _rollOverIfNewDay();
    _stats = _stats.copyWith(glassesToday: _stats.glassesToday + 1);
    _prefs.setInt(_kGlasses, _stats.glassesToday);
    notifyListeners();
    _push();
  }

  void completeStretch() {
    _stats = _stats.copyWith(totalStretches: _stats.totalStretches + 1);
    _prefs.setInt(_kStretches, _stats.totalStretches);
    notifyListeners();
    _push();
  }

  /// Call when a session starts so a bottle left over from yesterday is emptied
  /// even if the app stayed open past midnight.
  void refreshDay() {
    if (_rollOverIfNewDay()) {
      notifyListeners();
      _push();
    }
  }

  void resetProgress() {
    _stats = const UserStats();
    _prefs.setInt(_kGlasses, 0);
    _prefs.setInt(_kStretches, 0);
    _prefs.setString(_kDay, _todayKey());
    notifyListeners();
    _push();
  }

  // ---------------------------------------------------------------- cloud

  /// Call with the user's uid after sign-in (or at app start if a session is
  /// restored), and with null after sign-out.
  ///
  /// Sign-in: downloads the cloud copy and merges it with local progress.
  /// Both counters only ever go up, so taking the larger value never loses
  /// progress made on another device or while offline.
  /// Sign-out: wipes the local copy so the next account starts clean.
  Future<void> bindUser(String? uid) async {
    if (uid == _uid) return;
    final wasSignedIn = _uid != null;
    _uid = uid;

    if (uid == null) {
      if (wasSignedIn) _clearLocal();
      return;
    }

    try {
      _rollOverIfNewDay();
      final remote = await _cloud.loadStats(uid, today: _todayKey());
      if (_uid != uid) return; // user changed while we were loading

      _stats = UserStats(
        glassesToday:
            math.max(_stats.glassesToday, remote?.glassesToday ?? 0),
        totalStretches:
            math.max(_stats.totalStretches, remote?.totalStretches ?? 0),
      );
      _prefs.setInt(_kGlasses, _stats.glassesToday);
      _prefs.setInt(_kStretches, _stats.totalStretches);
      notifyListeners();
      _push();
    } catch (e) {
      // Offline or permission problem: keep local data, retry on next change.
      debugPrint('Initial sync failed: $e');
    }
  }

  void _push() {
    final uid = _uid;
    if (uid == null) return;
    _cloud.saveStats(uid, _stats, day: _todayKey()).catchError((Object e) {
      debugPrint('Cloud save failed: $e');
    });
  }

  void _clearLocal() {
    _stats = const UserStats();
    _prefs.setInt(_kGlasses, 0);
    _prefs.setInt(_kStretches, 0);
    _prefs.setString(_kDay, _todayKey());
    notifyListeners();
  }

  // ---------------------------------------------------------------- local

  void _load() {
    _stats = UserStats(
      glassesToday: _prefs.getInt(_kGlasses) ?? 0,
      totalStretches: _prefs.getInt(_kStretches) ?? 0,
    );
    _rollOverIfNewDay();
  }

  /// Returns true if the day changed and the bottle was emptied.
  bool _rollOverIfNewDay() {
    final today = _todayKey();
    if (_prefs.getString(_kDay) == today) return false;
    _stats = _stats.copyWith(glassesToday: 0);
    _prefs.setString(_kDay, today);
    _prefs.setInt(_kGlasses, 0);
    return true;
  }

  String _todayKey() => dayKey(_now());
}
