import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/ai_rule_set_model.dart';

class AiRuleSetRepository {
  final FirebaseFirestore _firestore;

  AiRuleSetRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _ref(String uid) =>
      _firestore.collection(FirestorePaths.aiRuleSets(uid));

  Stream<List<AiRuleSetModel>> watchRuleSets(String uid) {
    return _ref(uid).orderBy('updatedAt', descending: true).snapshots().map(
        (snap) =>
            snap.docs.map((d) => AiRuleSetModel.fromFirestore(d)).toList());
  }

  Future<AiRuleSetModel> addRuleSet(String uid, AiRuleSetModel ruleSet) async {
    final doc = _ref(uid).doc();
    final newRuleSet = ruleSet.copyWith(
      id: doc.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await doc.set(newRuleSet.toFirestore());
    return newRuleSet.copyWith(id: doc.id);
  }

  Future<void> updateRuleSet(String uid, AiRuleSetModel ruleSet) async {
    await _ref(uid).doc(ruleSet.id).update(
          ruleSet.copyWith(updatedAt: DateTime.now()).toFirestore(),
        );
  }

  Future<void> deleteRuleSet(String uid, String ruleSetId) async {
    await _ref(uid).doc(ruleSetId).delete();
  }

  Future<AiRuleSetModel?> getRuleSet(String uid, String ruleSetId) async {
    final doc = await _ref(uid).doc(ruleSetId).get();
    if (!doc.exists) return null;
    return AiRuleSetModel.fromFirestore(doc);
  }

  Future<List<AiRuleSetModel>> getAllRuleSets(String uid) async {
    final snap = await _ref(uid).get();
    return snap.docs.map((d) => AiRuleSetModel.fromFirestore(d)).toList();
  }
}
