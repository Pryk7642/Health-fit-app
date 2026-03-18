import 'package:flutter/material.dart';
import '../services/google_fit_service.dart';
import '../services/auth_store.dart';
import '../services/health_profile_store.dart';
import '../services/health_data_store.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Login with Google'),
          onPressed: () async {
            final email = await GoogleFitService.signIn();
            

            if (email != null) {
              await AuthStore.saveEmail(email);
              await AuthStore.loadRole();
              await HealthProfileStore.load();
              await HealthDataStore.load();

              // Navigator.pushReplacementNamed(context, '/dashboard');
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            }
          },
        ),
      ),
    );
  }
}







// import 'package:flutter/material.dart';
// import '../services/google_fit_service.dart';
// import '../services/auth_store.dart';
// import '../services/health_profile_store.dart';
// import '../services/health_data_store.dart';

// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login')),
//       body: Center(
//         child: ElevatedButton(
//           child: const Text('Login with Google'),
//           onPressed: () async {
//             final email = await GoogleFitService.signIn();

//             if (email != null) {
//               await AuthStore.saveEmail(email);
//               await HealthProfileStore.load();
//               await HealthDataStore.load();

//               Navigator.pushReplacementNamed(context, '/dashboard');
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
