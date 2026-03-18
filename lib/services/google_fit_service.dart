import 'package:flutter/services.dart';

class GoogleFitService {
  static const MethodChannel _channel = MethodChannel('google_fit');

  static Future<String?> signIn() async {
    return await _channel.invokeMethod<String>('signIn');
  }

  static Future<void> logout() async {
    await _channel.invokeMethod('logout');
  }

  static Future<int> getTodaySteps() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);

    return await _channel.invokeMethod<int>('getSteps', {
          'start': start.millisecondsSinceEpoch,
          'end': now.millisecondsSinceEpoch,
        }) ??
        0;
  }

  static Future<double> getHeartRate() async {
    return await _channel.invokeMethod<double>('getHeartRate') ?? 0;
  }

  static Future<bool> tryReconnect() async {
    return await _channel.invokeMethod<bool>('tryReconnect') ?? false;
  }
  
}
