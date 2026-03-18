// import 'package:shared_preferences/shared_preferences.dart';
// import 'auth_store.dart';

// class HealthProfileStore {
//   static DateTime? dateOfBirth;
//   static int? age;
//   static double? heightCm;
//   static double? weightKg;
//   static double? bmi;
//   static String gender = 'male';
//   static bool smoking = false;
//   static bool alcohol = false;

//   static String get _keyPrefix =>
//       AuthStore.email ?? 'guest';

//   static Future<void> save() async {
//     final prefs = await SharedPreferences.getInstance();

//     if (dateOfBirth != null) {
//       await prefs.setString(
//           '${_keyPrefix}_dob', dateOfBirth!.toIso8601String());
//     }

//     await prefs.setDouble('${_keyPrefix}_height', heightCm ?? 0);
//     await prefs.setDouble('${_keyPrefix}_weight', weightKg ?? 0);
//     await prefs.setString('${_keyPrefix}_gender', gender);
//     await prefs.setBool('${_keyPrefix}_smoking', smoking);
//     await prefs.setBool('${_keyPrefix}_alcohol', alcohol);

//     calculateAge();
//     calculateBMI();
//   }

//   static Future<void> load() async {
//     final prefs = await SharedPreferences.getInstance();

//     final dobStr = prefs.getString('${_keyPrefix}_dob');
//     if (dobStr != null) {
//       dateOfBirth = DateTime.parse(dobStr);
//       calculateAge();
//     }

//     heightCm = prefs.getDouble('${_keyPrefix}_height');
//     weightKg = prefs.getDouble('${_keyPrefix}_weight');
//     gender = prefs.getString('${_keyPrefix}_gender') ?? 'male';
//     smoking = prefs.getBool('${_keyPrefix}_smoking') ?? false;
//     alcohol = prefs.getBool('${_keyPrefix}_alcohol') ?? false;

//     calculateBMI();
//   }

//   static void calculateAge() {
//     if (dateOfBirth == null) return;

//     final now = DateTime.now();
//     age = now.year - dateOfBirth!.year;
//     if (now.month < dateOfBirth!.month ||
//         (now.month == dateOfBirth!.month &&
//             now.day < dateOfBirth!.day)) {
//       age = age! - 1;
//     }
//   }

//   static void calculateBMI() {
//     if (heightCm == null || weightKg == null) return;
//     final h = heightCm! / 100;
//     bmi = weightKg! / (h * h);
//   }

//   static void clear() {
//     dateOfBirth = null;
//     age = null;
//     heightCm = null;
//     weightKg = null;
//     bmi = null;
//     gender = 'male';
//     smoking = false;
//     alcohol = false;
//   }
// }








import 'package:shared_preferences/shared_preferences.dart';
import 'auth_store.dart';

class HealthProfileStore {
  static DateTime? dateOfBirth;
  static double? heightCm;
  static double? weightKg;
  static double? bmi;
  static String gender = 'male';
  static bool smoking = false;
  static bool alcohol = false;

  /// key ผูกกับ email
  static String _k(String key) =>
      '${AuthStore.email ?? 'guest'}_$key';

  /// 👉 อายุคำนวณสดทุกครั้ง (ไม่มีวัน null ถ้ามี dob)
  static int? get age {
    if (dateOfBirth == null) return null;

    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;

    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month &&
            now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }
  static void calculateAge() {
    if (dateOfBirth == null) {
      dateOfBirth = null;
      return;
    }

    final now = DateTime.now();
    int age = now.year -
        dateOfBirth!.year -
        ((now.month < dateOfBirth!.month ||
                (now.month == dateOfBirth!.month &&
                    now.day < dateOfBirth!.day))
            ? 1
            : 0);
  }

  // ---------- LOAD ----------
  static Future<void> loadFor(String email) async {
    final prefs = await SharedPreferences.getInstance();

    String k(String key) => '${email}_$key';

    final dob = prefs.getInt(k('dob'));
    if (dob != null) {
      dateOfBirth = DateTime.fromMillisecondsSinceEpoch(dob);
      calculateAge();
    } else {
      dateOfBirth = null;
    }

    heightCm = prefs.getDouble(k('height'));
    weightKg = prefs.getDouble(k('weight'));
    gender = prefs.getString(k('gender')) ?? 'male';
    smoking = prefs.getBool(k('smoking')) ?? false;
    alcohol = prefs.getBool(k('alcohol')) ?? false;

    calculateBMI();
  }
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final dob = prefs.getInt(_k('dob'));
    if (dob != null) {
      dateOfBirth = DateTime.fromMillisecondsSinceEpoch(dob);
    }

    heightCm = prefs.getDouble(_k('height'));
    weightKg = prefs.getDouble(_k('weight'));
    gender = prefs.getString(_k('gender')) ?? 'male';
    smoking = prefs.getBool(_k('smoking')) ?? false;
    alcohol = prefs.getBool(_k('alcohol')) ?? false;

    calculateBMI();
  }

  // ---------- SAVE ----------
  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    if (dateOfBirth != null) {
      await prefs.setInt(
        _k('dob'),
        dateOfBirth!.millisecondsSinceEpoch,
      );
    }

    if (heightCm != null) {
      await prefs.setDouble(_k('height'), heightCm!);
    }

    if (weightKg != null) {
      await prefs.setDouble(_k('weight'), weightKg!);
    }

    await prefs.setString(_k('gender'), gender);
    await prefs.setBool(_k('smoking'), smoking);
    await prefs.setBool(_k('alcohol'), alcohol);
  }

  // ---------- BMI ----------
  static void calculateBMI() {
    if (heightCm != null && weightKg != null && heightCm! > 0) {
      bmi = weightKg! /
          ((heightCm! / 100) * (heightCm! / 100));
    } else {
      bmi = null;
    }
  }
}
