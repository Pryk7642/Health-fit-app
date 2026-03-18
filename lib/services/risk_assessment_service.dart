class HeartRiskResult {
  final String level; // ต่ำ / กลาง / สูง
  final int score;
  final List<String> reasons;

  HeartRiskResult({
    required this.level,
    required this.score,
    required this.reasons,
  });
}

class RiskAssessmentService {
  static HeartRiskResult assess({
    required int steps,
    required double heartRate,
    int? spo2,
    int? bpSys,
    int? bpDia,
  }) {
    int score = 0;
    List<String> reasons = [];

    // ❤️ Heart Rate (ล่าสุด)
    if (heartRate > 100) {
      score += 2;
      reasons.add('อัตราการเต้นหัวใจสูง');
    } else if (heartRate < 50) {
      score += 1;
      reasons.add('อัตราการเต้นหัวใจต่ำ');
    }

    // 🫁 SpO2
    if (spo2 != null) {
      if (spo2 < 90) {
        score += 3;
        reasons.add('SpO₂ ต่ำมาก');
      } else if (spo2 < 95) {
        score += 1;
        reasons.add('SpO₂ ต่ำ');
      }
    }

    // 🩸 Blood Pressure
    if (bpSys != null && bpDia != null) {
      if (bpSys >= 140 || bpDia >= 90) {
        score += 3;
        reasons.add('ความดันโลหิตสูง');
      } else if (bpSys >= 130 || bpDia >= 85) {
        score += 1;
        reasons.add('ความดันเริ่มสูง');
      }
    }

    // 👣 Steps
    if (steps < 3000) {
      score += 2;
      reasons.add('การเคลื่อนไหวน้อย');
    } else if (steps < 5000) {
      score += 1;
      reasons.add('การเคลื่อนไหวต่ำ');
    }

    // 🧠 สรุประดับความเสี่ยง
    String level;
    if (score >= 6) {
      level = 'สูง';
    } else if (score >= 3) {
      level = 'กลาง';
    } else {
      level = 'ต่ำ';
    }

    return HeartRiskResult(
      level: level,
      score: score,
      reasons: reasons,
    );
  }
}
