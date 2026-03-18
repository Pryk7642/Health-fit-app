// import 'package:shared_preferences/shared_preferences.dart';
// import 'auth_store.dart';

// class HealthDataStore {
//   static int? spo2;
//   static int? bpSys;
//   static int? bpDia;

//   static String _k(String key) {
//     final email = AuthStore.email ?? 'guest';
//     return '${email}_$key';
//   }

//   /// โหลดข้อมูลของ user ปัจจุบัน
//   static Future<void> load() async {
//     final prefs = await SharedPreferences.getInstance();
//     spo2 = prefs.getInt(_k('spo2'));
//     bpSys = prefs.getInt(_k('bpSys'));
//     bpDia = prefs.getInt(_k('bpDia'));
//   }

//   /// บันทึกข้อมูล + update memory
//   static Future<void> save({
//     int? spo2Value,
//     int? bpSysValue,
//     int? bpDiaValue,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();

//     if (spo2Value != null) {
//       spo2 = spo2Value;
//       await prefs.setInt(_k('spo2'), spo2Value);
//     }

//     if (bpSysValue != null) {
//       bpSys = bpSysValue;
//       await prefs.setInt(_k('bpSys'), bpSysValue);
//     }

//     if (bpDiaValue != null) {
//       bpDia = bpDiaValue;
//       await prefs.setInt(_k('bpDia'), bpDiaValue);
//     }
//   }
// }




import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_store.dart';

class HealthDataStore {
  static int steps = 0;
  static double heartRate = 0;
  static int? spo2 = 0;
  static int? systolic = 0;
  static int? diastolic = 0;
  static String risk = 'Unknown';

  static String get _key {
    final email = AuthStore.email;
    if (email == null) {
      throw Exception('No user logged in');
    }
    return 'health_data_$email';
  }

  // โหลดข้อมูลของ user ปัจจุบัน
  static Future<void> loadFor(String email) async {
    final prefs = await SharedPreferences.getInstance();

    String k(String key) => '${email}_$key';

    spo2 = prefs.getInt(k('spo2'));
    systolic = prefs.getInt(k('systolic'));
    diastolic = prefs.getInt(k('diastolic'));
  }
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null) {
      _setDefault();
      return;
    }

    final data = jsonDecode(raw);
    steps = data['steps'] ?? 0;
    heartRate = (data['heartRate'] ?? 0).toDouble();
    spo2 = data['spo2'] ?? 0;
    systolic = data['systolic'] ?? 0;
    diastolic = data['diastolic'] ?? 0;
    risk = data['risk'] ?? 'Unknown';
  }

  // บันทึกข้อมูลของ user ปัจจุบัน
  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'steps': steps,
      'heartRate': heartRate,
      'spo2': spo2,
      'systolic': systolic,
      'diastolic': diastolic,
      'risk': risk,
    };
    await prefs.setString(_key, jsonEncode(data));
  }

  static void _setDefault() {
    steps = 0;
    heartRate = 0;
    spo2 = 0;
    systolic = 0;
    diastolic = 0;
    risk = 'Unknown';
  }

  // ใช้ตอน logout (ไม่ลบ storage)
  static void clearMemory() {
    _setDefault();
  }
}
