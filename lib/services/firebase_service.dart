import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/risk_engine.dart';

class FirebaseService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get uid => _auth.currentUser?.uid;

  // ---------------- SAVE ROLE ----------------
  static Future<void> saveUserRole(String role) async {
    await _firestore.collection('users').doc(uid).set({
      'email': _auth.currentUser?.email,
      'role': role,
    }, SetOptions(merge: true));
  }

  // ---------------- CHECK ABNORMAL ----------------
  static Map<String, dynamic> _checkAbnormal({
    required double heartRate,
    int? spo2,
    int? systolic,
    int? diastolic,
    required num riskScore,
  }) {
    // Heart rate สูง90ต่ำ60
    if (heartRate > 100 || heartRate < 50) {
      return {
        'alert': true,
        'alertType': 'heartRate',
      };
    }

    // SpO2
    if (spo2 != null && spo2 < 92) {
      return {
        'alert': true,
        'alertType': 'spo2',
      };
    }

    // Blood pressure
    if (systolic != null && diastolic != null) {
      if (systolic > 180 || diastolic > 110) {
        return {
          'alert': true,
          'alertType': 'bloodPressure',
        };
      }
    }

    // Risk score
    if (riskScore > 30) {
      return {
        'alert': true,
        'alertType': 'risk',
      };
    }

    return {
      'alert': false,
      'alertType': 'normal',
    };
  }

  // ---------------- PUSH HEALTH DATA (Patient) ----------------
  static Future<void> pushHealthData({
    required int steps,
    required double heartRate,
    int? spo2,
    int? systolic,
    int? diastolic,
    required RiskResult risk,
    required String email,
  }) async {

    final abnormal = _checkAbnormal(
      heartRate: heartRate,
      spo2: spo2,
      systolic: systolic,
      diastolic: diastolic,
      riskScore: risk.score,
    );

    // await _firestore.collection('health_data').doc(email).set({
    //   'steps': steps,
    //   'heartRate': heartRate,
    //   'spo2': spo2,
    //   'systolic': systolic,
    //   'diastolic': diastolic,
    //   'riskLevel': risk.level,
    //   'riskScore': risk.score,
    //   'alert': abnormal['alert'],
    //   'alertType': abnormal['alertType'],
    //   'alertTime': abnormal['alert']
    //       ? FieldValue.serverTimestamp()
    //       : null,
    //   'updatedAt': FieldValue.serverTimestamp(),
    // }, SetOptions(merge: true));

    final Map<String, dynamic> data = {
      'steps': steps,
      'heartRate': heartRate,
      'spo2': spo2,
      'systolic': systolic,
      'diastolic': diastolic,
      'riskLevel': risk.level,
      'riskScore': risk.score,
      'riskReasons': risk.reasons,
      'alert': abnormal['alert'],
      'alertType': abnormal['alertType'],
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (abnormal['alert']) {
      data['alertTime'] = FieldValue.serverTimestamp();
    }

    await _firestore
        .collection('health_data')
        .doc(email)
        .set(data, SetOptions(merge: true));
  }

  // ---------------- READ PATIENT DATA (Caregiver) ----------------
  static Stream<DocumentSnapshot> listenPatient(String email) {
    return _firestore.collection('health_data').doc(email).snapshots();
  }

  // ---------------- sendTestAlert ----------------
  static Future<void> sendTestAlert({
    required String email,
  }) async {
    await _firestore.collection('health_data').doc(email).set({
      'alert': true,
      'alertType': 'test',
      'alertTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ---------------- SAVE FCM TOKEN (Caregiver) ----------------
  static Future<void> saveFcmToken({
    required String email,
    required String token,
  }) async {
    await _firestore.collection('users').doc(email).set({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}