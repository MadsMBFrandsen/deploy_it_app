import 'package:deploy_it_app/components/my_button.dart';
import 'package:deploy_it_app/components/my_textfield.dart';
import 'package:flutter/material.dart';
import 'package:deploy_it_app/components/api_calls.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final usernameController = TextEditingController();
  final emailController = TextEditingController(); // <-- added this
  final passwordController = TextEditingController();

  void signUserUp(BuildContext context) async {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      String result = await ApiService.signUpUser(
        username: username,
        email: email.trim().toLowerCase(),
        password: password,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');

      // Specific handling
      if (errorMessage.contains('email has already been taken')) {
        errorMessage = 'This email is already registered. Please try logging in or use another email.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                const Icon(Icons.lock, size: 100),

                const SizedBox(height: 25),

                Text('Sign Up',
                  style: TextStyle(color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 25),

                Text('Welcome', style: TextStyle(color: Colors.grey[700], fontSize: 16)),

                const SizedBox(height: 25),

                // Username field
                MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),

                const SizedBox(height: 25),

                // Email field (NEW)
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 25),

                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 25),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Forgot Password?', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                MyButton(
                  onTap: () => signUserUp(context),
                  text: 'Create User',
                  backgroundColor: Colors.green,
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
                    Text('Am Already A User'),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        'Login Here',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
