import 'package:deploy_it_app/components/my_button.dart';
import 'package:deploy_it_app/components/my_textfield.dart';
import 'package:flutter/material.dart';
import 'package:deploy_it_app/components/api_calls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn(BuildContext context) async {
    //final email = emailController.text.trim();
    //final password = passwordController.text;

    final email = "admin@example.org";
    final password = "KrBFrF6HBP8z8VBDmd9y";


    try {
      final loginResponse = await ApiService.login(email, password);

      final token = loginResponse['token'];
      final user = loginResponse['user'];
      final role = user['role'];
      final name = user['name'];
      final userEmail = user['email'];

      // Save to SharedPreferences
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



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            const SizedBox(height: 50),

            const Icon(Icons.lock,
            size: 100,              
            ),

            SizedBox(height: 25),

            Text('Login',
            style: TextStyle(color: Colors.black,
            fontSize: 30,
                fontWeight: FontWeight.bold
            ),
              ),

            SizedBox(height: 25),

            Text('Welcome',
            style: TextStyle(color: Colors.grey[700],
            fontSize: 16),
            ),

            SizedBox(height: 25),

            MyTextField(
              controller: emailController,
              hintText: 'Email',
              obscureText: false,
            ),

            SizedBox(height: 25),

            MyTextField(
              controller: passwordController,
              hintText: 'Password',
              obscureText: false,
            ),


            SizedBox(height: 25),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Forgot Password?',
                  style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),


            SizedBox(height: 25),

            MyButton(
              onTap: () => signUserIn(context),
              text: 'Sign In',
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              padd: EdgeInsets.all(25),
              marg: EdgeInsets.symmetric(horizontal: 25),
            ),


            SizedBox(height: 25),

            Divider(
              thickness: 0.5,
              color: Colors.grey[400],
             ),

            SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Not A Member'),
                const SizedBox(width: 4,),
                Text('Register Here',
                style: TextStyle(
                  color: Colors.blue, fontWeight: FontWeight.bold),
                )
              ],
            )

          ],),
        ),
      ),
    );

  }
}