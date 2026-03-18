import 'package:flutter/material.dart';
import 'package:health_fit_native/services/firebase_service.dart';
import '../services/google_fit_service.dart';
import '../services/health_data_store.dart';
import '../services/health_profile_store.dart';
import 'manual_input_page.dart';
import 'health_profile_form.dart';
import '../services/risk_engine.dart';
import '../services/auth_store.dart';
import 'dart:async';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int steps = 0;
  double heartRate = 0;

  int? spo2;
  int? bpSys;
  int? bpDia;
  int _lastSteps = -1;
  double _lastHeartRate = -1;

  bool loading = true;

  Timer? _refreshTimer;

  late RiskResult risk;

  @override
  void initState() {
    super.initState();

    loadHealthData(); // โหลดครั้งแรก (รวม risk)

    // 🔁 auto refresh ทุก 10 วินาที
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => refreshRealtimeData(),
    );
  }
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadHealthData() async {
    final s = await GoogleFitService.getTodaySteps();
    final hr = await GoogleFitService.getHeartRate();

    setState(() {
      steps = s;
      heartRate = hr;
      spo2 = HealthDataStore.spo2;
      bpSys = HealthDataStore.systolic;
      bpDia = HealthDataStore.diastolic;
      loading = false;

      risk = RiskEngine.calculate(
        steps: steps,
        heartRate: heartRate,
        spo2: spo2,
        bpSys: bpSys,
        bpDia: bpDia,
        age: HealthProfileStore.age,
        bmi: HealthProfileStore.bmi,
        smoking: HealthProfileStore.smoking,
        alcohol: HealthProfileStore.alcohol,
      );

    });

    await FirebaseService.pushHealthData(
      steps: steps,
      heartRate: heartRate,
      spo2: spo2,
      systolic: bpSys,
      diastolic: bpDia,
      risk: risk,
      email: AuthStore.email!,
      );

  }

  Future<void> refreshRealtimeData() async {
    final s = await GoogleFitService.getTodaySteps();
    final hr = await GoogleFitService.getHeartRate();

    // ถ้าค่าไม่เปลี่ยน ไม่ต้อง push
    if (s == _lastSteps && hr == _lastHeartRate) return;

    _lastSteps = s;
    _lastHeartRate = hr;

    final newRisk = RiskEngine.calculate(
      steps: s,
      heartRate: hr,
      spo2: spo2,
      bpSys: bpSys,
      bpDia: bpDia,
      age: HealthProfileStore.age,
      bmi: HealthProfileStore.bmi,
      smoking: HealthProfileStore.smoking,
      alcohol: HealthProfileStore.alcohol,
    );

    setState(() {
      steps = s;
      heartRate = hr;
      risk = newRisk;
    });

    await FirebaseService.pushHealthData(
      email: AuthStore.email!,
      steps: s,
      heartRate: hr,
      spo2: spo2,
      systolic: bpSys,
      diastolic: bpDia,
      risk: newRisk,
    );
  }


  Widget infoCard({
    required IconData icon,
    required String title,
    required String value,
    Color? color,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          /// แก้ไขข้อมูลสุขภาพพื้นฐาน
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'ข้อมูลสุขภาพพื้นฐาน',
            onPressed: () async {
              final saved = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HealthProfileForm(),
                ),
              );
              if (saved == true) {
                setState(() {});
              }
            },
          ),

          /// กรอก SpO₂ / BP
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'กรอก SpO₂ / BP',
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManualInputPage()),
              );

              if (updated == true) {
                await HealthDataStore.load();
                setState(() {});
              }
            },
          ),

          /// 🚪 Logout
          // IconButton(
          //   icon: const Icon(Icons.logout),
          //   tooltip: 'Logout',
          //   onPressed: () async {
          //     await AuthStore.logout();

          //     Navigator.pushNamedAndRemoveUntil(
          //       context,
          //       '/login',
          //       (route) => false,
          //     );
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('ออกจากระบบ'),
                  content: const Text('ต้องการออกจากระบบใช่หรือไม่'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('ยกเลิก'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('ออกจากระบบ'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await GoogleFitService.logout();
                await AuthStore.logout();
                HealthDataStore.clearMemory(); // แค่ล้าง RAM
                Navigator.pushReplacementNamed(context, '/login');

                // if (!mounted) return;
                // Navigator.pushNamedAndRemoveUntil(
                //   context,
                //   '/login',
                //   (_) => false,
                // );
              }
            },
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadHealthData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  /// ---------- RiskEngine ----------
                  Card(
                    child: ExpansionTile(
                      leading: Icon(
                        Icons.warning,
                        color: risk.level == 'High Risk'
                            ? Colors.red
                            : risk.level == 'Medium Risk'
                                ? Colors.orange
                                : Colors.green,
                      ),
                      title: Text(
                        'Heart Disease Risk',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${risk.level} (Score ${risk.score})'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // children: risk.reasons.isEmpty
                            //     ? [const Text("ไม่พบปัจจัยเสี่ยงสำคัญ")]
                            //     : risk.reasons
                            //         .map((e) => Text("• $e"))
                            //         .toList(),
                            children: [
                              /// ปัจจัยเสี่ยง
                              if (risk.reasons.isEmpty)
                                const Text("ไม่พบปัจจัยเสี่ยงสำคัญ")
                              else
                                ...risk.reasons.map((e) => Text("• $e")),

                              const SizedBox(height: 12),
                              const Divider(),

                              /// อธิบาย Risk Score
                              const SizedBox(height: 8),
                              const Text(
                                "Risk Score คืออะไร",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "คะแนนนี้ใช้ประเมินความเสี่ยงโรคหัวใจจากข้อมูลสุขภาพ เช่น "
                                "อายุ BMI การสูบบุหรี่ การดื่มแอลกอฮอล์ Heart Rate "
                                "SpO₂ ความดันโลหิต และกิจกรรมทางกาย (Steps)",
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                "เกณฑ์คะแนน",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Text("0 - 14 : Low Risk (ความเสี่ยงต่ำ)"),
                              const Text("15 - 29 : Medium Risk (ความเสี่ยงปานกลาง)"),
                              const Text("30 - 50 : High Risk (ความเสี่ยงสูง)"),

                              const SizedBox(height: 10),

                              const Text(
                                "อ้างอิง: Thai Cardiovascular Risk Score\n"
                                "กรมอนามัย กระทรวงสาธารณสุข\n"
                                "ใช้สำหรับการเฝ้าระวังสุขภาพเบื้องต้น "
                                "ไม่ใช่การวินิจฉัยทางการแพทย์",
                                style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 59, 59, 59)),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  


                  /// ---------- Google Fit -----------
                  
                  const SizedBox(height: 12),
                  infoCard(
                    icon: Icons.favorite,
                    title: 'Heart Rate (ล่าสุด)',
                    value: '${heartRate.toStringAsFixed(1)} bpm',
                    color: Colors.red,
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.directions_walk),
                      title: const Text('Steps วันนี้'),
                      subtitle: const Text('เริ่มนับตั้งแต่ 00:00'),
                      trailing: Text('$steps', style: const TextStyle(fontSize: 16),),
                    ),
                  ),

                  const Divider(height: 32),

                  /// ---------- Manual ----------
                  infoCard(
                    icon: Icons.air,
                    title: 'SpO₂',
                    value: spo2 != null ? '$spo2 %' : 'ยังไม่มีข้อมูล',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  infoCard(
                    icon: Icons.monitor_heart,
                    title: 'ความดันโลหิต',
                    value: (bpSys != null && bpDia != null)
                        ? '$bpSys / $bpDia mmHg'
                        : 'ยังไม่มีข้อมูล',
                    color: Colors.deepPurple,
                  ),

                  const Divider(height: 32),

                  /// ---------- Profile ----------
                  infoCard(
                    icon: Icons.cake,
                    title: 'อายุ',
                    value: HealthProfileStore.age != null
                        ? '${HealthProfileStore.age} ปี'
                        : 'ยังไม่มีข้อมูล',
                  ),
                  const SizedBox(height: 12),
                  infoCard(
                    icon: Icons.scale,
                    title: 'BMI',
                    value: HealthProfileStore.bmi != null
                        ? HealthProfileStore.bmi!.toStringAsFixed(1)
                        : 'ยังไม่มีข้อมูล',
                  ),
                  const SizedBox(height: 12),
                  infoCard(
                    icon: Icons.smoking_rooms,
                    title: 'สูบบุหรี่',
                    value:
                        HealthProfileStore.smoking ? 'สูบ' : 'ไม่สูบ',
                  ),
                  const SizedBox(height: 12),
                  infoCard(
                    icon: Icons.local_bar,
                    title: 'ดื่มแอลกอฮอล์',
                    value:
                        HealthProfileStore.alcohol ? 'ดื่ม' : 'ไม่ดื่ม',
                  ),

                  /// ---------- Test Alert ----------

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.warning),
                    label: const Text("ทดสอบแจ้งเตือน High Risk"),
                    onPressed: () async {
                      await FirebaseService.sendTestAlert(
                        email: AuthStore.email!,
                      );
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("ส่งแจ้งเตือนทดสอบแล้ว")),
                      );
                    },
                  ),

                  
                ],
              ),
            ),
    );
  }
}

