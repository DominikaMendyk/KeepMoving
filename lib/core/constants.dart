/// Seconds that count as one "minute" inside the app.
///
/// While testing, set this to 1: a 45 min session then runs in 45 seconds,
/// water reminders appear after 20 s and stretch reminders after 30 s.
/// Set it back to 60 for real use.
const int kSecondsPerMinute = 1;
