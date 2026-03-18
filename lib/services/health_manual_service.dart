import 'package:shared_preferences/shared_preferences.dart';

class HealthManualService {
  static const _spo2Key = 'spo2';
  static const _bpSysKey = 'bp_sys';
  static const _bpDiaKey = 'bp_dia';

  static Future<void> saveSpO2(int value) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setInt(_spo2Key, value);
  }

  static Future<void> saveBP(int sys, int dia) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setInt(_bpSysKey, sys);
    await pref.setInt(_bpDiaKey, dia);
  }

  static Future<int?> getSpO2() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getInt(_spo2Key);
  }

  static Future<Map<String, int>?> getBP() async {
    final pref = await SharedPreferences.getInstance();
    final sys = pref.getInt(_bpSysKey);
    final dia = pref.getInt(_bpDiaKey);

    if (sys == null || dia == null) return null;
    return {'sys': sys, 'dia': dia};
  }
}
