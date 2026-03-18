import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:health_fit_native/services/alert_listener.dart';
import 'package:health_fit_native/services/caregiver_store.dart';
import 'package:health_fit_native/services/google_fit_service.dart';
import 'package:health_fit_native/services/notification_service.dart';
import 'package:health_fit_native/services/auth_store.dart';
import 'package:health_fit_native/services/health_profile_store.dart';
import 'package:health_fit_native/services/health_data_store.dart';

import 'pages/root_page.dart';
import 'pages/login_page.dart';
import 'pages/select_role_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/caregiver_dashboard.dart';
import 'pages/select_patient_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await NotificationService.init();

  await AuthStore.loadEmail();
  await AuthStore.loadRole();

  if (AuthStore.email != null) {
    await GoogleFitService.tryReconnect();
    await HealthProfileStore.load();
    await HealthDataStore.load();
  }

  /// 🔥 Start global listener ถ้าเป็น caregiver
  if (AuthStore.role == 'caregiver') {
    await CaregiverStore.load();

    if (CaregiverStore.patientUid != null) {
      GlobalAlertListener.start(CaregiverStore.patientUid!);
    }
  }

  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/',
      routes: {
        '/': (_) => const RootPage(),
        '/login': (_) => const LoginPage(),
        '/select-role': (_) => const SelectRolePage(),
        '/patient': (_) => const DashboardPage(),
        '/caregiver': (_) => const CaregiverDashboard(),
        '/select-patient': (_) => const SelectPatientPage(),
      },

      // initialRoute: AuthStore.email == null
      //   ? '/login'
      //   : AuthStore.role == null
      //       ? '/select-role'
      //       : AuthStore.role == 'patient'
      //           ? '/patient'
      //           : '/caregiver',
                
      // routes: {
      //   '/login': (_) => const LoginPage(),
      //   '/select-role': (_) => const SelectRolePage(),
      //   '/patient': (_) => const DashboardPage(),
      //   '/caregiver': (_) => const CaregiverDashboard(),
      //   '/select-patient': (_) => const SelectPatientPage(),
      // },
    );
  }
}
