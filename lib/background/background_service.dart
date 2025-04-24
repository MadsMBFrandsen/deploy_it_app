/*
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deploy_it_app/components/api_calls_temp.dart';
import 'package:background_fetch/background_fetch.dart';

// Initialize notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Headless task (when app is killed)
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool timeout = task.timeout;

  WidgetsFlutterBinding.ensureInitialized();

  if (timeout) {
    BackgroundFetch.finish(taskId);
    return;
  }

  await _initializeNotifications();
  await monitorVmResources();

  BackgroundFetch.finish(taskId);
}

// Initialize notifications
Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: DarwinInitializationSettings(),
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  final androidImplementation = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  await androidImplementation?.createNotificationChannel(
    const AndroidNotificationChannel(
      'resource_monitor_channel',
      'Resource Monitoring',
      description: 'Channel for VM resource monitoring alerts',
      importance: Importance.high,
    ),
  );
}

// Main VM Monitoring logic
Future<void> monitorVmResources() async {
  String? vmId = await loadSelectedVmId();
  if (vmId == null) {
    print("No VM selected. Skipping monitoring task.");
    return;
  }

  final Map<String, dynamic> status = await getVMStatusFromApi(vmId);

  double cpu = _parsePercentage(status["cpu_usage"]);
  double ram = _parsePercentage(status["ram_usage"]);
  double storage = _parsePercentage(status["storage_usage"]);

  double cpuThreshold = await loadCpuThreshold();
  double ramThreshold = await loadRamThreshold();
  double storageThreshold = await loadStorageThreshold();

  print('Fetched VM usage: CPU=$cpu, RAM=$ram, Storage=$storage');

  if (cpu > cpuThreshold || ram > ramThreshold || storage > storageThreshold) {
    String message = "CPU: ${(cpu * 100).toStringAsFixed(1)}%\n"
        "RAM: ${(ram * 100).toStringAsFixed(1)}%\n"
        "Storage: ${(storage * 100).toStringAsFixed(1)}%";

    await flutterLocalNotificationsPlugin.show(
      0,
      ' VM Resource Warning',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'resource_monitor_channel',
          'Resource Monitoring',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );

    print("Warning notification sent.");
  } else {
    print("VM resources normal. No notification needed.");
  }
}

// -----------------
// Helper functions
// -----------------

Future<String?> loadSelectedVmId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('selected_vm_id');
}

Future<Map<String, dynamic>> getVMStatusFromApi(String vmId) async {
  try {
    return await ApiService.getVMStatus(vmId);
  } catch (e) {
    print("Error fetching VM status: $e");
    return {
      "cpu_usage": "0%",
      "ram_usage": "0%",
      "storage_usage": "0%",
    };
  }
}

Future<double> loadCpuThreshold() async {
  final prefs = await SharedPreferences.getInstance();
  int cpuLimit = prefs.getInt('cpu_threshold') ?? 80;
  return cpuLimit / 100.0;
}

Future<double> loadRamThreshold() async {
  final prefs = await SharedPreferences.getInstance();
  int ramLimit = prefs.getInt('ram_threshold') ?? 80;
  return ramLimit / 100.0;
}

Future<double> loadStorageThreshold() async {
  final prefs = await SharedPreferences.getInstance();
  int storageLimit = prefs.getInt('storage_threshold') ?? 90;
  return storageLimit / 100.0;
}

double _parsePercentage(String percentStr) {
  return double.tryParse(percentStr.replaceAll('%', ''))! / 100.0;
}

// Request notification permission (for Android 13+)
Future<void> requestNotificationPermission() async {
  final androidImplementation = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  if (androidImplementation != null) {
    final bool? granted = await androidImplementation.requestNotificationsPermission();
    print('Notification permission granted: $granted');
  }
}
*/