import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:keep_moving/data/stretch_library.dart';
import 'package:keep_moving/services/stretch_suggester.dart';

void main() {
  test('short sessions only get quick stretches', () {
    final s = StretchSuggester(random: Random(1));
    for (var i = 0; i < 50; i++) {
      expect(s.next(sessionMinutes: 25).minSessionMinutes, 0);
    }
  });

  test('no repeats until every eligible stretch was used', () {
    final s = StretchSuggester(random: Random(2));
    final pool = stretchLibrary.where((x) => x.minSessionMinutes <= 25).length;
    final names = {for (var i = 0; i < pool; i++) s.next(sessionMinutes: 25).name};
    expect(names.length, pool);
  });

  test('long sessions also get hip, leg and full-body stretches', () {
    final s = StretchSuggester(random: Random(3));
    final pool = stretchLibrary.length;
    final picks = [for (var i = 0; i < pool; i++) s.next(sessionMinutes: 120)];
    expect(picks.any((p) => p.minSessionMinutes >= 60), isTrue);
    expect(picks.map((p) => p.name).toSet().length, pool);
  });
}
