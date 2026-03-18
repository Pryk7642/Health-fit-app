import '../models/health_data.dart';

class RiskResult {
  final int score;
  final String level;
  final String description;

  RiskResult({
    required this.score,
    required this.level,
    required this.description,
  });
}

class RiskCalculator {
  static RiskResult calculate(HealthData data) {
    int score = 0;

    // Steps
    if (data.steps < 3000) {
      score += 2;
    } else if (data.steps < 7000) {
      score += 1;
    }

    // Heart Rate
    if (data.heartRate > 100) {
      score += 2;
    } else if (data.heartRate > 90) {
      score += 1;
    }

    // SpO2
    if (data.spo2 < 92) {
      score += 3;
    } else if (data.spo2 < 95) {
      score += 1;
    }

    // Blood Pressure
    if (data.systolic >= 140 || data.diastolic >= 90) {
      score += 2;
    } else if (data.systolic >= 130 || data.diastolic >= 85) {
      score += 1;
    }

    if (score <= 2) {
      return RiskResult(
        score: score,
        level: "Low",
        description: "ความเสี่ยงต่ำ สุขภาพโดยรวมอยู่ในเกณฑ์ดี",
      );
    } else if (score <= 5) {
      return RiskResult(
        score: score,
        level: "Medium",
        description: "ความเสี่ยงปานกลาง ควรเฝ้าระวังและปรับพฤติกรรม",
      );
    } else {
      return RiskResult(
        score: score,
        level: "High",
        description: "ความเสี่ยงสูง ควรพบแพทย์หรือดูแลใกล้ชิด",
      );
    }
  }
}
