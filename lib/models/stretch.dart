enum BodyArea { neck, shoulders, wrists, eyes, back, hips, legs, fullBody }

class Stretch {
  const Stretch({
    required this.name,
    required this.instruction,
    required this.seconds,
    required this.area,
    this.minSessionMinutes = 0,
  });

  final String name;
  final String instruction;

  /// How long to hold or repeat it.
  final int seconds;
  final BodyArea area;

  /// Only suggested when the planned session is at least this long.
  final int minSessionMinutes;
}
