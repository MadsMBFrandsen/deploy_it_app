import 'package:deploy_it_app/pages/admin_page.dart';
import 'package:deploy_it_app/pages/deployment_page.dart';
import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/status_page.dart';
import 'pages/sign_up_page.dart';
import 'pages/profile_page.dart';
import 'pages/pay_status.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/status': (context) => StatusPage(),//get token and put it in or have it as an global value
        '/profile': (context) => ProfilePage(),
        '/paid': (context) => PayStatus(),
        '/deploy': (context) => DeploymentPage(),
        '/admin': (context) => AdminPage(),
      },
    );
  }
}
