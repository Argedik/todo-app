import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }
    }

    _messaging.onTokenRefresh.listen(_saveTokenToFirestore);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  Future<void> _saveTokenToFirestore(String token) async {
    // TODO: Token'ı users/{uid}/profile/fcmToken'a kaydet
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // TODO: Foreground'da bildirim göster
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // TODO: Bildirimin ilgili sayfasına yönlendir
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Arka plan mesajı işleme
}
