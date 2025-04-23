import 'dart:convert';
import 'package:flutter/material.dart';
import 'api_calls_temp.dart';

class EditUserPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditUserPage({super.key, required this.user});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user['name']);
    emailController = TextEditingController(text: widget.user['email']);
    passwordController = TextEditingController(); // blank by default
  }

  void saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    final updatedUser = {
      "name": nameController.text,
      "email": emailController.text,
    };

    if (passwordController.text.isNotEmpty) {
      updatedUser["password"] = passwordController.text;
    }

    try {
      final response = await ApiService.updateUser(widget.user['id'], updatedUser);
      final message = jsonDecode(response.body)['message'];

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      Navigator.pop(context); // Go back to AdminPage
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Edit User')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Name"),
                  validator: (val) => val == null || val.isEmpty ? "Enter a name" : null,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  validator: (val) => val == null || !val.contains('@') ? "Enter valid email" : null,
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: "New Password (leave blank to keep current)"),
                  obscureText: true,
                ),
                SizedBox(height: 24),
                saving
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: saveChanges,
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
