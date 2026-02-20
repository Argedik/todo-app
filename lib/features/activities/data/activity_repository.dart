import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/activity_model.dart';

class ActivityRepository {
  final FirebaseFirestore _firestore;

  ActivityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _ref(String uid) =>
      _firestore.collection(FirestorePaths.activities(uid));

  Stream<List<ActivityModel>> watchActivities(String uid) {
    return _ref(uid)
        .orderBy('activityAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ActivityModel.fromFirestore(d)).toList());
  }

  Future<ActivityModel> addActivity(String uid, ActivityModel activity) async {
    final doc = _ref(uid).doc();
    final newActivity = activity.copyWith(
      id: doc.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await doc.set(newActivity.toFirestore());
    return newActivity.copyWith(id: doc.id);
  }

  Future<void> updateActivity(String uid, ActivityModel activity) async {
    await _ref(uid).doc(activity.id).update(
          activity.copyWith(updatedAt: DateTime.now()).toFirestore(),
        );
  }

  Future<void> deleteActivity(String uid, String activityId) async {
    await _ref(uid).doc(activityId).delete();
  }

  Future<List<ActivityModel>> getAllActivities(String uid) async {
    final snap = await _ref(uid).get();
    return snap.docs.map((d) => ActivityModel.fromFirestore(d)).toList();
  }
}
