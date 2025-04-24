/*

import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'background_task.dart';

/// Schedules a background VM check task if user has notifications enabled.
Future<void> scheduleBackgroundCheckBasedOnPrefs() async {
  final prefs = await SharedPreferences.getInstance();

  final bool enabled = prefs.getBool('notifications_enabled') ?? true;
  final int interval = prefs.getInt('notification_interval') ?? 30;

  // Cancel any previously scheduled task
  await Workmanager().cancelAll();

  if (enabled) {
    await Workmanager().registerPeriodicTask(
      "vmCheckTask",
      vmTaskKey,
      frequency: Duration(minutes: interval),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
    print('🔔 Scheduled VM usage check every $interval minutes');
  } else {
    print('🔕 Notifications disabled, background task not scheduled');
  }
}
 */