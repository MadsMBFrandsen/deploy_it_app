import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:deploy_it_app/components/navigation_bar.dart';
import 'package:deploy_it_app/components/my_textfield.dart';
import 'package:deploy_it_app/components/my_button.dart';
import 'package:deploy_it_app/components/api_calls.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  bool loading = true;
  bool saving = false;

  int notificationInterval = 30;
  bool notificationsEnabled = true;
  int cpuThreshold = 80;
  int ramThreshold = 80;
  int storageThreshold = 90;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadUserData();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'test_channel',
      'Test Notifikationer',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Test Notifikation',
      'Det her virker!',
      notificationDetails,
    );
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied ||
        await Permission.notification.isRestricted) {
      await Permission.notification.request();
    }
  }

  void loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? username = prefs.getString('user_name');
      String? email = prefs.getString('user_email');
      int? savedInterval = prefs.getInt('notification_interval');
      bool? savedEnabled = prefs.getBool('notifications_enabled');
      int? savedCpuThreshold = prefs.getInt('cpu_threshold');
      int? savedRamThreshold = prefs.getInt('ram_threshold');
      int? savedStorageThreshold = prefs.getInt('storage_threshold');

      final List<int> validIntervals = [15, 30, 60];

      setState(() {
        usernameController.text = username ?? '';
        emailController.text = email ?? '';
        notificationInterval =
        validIntervals.contains(savedInterval) ? savedInterval! : 30;
        notificationsEnabled = savedEnabled ?? true;
        cpuThreshold = savedCpuThreshold ?? 80;
        ramThreshold = savedRamThreshold ?? 80;
        storageThreshold = savedStorageThreshold ?? 90;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load user data')),
      );
    }
  }

  void saveProfileSettings() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();

    if (username.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username and Email cannot be empty')),
      );
      return;
    }

    bool wantsToChangePassword =
        oldPassword.isNotEmpty || newPassword.isNotEmpty;

    if (wantsToChangePassword) {
      if (oldPassword.isEmpty || newPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please fill both old and new password fields')),
        );
        return;
      }
      if (newPassword.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('New password must be at least 6 characters')),
        );
        return;
      }
    }

    setState(() => saving = true);

    try {
      final message = await ApiService.updateUserProfile(
        username: username,
        email: email,
        oldPassword: wantsToChangePassword ? oldPassword : null,
        newPassword: wantsToChangePassword ? newPassword : null,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', username);
      await prefs.setString('user_email', email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      oldPasswordController.clear();
      newPasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      setState(() => saving = false);
    }
  }

  void saveNotificationSettings() async {
    setState(() => saving = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notification_interval', notificationInterval);
      await prefs.setBool('notifications_enabled', notificationsEnabled);
      await prefs.setInt('cpu_threshold', cpuThreshold);
      await prefs.setInt('ram_threshold', ramThreshold);
      await prefs.setInt('storage_threshold', storageThreshold);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification Settings Saved!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save settings: $e')),
      );
    } finally {
      setState(() => saving = false);
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _tabController.dispose();
    usernameController.dispose();
    emailController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBarCustom(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Edit Profile'),
                Tab(text: 'Notification Settings'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  buildEditProfileTab(),
                  buildNotificationSettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEditProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildLabeledField("Username", usernameController, false),
          _buildLabeledField("Email", emailController, false),
          const SizedBox(height: 20),
          _buildLabeledField("Old Password", oldPasswordController, true),
          _buildLabeledField("New Password", newPasswordController, true),
          const SizedBox(height: 30),
          MyButton(
            onTap: saving ? null : saveProfileSettings,
            text: saving ? 'Saving...' : 'Save Profile',
            backgroundColor: saving ? Colors.grey : Colors.green,
            textColor: Colors.white,
            padd: const EdgeInsets.all(25),
            marg: const EdgeInsets.symmetric(horizontal: 8),
          ),
          const SizedBox(height: 20),
          MyButton(
            onTap: logout,
            text: 'Logout',
            backgroundColor: Colors.red,
            textColor: Colors.white,
            padd: const EdgeInsets.all(25),
            marg: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ],
      ),
    );
  }

  Widget buildNotificationSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Receive Notifications',
                  style: TextStyle(fontSize: 18)),
              Switch(
                value: notificationsEnabled,
                onChanged: (bool value) async {
                  setState(() {
                    notificationsEnabled = value;
                  });

                  if (value) {
                    if (!(await Permission.notification.isGranted)) {
                      await requestNotificationPermission();
                    }
                    await _showTestNotification();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications Enabled')),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications Disabled')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Notify Every (minutes)',
                  style: TextStyle(fontSize: 18)),
              DropdownButton<int>(
                value: notificationInterval,
                items: [15, 30, 60].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value min'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    notificationInterval = newValue ?? 30;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text('Warning Thresholds', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          _buildThresholdRow('CPU Warning Level', cpuThreshold, (val) {
            setState(() {
              cpuThreshold = val ?? 80;
            });
          }),
          _buildThresholdRow('RAM Warning Level', ramThreshold, (val) {
            setState(() {
              ramThreshold = val ?? 80;
            });
          }),
          _buildThresholdRow('Storage Warning Level', storageThreshold, (val) {
            setState(() {
              storageThreshold = val ?? 90;
            });
          }),
          const SizedBox(height: 30),
          MyButton(
            onTap: saving ? null : saveNotificationSettings,
            text: saving ? 'Saving...' : 'Save Notification Settings',
            backgroundColor: saving ? Colors.grey : Colors.blue,
            textColor: Colors.white,
            padd: const EdgeInsets.all(25),
            marg: const EdgeInsets.symmetric(horizontal: 8),
          ),
          const SizedBox(height: 20),
          MyButton(
            onTap: _showTestNotification,
            text: 'Send Test Notification',
            backgroundColor: Colors.deepPurple,
            textColor: Colors.white,
            padd: const EdgeInsets.all(20),
            marg: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField(
      String label, TextEditingController controller, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        MyTextField(
          controller: controller,
          hintText: label,
          obscureText: isPassword,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildThresholdRow(
      String label, int currentValue, Function(int?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 18)),
        DropdownButton<int>(
          value: currentValue,
          items: [30, 70, 80, 85, 90, 95].map((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('$value%'),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
