import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/calendar_event_model.dart';

class CalendarEventRepository {
  final FirebaseFirestore _firestore;

  CalendarEventRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _ref(String uid) =>
      _firestore.collection(FirestorePaths.calendarEvents(uid));

  Stream<List<CalendarEventModel>> watchEvents(String uid) {
    return _ref(uid).orderBy('startAt').snapshots().map((snap) =>
        snap.docs.map((d) => CalendarEventModel.fromFirestore(d)).toList());
  }

  Stream<List<CalendarEventModel>> watchEventsForDay(
      String uid, DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return _ref(uid)
        .where('startAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startAt', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CalendarEventModel.fromFirestore(d))
            .toList());
  }

  Future<CalendarEventModel> addEvent(
      String uid, CalendarEventModel event) async {
    final doc = _ref(uid).doc();
    final newEvent = event.copyWith(
      id: doc.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await doc.set(newEvent.toFirestore());
    return newEvent.copyWith(id: doc.id);
  }

  Future<void> updateEvent(String uid, CalendarEventModel event) async {
    await _ref(uid).doc(event.id).update(
          event.copyWith(updatedAt: DateTime.now()).toFirestore(),
        );
  }

  Future<void> deleteEvent(String uid, String eventId) async {
    await _ref(uid).doc(eventId).delete();
  }

  Future<List<CalendarEventModel>> getAllEvents(String uid) async {
    final snap = await _ref(uid).get();
    return snap.docs
        .map((d) => CalendarEventModel.fromFirestore(d))
        .toList();
  }
}
