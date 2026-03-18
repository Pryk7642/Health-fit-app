import 'package:flutter/material.dart';
import '../services/invite_service.dart';
import '../services/caregiver_store.dart';

class EnterInvitePage extends StatefulWidget {
  const EnterInvitePage({super.key});

  @override
  State<EnterInvitePage> createState() => _EnterInvitePageState();
}

class _EnterInvitePageState extends State<EnterInvitePage> {
  final emailCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  String? error;

  void submit() async {
    final ok = await InviteService.validateCode(
      emailCtrl.text.trim(),
      codeCtrl.text.trim(),
    );

    if (ok) {
      await CaregiverStore.savePatientEmail(emailCtrl.text.trim());
      Navigator.pushReplacementNamed(context, '/caregiver');
    } else {
      setState(() => error = 'รหัสไม่ถูกต้องหรือหมดอายุ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('กรอกรหัสเชิญ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email ผู้ป่วย',
              ),
            ),
            TextField(
              controller: codeCtrl,
              decoration: const InputDecoration(
                labelText: 'Invite Code',
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: submit,
              child: const Text('เชื่อมต่อ'),
            ),
          ],
        ),
      ),
    );
  }
}
