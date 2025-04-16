import 'package:flutter/material.dart';
import 'package:deploy_it_app/pages/admin_page.dart';
import 'package:deploy_it_app/pages/deployment_page.dart';
import 'package:deploy_it_app/pages/login_page.dart';
import 'package:deploy_it_app/pages/status_page.dart';
import 'package:deploy_it_app/pages/sign_up_page.dart';
import 'package:deploy_it_app/pages/profile_page.dart';
import 'package:deploy_it_app/pages/pay_status.dart';
import 'package:deploy_it_app/components/theme_controller.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Deploy-It',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentMode,
          initialRoute: '/login',
          routes: {
            '/login': (context) => LoginPage(),
            '/signup': (context) => SignUpPage(),
            '/status': (context) => StatusPage(),
            '/profile': (context) => ProfilePage(),
            '/paid': (context) => PayStatus(),
            '/deploy': (context) => DeploymentPage(),
            '/admin': (context) => AdminPage(),
          },
        );
      },
    );
  }
}
