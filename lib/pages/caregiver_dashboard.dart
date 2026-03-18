import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/caregiver_store.dart';
import '../services/firebase_service.dart';
import '../services/alert_listener.dart';

class CaregiverDashboard extends StatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard>
    with SingleTickerProviderStateMixin {
  String? patientEmail;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    init();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(begin: 1.0, end: 1.08).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> init() async {
    await CaregiverStore.load();

    if (CaregiverStore.patientUid == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/select-patient');
      return;
    }

    setState(() {
      patientEmail = CaregiverStore.patientUid;
    });

    GlobalAlertListener.start(patientEmail!);
  }

  // =========================
  // 🔴 Risk Color
  // =========================

  Color getRiskColor(String level) {
    switch (level) {
      case 'High Risk':
        return Colors.red.shade100;
      case 'Medium Risk':
        return Colors.orange.shade100;
      default:
        return Colors.green.shade100;
    }
  }

  Color getRiskTextColor(String level) {
    switch (level) {
      case 'High Risk':
        return Colors.red;
      case 'Medium Risk':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String getRiskDescription(String level) {
    switch (level) {
      case 'High Risk':
        return 'ผู้ป่วยมีความเสี่ยงสูง ควรตรวจสอบทันที';
      case 'Medium Risk':
        return 'ผู้ป่วยเริ่มมีค่าผิดปกติ ควรเฝ้าระวัง';
      default:
        return 'ค่าปกติ ยังไม่มีความเสี่ยง';
    }
  }

  // =========================
  // 🎯 Risk Card (มี animation ตอน High)
  // =========================

  Widget riskCard(Map<String, dynamic> data) {
    final level = data['riskLevel'] ?? 'Low';
    final score = data['riskScore'] ?? 0;

    Widget card = Card(
      color: getRiskColor(level),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: getRiskTextColor(level)),
                const SizedBox(width: 8),
                Text(
                  '$level',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: getRiskTextColor(level),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'คะแนนความเสี่ยง: $score',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              getRiskDescription(level),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );

    if (level == 'High') {
      _controller.repeat(reverse: true);

      return ScaleTransition(
        scale: _animation,
        child: card,
      );
    } else {
      _controller.stop();
      _controller.reset();
      return card;
    }
  }

  Widget card(String title, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title ),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (patientEmail == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ดูแลผู้ป่วย'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'เปลี่ยนผู้ป่วย',
            onPressed: () async {
              await CaregiverStore.clear();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/select-patient');
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseService.listenPatient(patientEmail!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(child: Text('ยังไม่มีข้อมูลสุขภาพ'));
          }

          // แสดงเวลาอัปเดตล่าสุด
          final timestamp = data['updatedAt'] as Timestamp?;
          final updatedTime = timestamp?.toDate();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 🔥 Risk Card (มี animation)
              riskCard(data),
                Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text(
                      'เกณฑ์ Risk Score',
                      // style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'Risk Score ใช้ประเมินความเสี่ยงโรคหัวใจจากข้อมูลสุขภาพของผู้ป่วย\n\n'

                          'เกณฑ์คะแนน\n'
                          '0 - 14 คะแนน : Low Risk (ความเสี่ยงต่ำ)\n'
                          '15 - 29 คะแนน : Medium Risk (ความเสี่ยงปานกลาง)\n'
                          '30 - 50 คะแนน : High Risk (ความเสี่ยงสูง)\n\n'

                          'คะแนนนี้คำนวณจากข้อมูล เช่น\n'
                          '• อายุ\n'
                          '• BMI\n'
                          '• การสูบบุหรี่\n'
                          '• การดื่มแอลกอฮอล์\n'
                          '• Heart Rate\n'
                          '• Steps\n'
                          '• SpO₂\n'
                          '• ความดันโลหิต\n\n'

                          'อ้างอิงแนวคิดจาก\n'
                          'Thai Cardiovascular Risk Score\n'
                          'กรมอนามัย กระทรวงสาธารณสุข\n'
                          'ใช้สำหรับการเฝ้าระวังสุขภาพเบื้องต้น ไม่ใช่การวินิจฉัยทางการแพทย์',
                        ),
                      )
                    ],
                  ),
                ),


              if (updatedTime != null)
                

              card(
                'Heart Rate',
                '${data['heartRate'] ?? '-'} bpm',
                Icons.favorite,
              ),
              card(
                'Steps วันนี้',
                '${data['steps'] ?? '-'}',
                Icons.directions_walk,
              ),
              card(
                'SpO₂',
                '${data['spo2'] ?? '-'} %',
                Icons.air,
              ),
              card(
                'ความดัน',
                data['systolic'] != null
                    ? '${data['systolic']}/${data['diastolic']}'
                    : '-',
                Icons.monitor_heart,
              ),
              card(
                'อัปเดตล่าสุด',
                updatedTime.toString(),
                Icons.access_time,
              ),

              
            ],
          );
        },
      ),
    );
  }
}