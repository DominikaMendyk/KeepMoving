import 'stretch.dart';

enum ReminderType { water, stretch }

class Reminder {
  const Reminder.water()
      : type = ReminderType.water,
        stretch = null;

  const Reminder.stretch(this.stretch) : type = ReminderType.stretch;

  final ReminderType type;
  final Stretch? stretch;
}
