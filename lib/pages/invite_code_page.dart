import 'package:flutter/material.dart';
import '../services/invite_service.dart';

class InviteCodePage extends StatefulWidget {
  const InviteCodePage({super.key});

  @override
  State<InviteCodePage> createState() => _InviteCodePageState();
}

class _InviteCodePageState extends State<InviteCodePage> {
  String? code;

  void generate() async {
    final c = await InviteService.generateCode();
    setState(() => code = c);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เชิญผู้ดูแล')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (code != null)
              Text(
                code!,
                style: const TextStyle(
                    fontSize: 36, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: generate,
              child: const Text('สร้างรหัสเชิญ'),
            ),
            const SizedBox(height: 12),
            const Text('รหัสมีอายุ 10 นาที'),
          ],
        ),
      ),
    );
  }
}
