import 'package:deploy_it_app/components/my_button.dart';
import 'package:deploy_it_app/components/my_textfield.dart';
import 'package:flutter/material.dart';


class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserUp(){}


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
                controller: usernameController,
                hintText: 'Username',
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
                onTap: signUserUp,
                text: 'Create User',
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
                  Text('Am Already A User'),
                  const SizedBox(width: 4,),
                  Text('´Login Here',
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
