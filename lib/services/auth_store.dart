// import 'package:shared_preferences/shared_preferences.dart';

// class AuthStore {
//   static String? email;
//   static String? role = 'patient'; // patient | caregiver

//   static String _k(String key) =>
//       '${email ?? 'guest'}_$key';

//   static Future<void> loadEmail() async {
//     final prefs = await SharedPreferences.getInstance();
//     email = prefs.getString('current_email');
//   }

//   static Future<void> saveEmail(String email) async {
//     final prefs = await SharedPreferences.getInstance();
//     AuthStore.email = email;
//     await prefs.setString('current_email', email);
//   }

//   static Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     email = null;
//     await prefs.remove('current_email');
//   }
// }



import 'package:shared_preferences/shared_preferences.dart';

class AuthStore {
  static String? email;
  static String? role; // 'patient' | 'caregiver'

  static String _k(String key) =>
      '${email ?? 'guest'}_$key';

  static Future<void> saveEmail(String value) async {
    final prefs = await SharedPreferences.getInstance();
    email = value;
    await prefs.setString('current_email', value);
  }

  static Future<void> loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString('current_email');
    if (email != null) {
      role = prefs.getString(_k('role'));
    }
  }

  static Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    role = prefs.getString('role');
  }

  static Future<void> saveRole(String value) async {
    final prefs = await SharedPreferences.getInstance();
    role = value;
    await prefs.setString(_k('role'), value);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    email = null;
    role = null;
    await prefs.remove('current_email');
  }
}
