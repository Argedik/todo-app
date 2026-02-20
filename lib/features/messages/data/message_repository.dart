import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/generated_message_model.dart';

class MessageRepository {
  final FirebaseFirestore _firestore;

  MessageRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _ref(String uid) =>
      _firestore.collection(FirestorePaths.generatedMessages(uid));

  Stream<List<GeneratedMessageModel>> watchMessages(String uid) {
    return _ref(uid)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => GeneratedMessageModel.fromFirestore(d))
            .toList());
  }

  Stream<List<GeneratedMessageModel>> watchFavorites(String uid) {
    return _ref(uid)
        .where('isFavorite', isEqualTo: true)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => GeneratedMessageModel.fromFirestore(d))
            .toList());
  }

  Future<GeneratedMessageModel> addMessage(
      String uid, GeneratedMessageModel message) async {
    final doc = _ref(uid).doc();
    final newMsg = message.copyWith(
      id: doc.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await doc.set(newMsg.toFirestore());
    return newMsg.copyWith(id: doc.id);
  }

  Future<void> updateMessage(
      String uid, GeneratedMessageModel message) async {
    await _ref(uid).doc(message.id).update(
          message.copyWith(updatedAt: DateTime.now()).toFirestore(),
        );
  }

  Future<void> toggleFavorite(
      String uid, GeneratedMessageModel message) async {
    await _ref(uid).doc(message.id).update({
      'isFavorite': !message.isFavorite,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> archiveMessage(String uid, String messageId) async {
    await _ref(uid).doc(messageId).update({
      'isArchived': true,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteMessage(String uid, String messageId) async {
    await _ref(uid).doc(messageId).delete();
  }

  Future<List<GeneratedMessageModel>> getAllMessages(String uid) async {
    final snap = await _ref(uid).get();
    return snap.docs
        .map((d) => GeneratedMessageModel.fromFirestore(d))
        .toList();
  }
}
