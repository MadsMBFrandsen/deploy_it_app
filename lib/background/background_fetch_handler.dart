/*
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// Initialiserer local notifikationer og background fetch
Future<void> initializeBackgroundFetch() async {
  // Notifikation init
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Konfigurer BackgroundFetch
  await BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 15, // i minutter
      forceAlarmManager: true, // vigtig for Android 12+
      startOnBoot: true,       // genstarter efter genstart
      enableHeadless: true,    // kan køre selv uden aktivt UI
      stopOnTerminate: false,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      requiresStorageNotLow: false,
      requiredNetworkType: NetworkType.ANY,
    ),
    _onBackgroundFetch,
    _onTimeout,
  );
}

// Logic der kører i baggrunden
Future<void> _onBackgroundFetch(String taskId) async {
  final prefs = await SharedPreferences.getInstance();
  final enabled = prefs.getBool('notifications_enabled') ?? true;
  final cpuThreshold = (prefs.getInt('cpu_threshold') ?? 80) / 100.0;
  final ramThreshold = (prefs.getInt('ram_threshold') ?? 80) / 100.0;
  final storageThreshold = (prefs.getInt('storage_threshold') ?? 90) / 100.0;

  if (!enabled) {
    BackgroundFetch.finish(taskId);
    return;
  }

  // MOCK DATA
  final double cpu = 0.91;
  final double ram = 0.83;
  final double storage = 0.93;

  if (cpu > cpuThreshold) await _sendNotification('CPU', cpu);
  if (ram > ramThreshold) await _sendNotification('RAM', ram);
  if (storage > storageThreshold) await _sendNotification('Storage', storage);

  BackgroundFetch.finish(taskId);
}

Future<void> _sendNotification(String label, double usage) async {
  const androidDetails = AndroidNotificationDetails(
    'vm_alerts',
    'VM Usage Alerts',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );

  const details = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    '⚠️ $label Alert',
    '$label usage is at ${(usage * 100).toStringAsFixed(1)}%',
    details,
  );
}

void _onTimeout(String taskId) {
  print("[BackgroundFetch] TASK TIMEOUT: $taskId");
  BackgroundFetch.finish(taskId);
}
*/