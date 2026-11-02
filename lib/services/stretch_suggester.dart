import 'dart:math';

import '../data/stretch_library.dart';
import '../models/stretch.dart';

/// Picks a stretch that fits the planned session length.
///
/// Within one session it never repeats a stretch until every eligible one
/// has been used, and it prefers a different body area than the last pick.
class StretchSuggester {
  StretchSuggester({Random? random, List<Stretch>? library})
      : _random = random ?? Random(),
        _library = library ?? stretchLibrary;

  final Random _random;
  final List<Stretch> _library;
  final Set<String> _used = {};
  BodyArea? _lastArea;

  Stretch next({required int sessionMinutes}) {
    final eligible =
        _library.where((s) => s.minSessionMinutes <= sessionMinutes).toList();

    var fresh = eligible.where((s) => !_used.contains(s.name)).toList();
    if (fresh.isEmpty) {
      _used.clear();
      fresh = eligible;
    }

    final varied = fresh.where((s) => s.area != _lastArea).toList();
    final pool = varied.isNotEmpty ? varied : fresh;

    final pick = pool[_random.nextInt(pool.length)];
    _used.add(pick.name);
    _lastArea = pick.area;
    return pick;
  }
}
