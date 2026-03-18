import 'package:flutter/material.dart';

class RiskCard extends StatelessWidget {
  final String riskLevel;
  final int score;

  const RiskCard({super.key, required this.riskLevel, required this.score});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("ระดับความเสี่ยง\n$riskLevel",
                style: const TextStyle(fontSize: 18)),
            Text("Score\n$score",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
