import 'package:shared_preferences/shared_preferences.dart';
import 'auth_store.dart';

class CaregiverStore {
  // static String? patientEmail;
  static String? patientUid;

  static String _k(String key) =>
      '${AuthStore.email}_$key';

  static Future<void> savePatientEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    patientUid = email;
    await prefs.setString(_k('patient_email'), email);
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    patientUid = prefs.getString(_k('patient_email'));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    patientUid = null;
    await prefs.remove(_k('patient_email'));
  }
}
