import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_store.dart';

class InviteService {
  static Future<String> generateCode() async {
    final prefs = await SharedPreferences.getInstance();

    final code = (Random().nextInt(900000) + 100000).toString();
    final expire =
        DateTime.now().add(const Duration(minutes: 10)).millisecondsSinceEpoch;

    await prefs.setString('${AuthStore.email}_invite_code', code);
    await prefs.setInt('${AuthStore.email}_invite_expire', expire);

    return code;
  }

  static Future<bool> validateCode(
      String patientEmail, String code) async {
    final prefs = await SharedPreferences.getInstance();

    final savedCode =
        prefs.getString('${patientEmail}_invite_code');
    final expire =
        prefs.getInt('${patientEmail}_invite_expire');

    if (savedCode == null || expire == null) return false;
    if (DateTime.now().millisecondsSinceEpoch > expire) return false;

    return savedCode == code;
  }
}
