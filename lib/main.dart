import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:deploy_it_app/pages/admin_page.dart';
import 'package:deploy_it_app/pages/deployment_page.dart';
import 'package:deploy_it_app/pages/login_page.dart';
import 'package:deploy_it_app/pages/status_page.dart';
import 'package:deploy_it_app/pages/sign_up_page.dart';
import 'package:deploy_it_app/pages/profile_page.dart';
import 'package:deploy_it_app/pages/pay_status.dart';

import 'package:deploy_it_app/components/theme_controller.dart';
import 'package:deploy_it_app/components/SplashScreen.dart';

import 'package:deploy_it_app/components/vm_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = VMProvider();
            provider.preloadVMs();
            return provider;
          },
        ),
      ],
      child: const Deploy_It(),
    ),
  );
}

class Deploy_It extends StatelessWidget {
  const Deploy_It({super.key});

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
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/login': (context) => const LoginPage(),
            '/signup': (context) => SignUpPage(),
            '/status': (context) => StatusPage(),
            '/profile': (context) => const ProfilePage(),
            '/paid': (context) => PayStatus(),
            '/deploy': (context) => DeploymentPage(),
            '/admin': (context) => AdminPage(),
          },
        );
      },
    );
  }
}