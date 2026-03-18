import 'package:flutter/material.dart';
import '../services/health_data_store.dart';

class ManualInputPage extends StatefulWidget {
  const ManualInputPage({super.key});

  @override
  State<ManualInputPage> createState() => _ManualInputPageState();
}

class _ManualInputPageState extends State<ManualInputPage> {
  final _formKey = GlobalKey<FormState>();

  final spo2Ctrl = TextEditingController();
  final bpSysCtrl = TextEditingController();
  final bpDiaCtrl = TextEditingController();

  @override
  void dispose() {
    spo2Ctrl.dispose();
    bpSysCtrl.dispose();
    bpDiaCtrl.dispose();
    super.dispose();
  }

  void saveData() async {
    if (_formKey.currentState!.validate()) {
      if (spo2Ctrl.text.isNotEmpty) {
        HealthDataStore.spo2 = int.parse(spo2Ctrl.text);
      }

      if (bpSysCtrl.text.isNotEmpty) {
        HealthDataStore.systolic = int.parse(bpSysCtrl.text);
      }

      if (bpDiaCtrl.text.isNotEmpty) {
        HealthDataStore.diastolic = int.parse(bpDiaCtrl.text);
      }

      await HealthDataStore.save(); // ✅ บันทึกตาม email

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('กรอกข้อมูลสุขภาพ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: spo2Ctrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'SpO₂ (%)',
                  prefixIcon: Icon(Icons.air),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final val = int.tryParse(v);
                  if (val == null || val < 70 || val > 100) {
                    return 'SpO₂ ต้องอยู่ระหว่าง 70–100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: bpSysCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ความดันตัวบน (Sys)',
                  prefixIcon: Icon(Icons.favorite),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: bpDiaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ความดันตัวล่าง (Dia)',
                  prefixIcon: Icon(Icons.favorite_border),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: saveData,
                icon: const Icon(Icons.save),
                label: const Text('บันทึกข้อมูล'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
