import '../core/constants.dart';

class SessionConfig {
  const SessionConfig({
    required this.minutes,
    required this.length,
    required this.waterEvery,
    required this.stretchEvery,
  });

  /// Sensible defaults for a session of [minutes].
  factory SessionConfig.forMinutes(int minutes) {
    Duration m(int v) => Duration(seconds: v * kSecondsPerMinute);
    return SessionConfig(
      minutes: minutes,
      length: m(minutes),
      waterEvery: m(minutes >= 60 ? 60 : 20),
      stretchEvery: m(minutes <= 30 ? 15 : 30),
    );
  }

  /// Planned session length. Used to pick fitting stretches.
  final int minutes;
  final Duration length;
  final Duration waterEvery;
  final Duration stretchEvery;

  int get waterEveryMinutes => waterEvery.inSeconds ~/ kSecondsPerMinute;
  int get stretchEveryMinutes => stretchEvery.inSeconds ~/ kSecondsPerMinute;
}
