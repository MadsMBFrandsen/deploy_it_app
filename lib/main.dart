import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:deploy_it_app/components/theme_controller.dart';
import 'package:deploy_it_app/pages/admin_page.dart';
import 'package:deploy_it_app/pages/deployment_page.dart';
import 'package:deploy_it_app/pages/login_page.dart';
import 'package:deploy_it_app/pages/status_page.dart';
import 'package:deploy_it_app/pages/sign_up_page.dart';
import 'package:deploy_it_app/pages/profile_page.dart';
import 'package:deploy_it_app/pages/pay_status.dart';

import 'components/SplashScreen.dart';

// Initialisering af notifikation-plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await requestNotificationPermission();
  await initNotifications();

  runApp(const Deploy_It());
}

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  if (await Permission.notification.isGranted) {
    print('🔔 Notifikationstilladelse givet');
  } else {
    print('❌ Notifikationstilladelse nægtet');
  }
}

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void showTestNotification() async {
  const AndroidNotificationDetails androidDetails =
  AndroidNotificationDetails('test_channel', 'Test Notifikationer',
      importance: Importance.max, priority: Priority.high);

  const NotificationDetails notificationDetails =
  NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
      0, 'Test Notifikation', 'Det her virker!', notificationDetails);
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
