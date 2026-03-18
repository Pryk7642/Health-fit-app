import 'package:flutter/material.dart';
import '../services/auth_store.dart';

class SelectRolePage extends StatelessWidget {
  const SelectRolePage({super.key});

  void _selectRole(BuildContext context, String role) async {
    await AuthStore.saveRole(role);

    Navigator.pushReplacementNamed(
      context,
      role == 'patient' ? '/patient' : '/caregiver',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เลือกบทบาท')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'คุณคือใคร?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            ElevatedButton.icon(
              icon: const Icon(Icons.favorite),
              label: const Text('ผู้ป่วย'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
              ),
              onPressed: () => _selectRole(context, 'patient'),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              icon: const Icon(Icons.group),
              label: const Text('ญาติ / ผู้ดูแล'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
              ),
              onPressed: () => _selectRole(context, 'caregiver'),
            ),
          ],
        ),
      ),
    );
  }
}
