// class RiskResult {
//   final int score;
//   final String level;
//   final List<String> reasons;

//   RiskResult({
//     required this.score,
//     required this.level,
//     required this.reasons,
//   });
// }

// class RiskEngine {
//   static RiskResult calculate({
//     required int steps,
//     required double heartRate,
//     int? spo2,
//     int? bpSys,
//     int? bpDia,
//     int? age,
//     double? bmi,
//     required bool smoking,
//     required bool alcohol,
//   }) {
//     int score = 0;
//     final reasons = <String>[];

//     // ---------- Steps ----------
//     if (steps < 3000) {
//       score += 2;
//       reasons.add("กิจกรรมทางกายน้อย (Steps < 3,000)");
//     } else if (steps < 7000) {
//       score += 1;
//     }

//     // ---------- Heart Rate ----------
//     if (heartRate > 100) {
//       score += 2;
//       reasons.add("ชีพจรสูง (>100 bpm)");
//     }

//     // ---------- SpO₂ ----------
//     if (spo2 != null) {
//       if (spo2 < 92) {
//         score += 3;
//         reasons.add("SpO₂ ต่ำ (<92%)");
//       } else if (spo2 < 95) {
//         score += 1;
//       }
//     }

//     // ---------- Blood Pressure ----------
//     if (bpSys != null && bpDia != null) {
//       if (bpSys >= 140 || bpDia >= 90) {
//         score += 2;
//         reasons.add("ความดันโลหิตสูง");
//       }
//     }

//     // ---------- Age ----------
//     if (age != null && age >= 60) {
//       score += 2;
//       reasons.add("อายุ ≥ 60 ปี");
//     }

//     // ---------- BMI ----------
//     if (bmi != null) {
//       if (bmi >= 30) {
//         score += 2;
//         reasons.add("BMI อ้วน");
//       } else if (bmi >= 25) {
//         score += 1;
//       }
//     }

//     // ---------- Lifestyle ----------
//     if (smoking) {
//       score += 2;
//       reasons.add("สูบบุหรี่");
//     }

//     if (alcohol) {
//       score += 1;
//       reasons.add("ดื่มแอลกอฮอล์");
//     }

//     // ---------- Final Level ----------
//     String level;
//     if (score <= 3) {
//       level = "Low Risk";
//     } else if (score <= 7) {
//       level = "Medium Risk";
//     } else {
//       level = "High Risk";
//     }

//     return RiskResult(
//       score: score,
//       level: level,
//       reasons: reasons,
//     );
//   }
// }






class RiskResult {
  final int score;
  final String level;
  final List<String> reasons;

  RiskResult({
    required this.score,
    required this.level,
    required this.reasons,
  });
}

class RiskEngine {
  static RiskResult calculate({
    required int steps,
    required double heartRate,
    int? spo2,
    int? bpSys,
    int? bpDia,
    int? age,
    double? bmi,
    bool smoking = false,
    bool alcohol = false,
  }) {
    int score = 0;
    List<String> reasons = [];

    /// ---------------- Age ----------------
    if (age != null) {
      if (age >= 60) {
        score += 10;
        reasons.add("อายุมากกว่า 60 ปี");
      } else if (age >= 45) {
        score += 5;
        reasons.add("อายุมากกว่า 45 ปี");
      }
    }

    /// ---------------- BMI ----------------
    if (bmi != null) {
      if (bmi >= 30) {
        score += 8;
        reasons.add("BMI ≥ 30 (อ้วน)");
      } else if (bmi >= 25) {
        score += 4;
        reasons.add("BMI ≥ 25 (น้ำหนักเกิน)");
      }
    }

    /// ---------------- Smoking ----------------
    if (smoking) {
      score += 8;
      reasons.add("สูบบุหรี่");
    }

    /// ---------------- Alcohol ----------------
    if (alcohol) {
      score += 3;
      reasons.add("ดื่มแอลกอฮอล์");
    }

    /// ---------------- Heart Rate ----------------
    if (heartRate > 100) {
      score += 8;
      reasons.add("Heart Rate สูง (>100 bpm)");
    } else if (heartRate < 50) {
      score += 6;
      reasons.add("Heart Rate ต่ำผิดปกติ");
    }

    /// ---------------- Steps ----------------
    if (steps < 3000) {
      score += 5;
      reasons.add("กิจกรรมทางกายน้อย (<3000 steps)");
    }

    /// ---------------- SpO2 ----------------
    if (spo2 != null) {
      if (spo2 < 95) {
        score += 5;
        reasons.add("ค่าออกซิเจนในเลือดต่ำ");
      }
    }

    /// ---------------- Blood Pressure ----------------
    if (bpSys != null && bpDia != null) {
      if (bpSys >= 160 || bpDia >= 100) {
        score += 12;
        reasons.add("ความดันโลหิตสูงมาก");
      } else if (bpSys >= 140 || bpDia >= 90) {
        score += 8;
        reasons.add("ความดันโลหิตสูง");
      } else if (bpSys >= 130 || bpDia >= 85) {
        score += 2;
        reasons.add("ความดันเริ่มสูง");
      }
    }

    /// ---------------- Limit Score ----------------
    if (score > 50) {
      score = 50;
    }

    /// ---------------- Risk Level ----------------
    String level;

    if (score >= 30) {
      level = "High Risk";
    } else if (score >= 15) {
      level = "Medium Risk";
    } else {
      level = "Low Risk";
    }

    return RiskResult(
      score: score,
      level: level,
      reasons: reasons,
    );
  }
}