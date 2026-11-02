/// What the user has achieved so far.
///
/// We store *counts* (glasses, stretches) and derive the visual levels from
/// them. That avoids floating point drift and makes the goals easy to tune.
class UserStats {
  const UserStats({this.glassesToday = 0, this.totalStretches = 0});

  /// Glasses that fill the bottle completely.
  static const int dailyWaterGoal = 8;

  /// Stretches needed per muscle tier.
  static const int stretchesPerTier = 3;
  static const int maxTier = 10;

  /// Resets every day.
  final int glassesToday;

  /// Never resets: every stretch ever confirmed.
  final int totalStretches;

  /// 0.0 (empty) to 1.0 (full).
  double get waterLevel =>
      (glassesToday / dailyWaterGoal).clamp(0.0, 1.0).toDouble();

  /// Tier 1 to [maxTier], shown as a label.
  int get muscleLevel =>
      (1 + totalStretches ~/ stretchesPerTier).clamp(1, maxTier).toInt();

  /// 0.0 to 1.0, grows a little with every stretch (drives the drawing).
  double get muscleProgress =>
      (totalStretches / (stretchesPerTier * (maxTier - 1)))
          .clamp(0.0, 1.0)
          .toDouble();

  UserStats copyWith({int? glassesToday, int? totalStretches}) {
    return UserStats(
      glassesToday: glassesToday ?? this.glassesToday,
      totalStretches: totalStretches ?? this.totalStretches,
    );
  }
}
