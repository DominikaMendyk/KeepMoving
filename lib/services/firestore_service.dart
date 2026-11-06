import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/day_key.dart';
import '../models/user_stats.dart';

/// Path: users/{uid}
/// Fields: glassesToday (int), totalStretches (int), lastUpdatedDay (String)
class FirestoreService {
  FirestoreService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid);

  /// Returns null if the user has no document yet.
  /// If the stored day is not today, glassesToday comes back as 0
  /// (the bottle empties overnight).
  Future<UserStats?> loadStats(String uid, {String? today}) async {
    final data = (await _doc(uid).get()).data();
    if (data == null) return null;

    final isToday =
        data['lastUpdatedDay'] == (today ?? dayKey(DateTime.now()));
    return UserStats(
      glassesToday: isToday ? (data['glassesToday'] as num?)?.toInt() ?? 0 : 0,
      totalStretches: (data['totalStretches'] as num?)?.toInt() ?? 0,
    );
  }

  Future<void> saveStats(String uid, UserStats stats, {String? day}) {
    return _doc(uid).set({
      'glassesToday': stats.glassesToday,
      'totalStretches': stats.totalStretches,
      'lastUpdatedDay': day ?? dayKey(DateTime.now()),
    }, SetOptions(merge: true));
  }
}
