import 'package:flutter/material.dart';
import '../components/edit_user_page.dart';
import '../components/navigation_bar.dart';
import '../components/api_calls_temp.dart'; // Assuming your API functions are in here

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void fetchUsers() async {
    try {
      final fetchedUsers = await ApiService.getUsers(); // Create this method in your API service
      setState(() {
        users = fetchedUsers;
        loading = false;
      });
    } catch (e) {

      setState(() => loading = false);
    }
  }

  void deleteUser(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.deleteUser(userId); // Create this method in your API service
      fetchUsers(); // Refresh list
    }
  }

  void editUser(Map<String, dynamic> user) {
    // This can navigate to a new edit page or show a modal form
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditUserPage(user: user), // You'll need to create this page
      ),
    ).then((_) => fetchUsers()); // Refresh when coming back
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBarCustom(
      body: SafeArea(
        child: loading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: users.length,
          itemBuilder: (_, index) {
            final user = users[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(user['name']),
                subtitle: Text(user['email']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => editUser(user),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteUser(user['id']),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
