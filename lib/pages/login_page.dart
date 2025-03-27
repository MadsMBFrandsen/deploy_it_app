import 'package:deploy_it_app/components/my_textfield.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(children: [
            const SizedBox(height: 50),

            const Icon(Icons.lock,
            size: 100,              
            ),

            SizedBox(height: 50),
            Text('Welcome',
            style: TextStyle(color: Colors.grey[700],
            fontSize: 16),
            ),

            SizedBox(height: 25),

            MyTextField(
              controller: usernameController,
              hintText: 'Username',
              obscureText: false,
            ),

            SizedBox(height: 25),

            MyTextField(
              controller: passwordController,
              hintText: 'Password',
              obscureText: true,
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




          ],),
        ),
      ),
    );

  }
}