import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your pages
import 'package:deploy_it_app/pages/admin_page.dart';
import 'package:deploy_it_app/pages/deployment_page.dart';
import 'package:deploy_it_app/pages/login_page.dart';
import 'package:deploy_it_app/pages/status_page.dart';
import 'package:deploy_it_app/pages/sign_up_page.dart';
import 'package:deploy_it_app/pages/profile_page.dart';
import 'package:deploy_it_app/pages/pay_status.dart';
import 'package:deploy_it_app/components/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          initialRoute: '/splash', // Start at splash screen
          routes: {
            '/splash': (context) => const SplashScreen(),
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

// SplashScreen widget
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    await Future.delayed(const Duration(seconds: 2)); // Show splash for 2 seconds

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => StatusPage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginPage()),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_done, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'Deploy-It',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
