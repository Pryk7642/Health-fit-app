import 'package:flutter/material.dart';
import '../services/auth_store.dart';
import 'login_page.dart';
import 'select_role_page.dart';
import 'dashboard_page.dart';
import 'caregiver_dashboard.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ยังไม่ได้ login
    if (AuthStore.email == null) {
      return const LoginPage();
    }

    // login แล้ว แต่ยังไม่เลือก role
    if (AuthStore.role == null) {
      return const SelectRolePage();
    }

    // patient
    if (AuthStore.role == 'patient') {
      return const DashboardPage();
    }

    // caregiver
    return const CaregiverDashboard();
  }
}
