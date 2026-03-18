def assess_risk(data):
    score = 0

    # Steps
    if data["steps"] < 3000:
        score += 2
    elif data["steps"] < 6000:
        score += 1

    # Heart Rate
    if data["heart_rate"] > 100:
        score += 2
    elif data["heart_rate"] > 85:
        score += 1

    # BMI
    if data["bmi"] >= 30:
        score += 2
    elif data["bmi"] >= 25:
        score += 1

    # SpO2
    if data["spo2"] < 95:
        score += 2

    # Sleep
    if data["sleep_hours"] < 6:
        score += 1

    # Lifestyle
    if data["smoking"]:
        score += 2
    if data["alcohol"]:
        score += 1

    if score >= 7:
        return "HIGH"
    elif score >= 4:
        return "MEDIUM"
    else:
        return "LOW"
