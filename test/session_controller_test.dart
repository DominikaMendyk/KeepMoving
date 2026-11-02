import 'package:flutter_test/flutter_test.dart';
import 'package:keep_moving/models/reminder.dart';
import 'package:keep_moving/models/session_config.dart';
import 'package:keep_moving/state/session_controller.dart';

void main() {
  const config = SessionConfig(
    minutes: 45,
    length: Duration(minutes: 45),
    waterEvery: Duration(minutes: 20),
    stretchEvery: Duration(minutes: 30),
  );

  late DateTime clock;
  late SessionController session;
  late List<Reminder> notified;

  void advance(Duration d) {
    clock = clock.add(d);
    session.tick();
  }

  setUp(() {
    clock = DateTime(2026, 1, 1, 9);
    notified = [];
    session = SessionController(now: () => clock, onReminder: notified.add);
    session.start(config);
  });

  tearDown(() => session.dispose());

  test('water reminder appears after the interval, not before', () {
    advance(const Duration(minutes: 19));
    expect(session.pending, isNull);

    advance(const Duration(minutes: 1));
    expect(session.pending?.type, ReminderType.water);
    expect(notified.length, 1);
  });

  test('simultaneous reminders are queued, one at a time', () {
    advance(const Duration(minutes: 20)); // water
    advance(const Duration(minutes: 10)); // stretch while water is pending

    expect(session.pending?.type, ReminderType.water);
    session.resolveReminder();
    expect(session.pending?.type, ReminderType.stretch);
    expect(session.pending?.stretch, isNotNull);
    session.resolveReminder();
    expect(session.pending, isNull);
  });

  test('an unanswered reminder is not duplicated', () {
    advance(const Duration(minutes: 20)); // water
    advance(const Duration(minutes: 20)); // water again at 40, plus stretch at 30

    session.resolveReminder(); // water answered
    expect(session.pending?.type, ReminderType.stretch);
    session.resolveReminder();
    expect(session.pending, isNull);
  });

  test('paused time does not count', () {
    advance(const Duration(minutes: 10));
    session.pause();
    clock = clock.add(const Duration(minutes: 60));
    session.resume();

    expect(session.elapsed, const Duration(minutes: 10));
  });

  test('session finishes at its planned length', () {
    advance(const Duration(minutes: 46));
    expect(session.status, SessionStatus.finished);
    expect(session.pending, isNull);
    expect(session.remaining, Duration.zero);
  });
}
