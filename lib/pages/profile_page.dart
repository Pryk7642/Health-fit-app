import 'package:flutter/material.dart';
import '../store/profile_store.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final store = ProfileStore();

  late TextEditingController heightCtrl;
  late TextEditingController weightCtrl;
  late TextEditingController spo2Ctrl;
  late TextEditingController sysCtrl;
  late TextEditingController diaCtrl;

  bool smoking = false;
  bool alcohol = false;

  @override
  void initState() {
    super.initState();
    final p = store.profile;
    heightCtrl = TextEditingController(text: p.height.toString());
    weightCtrl = TextEditingController(text: p.weight.toString());
    spo2Ctrl = TextEditingController(text: p.spo2.toString());
    sysCtrl = TextEditingController(text: p.systolic.toString());
    diaCtrl = TextEditingController(text: p.diastolic.toString());
    smoking = p.smoking;
    alcohol = p.alcohol;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: heightCtrl, decoration: const InputDecoration(labelText: 'Height (cm)')),
          TextField(controller: weightCtrl, decoration: const InputDecoration(labelText: 'Weight (kg)')),
          TextField(controller: spo2Ctrl, decoration: const InputDecoration(labelText: 'SpO₂ (%)')),
          TextField(controller: sysCtrl, decoration: const InputDecoration(labelText: 'Systolic BP')),
          TextField(controller: diaCtrl, decoration: const InputDecoration(labelText: 'Diastolic BP')),
          SwitchListTile(title: const Text('Smoking'), value: smoking, onChanged: (v) => setState(() => smoking = v)),
          SwitchListTile(title: const Text('Alcohol'), value: alcohol, onChanged: (v) => setState(() => alcohol = v)),
          const SizedBox(height: 20),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              store.profile.height = double.tryParse(heightCtrl.text) ?? 0;
              store.profile.weight = double.tryParse(weightCtrl.text) ?? 0;
              store.profile.spo2 = double.tryParse(spo2Ctrl.text) ?? 0;
              store.profile.systolic = int.tryParse(sysCtrl.text) ?? 0;
              store.profile.diastolic = int.tryParse(diaCtrl.text) ?? 0;
              store.profile.smoking = smoking;
              store.profile.alcohol = alcohol;
              await store.save();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
              }
            },
          )
        ],
      ),
    );
  }
}