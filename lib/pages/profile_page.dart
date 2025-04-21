import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deploy_it_app/components/navigation_bar.dart';
import 'package:deploy_it_app/components/my_textfield.dart';
import 'package:deploy_it_app/components/my_button.dart';
import 'package:deploy_it_app/components/api_calls_temp.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? username = prefs.getString('user_name');
      String? email = prefs.getString('user_email');

      setState(() {
        usernameController.text = username ?? '';
        emailController.text = email ?? '';
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data')),
      );
    }
  }

  void updateProfile() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final email = emailController.text.trim();

    if (username.isEmpty || password.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => saving = true);

    try {
      final message = await ApiService.updateUserProfile(
        username: username,
        password: password,
        email: email,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', username);
      await prefs.setString('user_email', email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      passwordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
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
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBarCustom(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // User info with icon
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blueGrey,
                    child: Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usernameController.text,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          emailController.text,
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Text('Edit Profile', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 25),

              _buildLabeledField("Username", usernameController, false),
              _buildLabeledField("Password", passwordController, true),
              _buildLabeledField("Email", emailController, false),

              const SizedBox(height: 20),
              MyButton(
                onTap: saving ? null : updateProfile,
                text: saving ? 'Saving...' : 'Save All Changes',
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
        ),
      ),
    );
  }

  Widget _buildLabeledField(String label, TextEditingController controller, bool isPassword) {
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
}
