class UserProfile {
  double height;
  double weight;
  double spo2;
  int systolic;
  int diastolic;
  bool smoking;
  bool alcohol;

  UserProfile({
    this.height = 0,
    this.weight = 0,
    this.spo2 = 0,
    this.systolic = 0,
    this.diastolic = 0,
    this.smoking = false,
    this.alcohol = false,
  });

  double get bmi => height > 0 ? weight / ((height / 100) * (height / 100)) : 0;

  Map<String, dynamic> toJson() => {
        'height': height,
        'weight': weight,
        'spo2': spo2,
        'systolic': systolic,
        'diastolic': diastolic,
        'smoking': smoking,
        'alcohol': alcohol,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        height: (json['height'] ?? 0).toDouble(),
        weight: (json['weight'] ?? 0).toDouble(),
        spo2: (json['spo2'] ?? 0).toDouble(),
        systolic: json['systolic'] ?? 0,
        diastolic: json['diastolic'] ?? 0,
        smoking: json['smoking'] ?? false,
        alcohol: json['alcohol'] ?? false,
      );
}