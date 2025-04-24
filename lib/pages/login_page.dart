import 'package:deploy_it_app/components/my_button.dart';
import 'package:deploy_it_app/components/my_textfield.dart';
import 'package:flutter/material.dart';
import 'package:deploy_it_app/components/api_calls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      final loginResponse = await ApiService.login(email, password);
      final token = loginResponse['token'];
      final user = loginResponse['user'];
      final role = user['role'];
      final name = user['name'];
      final userEmail = user['email'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_role', role);
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', userEmail);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome $name! You are a ($role)')),
      );

      Navigator.pushReplacementNamed(context, '/status');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }
  }

  void fillAdminCredentials() {
    emailController.text = "admin@example.org";
    passwordController.text = "KrBFrF6HBP8z8VBDmd9y";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              GestureDetector(
                onLongPress: fillAdminCredentials,
                child: const Icon(Icons.lock, size: 100),
              ),
              const SizedBox(height: 25),
              const Text('Login',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              Text('Welcome',
                  style: TextStyle(
                      color: Colors.grey[700], fontSize: 16)),
              const SizedBox(height: 25),
              MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false),
              const SizedBox(height: 25),
              MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Forgot Password?',
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              MyButton(
                onTap: () => signUserIn(context),
                text: 'Sign In',
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                padd: const EdgeInsets.all(25),
                marg: const EdgeInsets.symmetric(horizontal: 25),
              ),
              const SizedBox(height: 25),
              Divider(thickness: 0.5, color: Colors.grey[400]),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Not A Member'),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text('Register Here',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
