import 'package:flutter/material.dart';
import '../services/risk_calculator.dart';

class RiskInfoCard extends StatefulWidget {
  final RiskResult result;

  const RiskInfoCard({super.key, required this.result});

  @override
  State<RiskInfoCard> createState() => _RiskInfoCardState();
}

class _RiskInfoCardState extends State<RiskInfoCard> {
  bool expanded = false;

  Color get color {
    switch (widget.result.level) {
      case "Low":
        return Colors.green;
      case "Medium":
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.monitor_heart, color: color),
            title: Text(
              "Risk Level: ${widget.result.level}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            subtitle: Text("Score: ${widget.result.score}"),
            trailing: IconButton(
              icon: Icon(
                expanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
              onPressed: () {
                setState(() => expanded = !expanded);
              },
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "ความหมายของระดับความเสี่ยง",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text("• Low: สุขภาพอยู่ในเกณฑ์ดี"),
                  Text("• Medium: เริ่มมีปัจจัยเสี่ยง"),
                  Text("• High: ควรปรึกษาแพทย์"),
                  SizedBox(height: 12),
                  Text(
                    "เกณฑ์ที่ใช้ประเมิน",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text("• Steps < 3,000"),
                  Text("• HR > 100 bpm"),
                  Text("• SpO₂ < 95%"),
                  Text("• BP ≥ 140/90"),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
