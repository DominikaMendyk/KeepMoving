import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_stats.dart';

/// Holds the bottle and muscle progress and saves it to disk.
///
/// Water resets every day (the bottle empties overnight).
/// Muscles are permanent: every confirmed stretch counts forever.
class ProgressController extends ChangeNotifier {
  ProgressController(this._prefs, {DateTime Function()? now})
      : _now = now ?? DateTime.now {
    _load();
  }

  static const _kDay = 'water_day';
  static const _kGlasses = 'water_glasses';
  static const _kStretches = 'total_stretches';

  final SharedPreferences _prefs;
  final DateTime Function() _now;
  UserStats _stats = const UserStats();

  UserStats get stats => _stats;

  void drinkWater() {
    _rollOverIfNewDay();
    _stats = _stats.copyWith(glassesToday: _stats.glassesToday + 1);
    _prefs.setInt(_kGlasses, _stats.glassesToday);
    notifyListeners();
  }

  void completeStretch() {
    _stats = _stats.copyWith(totalStretches: _stats.totalStretches + 1);
    _prefs.setInt(_kStretches, _stats.totalStretches);
    notifyListeners();
  }

  /// Call when a session starts so a bottle left over from yesterday is emptied
  /// even if the app stayed open past midnight.
  void refreshDay() {
    if (_rollOverIfNewDay()) notifyListeners();
  }

  void resetProgress() {
    _stats = const UserStats();
    _prefs.setInt(_kGlasses, 0);
    _prefs.setInt(_kStretches, 0);
    _prefs.setString(_kDay, _todayKey());
    notifyListeners();
  }

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

  String _todayKey() {
    final n = _now();
    return '${n.year}-${n.month}-${n.day}';
  }
}
