import 'package:flutter/material.dart';
import '../services/health_profile_store.dart';

class HealthProfileForm extends StatefulWidget {
  const HealthProfileForm({super.key});

  @override
  State<HealthProfileForm> createState() => _HealthProfileFormState();
}

class _HealthProfileFormState extends State<HealthProfileForm> {
  final heightCtrl =
      TextEditingController(text: HealthProfileStore.heightCm?.toString());
  final weightCtrl =
      TextEditingController(text: HealthProfileStore.weightKg?.toString());

  String gender = HealthProfileStore.gender;// ?? 'male';
  bool smoking = HealthProfileStore.smoking;
  bool alcohol = HealthProfileStore.alcohol;

  void save() async {
    HealthProfileStore.heightCm =
        double.tryParse(heightCtrl.text);
    HealthProfileStore.weightKg =
        double.tryParse(weightCtrl.text);

    HealthProfileStore.gender = gender;
    HealthProfileStore.smoking = smoking;
    HealthProfileStore.alcohol = alcohol;

    HealthProfileStore.calculateBMI();
    await HealthProfileStore.save();

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ข้อมูลสุขภาพพื้นฐาน')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            /// 🎂 วันเกิด
            ListTile(
              title: const Text('วันเกิด'),
              subtitle: Text(
                HealthProfileStore.dateOfBirth == null
                    ? 'ยังไม่ได้เลือก'
                    : '${HealthProfileStore.dateOfBirth!.day}/'
                        '${HealthProfileStore.dateOfBirth!.month}/'
                        '${HealthProfileStore.dateOfBirth!.year}'
                        ' (อายุ ${HealthProfileStore.age} ปี)',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      HealthProfileStore.dateOfBirth ?? DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (picked != null) {
                  setState(() {
                    HealthProfileStore.dateOfBirth = picked;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            /// 👤 เพศ
            DropdownButtonFormField<String>(
              value: gender,
              items: const [
                DropdownMenuItem(value: 'male', child: Text('ชาย')),
                DropdownMenuItem(value: 'female', child: Text('หญิง')),
              ],
              onChanged: (v) => setState(() => gender = v!),
              decoration: const InputDecoration(labelText: 'เพศ'),
            ),

            const SizedBox(height: 12),

            /// 📏 ส่วนสูง
            TextField(
              controller: heightCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'ส่วนสูง (cm)'),
            ),

            const SizedBox(height: 12),

            /// ⚖ น้ำหนัก
            TextField(
              controller: weightCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'น้ำหนัก (kg)'),
            ),

            const SizedBox(height: 16),

            /// 🚬 สูบบุหรี่
            SwitchListTile(
              title: const Text('สูบบุหรี่'),
              value: smoking,
              onChanged: (v) => setState(() => smoking = v),
            ),

            /// 🍺 แอลกอฮอล์
            SwitchListTile(
              title: const Text('ดื่มแอลกอฮอล์'),
              value: alcohol,
              onChanged: (v) => setState(() => alcohol = v),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: save,
              child: const Text('บันทึกข้อมูล'),
            )
          ],
        ),
      ),
    );
  }
}
