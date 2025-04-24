/*import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const String vmTaskKey = 'checkVMUsage';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

/// This function is executed by Workmanager in the background
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == vmTaskKey) {
      await _initNotifications();
      await _checkVMUsageAndNotify();
    }
    return Future.value(true);
  });
}

Future<void> _initNotifications() async {
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
  InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

Future<void> _checkVMUsageAndNotify() async {
  final prefs = await SharedPreferences.getInstance();
  final cpuThreshold = (prefs.getInt('cpu_threshold') ?? 80) / 100.0;
  final ramThreshold = (prefs.getInt('ram_threshold') ?? 80) / 100.0;
  final storageThreshold = (prefs.getInt('storage_threshold') ?? 90) / 100.0;

  // Replace these mock values with your real API call
  final double cpu = 0.92;
  final double ram = 0.75;
  final double storage = 0.95;

  if (cpu > cpuThreshold) await _sendNotification('CPU', cpu);
  if (ram > ramThreshold) await _sendNotification('RAM', ram);
  if (storage > storageThreshold) await _sendNotification('Storage', storage);
}

Future<void> _sendNotification(String type, double usage) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'vm_alerts',
    'VM Usage Alerts',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
  NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    '⚠️ $type Alert',
    '$type usage is at ${(usage * 100).toStringAsFixed(1)}%',
    notificationDetails,
  );
}
*/