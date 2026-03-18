import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class GlobalAlertListener {
  static StreamSubscription<DocumentSnapshot>? _subscription;

  static void start(String patientEmail) {
    _subscription = FirebaseFirestore.instance
        .collection('health_data')
        .doc(patientEmail)
        .snapshots()
        .listen((doc) async {
      final data = doc.data();

      if (data != null && data['alert'] == true) {
        await NotificationService.showIncomingCallNotification();

        // reset flag
        await FirebaseFirestore.instance
            .collection('health_data')
            .doc(patientEmail)
            .update({'alert': false});
      }
    });
  }

  static void stop() {
    _subscription?.cancel();
  }
}
