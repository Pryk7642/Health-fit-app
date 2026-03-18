import 'package:flutter/material.dart';
import '../services/caregiver_store.dart';
import '../services/auth_store.dart';

class SelectPatientPage extends StatefulWidget {
  const SelectPatientPage({super.key});

  @override
  State<SelectPatientPage> createState() => _SelectPatientPageState();
}

class _SelectPatientPageState extends State<SelectPatientPage> {
  final ctrl = TextEditingController();

  void save() async {
    if (ctrl.text.isNotEmpty) {
      await CaregiverStore.savePatientEmail(ctrl.text.trim());
      Navigator.pushReplacementNamed(context, '/caregiver');
    }
  }

  Future<void> logout() async {
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
      await AuthStore.logout();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เลือกผู้ป่วย'),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: logout,
        )
      ],),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: ctrl,
              decoration: const InputDecoration(
                labelText: 'Email ผู้ป่วย',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: save,
              child: const Text('ดูข้อมูลผู้ป่วย'),
            )
          ],
        ),
      ),
    );
  }
}
