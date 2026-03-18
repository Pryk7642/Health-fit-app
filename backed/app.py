from flask import Flask, request, jsonify
from risk_engine import assess_risk

app = Flask(__name__)

@app.route("/api/risk", methods=["POST"])
def risk():
    data = request.json

    risk_level = assess_risk(data)

    return jsonify({
        "risk": risk_level,
        "input": data
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
