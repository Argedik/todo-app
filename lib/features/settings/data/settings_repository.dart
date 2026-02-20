import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/user_settings_model.dart';

class SettingsRepository {
  final FirebaseFirestore _firestore;

  SettingsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  Future<UserSettingsModel> getSettings(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) return const UserSettingsModel();
    final data = doc.data() as Map<String, dynamic>;
    final settingsData = data['settings'] as Map<String, dynamic>? ?? {};
    return UserSettingsModel.fromFirestore(settingsData);
  }

  Future<void> updateSettings(
      String uid, UserSettingsModel settings) async {
    await _userDoc(uid).update({'settings': settings.toFirestore()});
  }

  Stream<UserSettingsModel> watchSettings(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      if (!snap.exists) return const UserSettingsModel();
      final data = snap.data() as Map<String, dynamic>;
      final settingsData = data['settings'] as Map<String, dynamic>? ?? {};
      return UserSettingsModel.fromFirestore(settingsData);
    });
  }
}
