import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotifications {
  static final _firebaseMessaging = FirebaseMessaging.instance;

  // request notification permission
  static Future Intt() async {
    await _firebaseMessaging.requestPermission(
        announcement: true,
        alert: true,
        badge: true,
        sound: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false);

    // get  the token for this device
    final token = await _firebaseMessaging.getToken();
    print("Device Token :$token");
  }
}
