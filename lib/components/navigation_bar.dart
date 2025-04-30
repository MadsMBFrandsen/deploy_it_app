import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deploy_it_app/components/theme_controller.dart';

import '../pages/admin_page.dart';
import '../pages/deployment_page.dart';
import '../pages/login_page.dart';
import '../pages/pay_status.dart';
import '../pages/profile_page.dart';
import '../pages/status_page.dart';



class NavigationBarCustom extends StatefulWidget {
  final Widget body;

  const NavigationBarCustom({super.key, required this.body});

  @override
  State<NavigationBarCustom> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBarCustom> {
  bool _isDrawerOpen = false;
  final double drawerWidth = 250;

  bool isAdmin = false;
  bool isAPayingUser = false;

  String userName = '';
  String userEmail = '';
 // String? userAvatar;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    loadUserRole();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      if (!mounted) return;
      // No token? Redirect to login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = (prefs.getString('user_role') ?? 'user').toLowerCase();
    userName = prefs.getString('user_name') ?? 'Guest';
    userEmail = prefs.getString('user_email') ?? 'guest@example.com';
    //userAvatar = prefs.getString('user_avatar_url');

    setState(() {
      isAdmin = role == 'admin';
      isAPayingUser = role == 'user';
    });
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  void _handleSwipe(DragUpdateDetails details) {
    if (details.delta.dx > 10 && !_isDrawerOpen) {
      setState(() => _isDrawerOpen = true);
    } else if (details.delta.dx < -10 && _isDrawerOpen) {
      setState(() => _isDrawerOpen = false);
    }
  }

  void _navigateWithTransition(String route) {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => getPageForRoute(route),
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    ));
  }

  Widget getPageForRoute(String route) {
    switch (route) {
      case '/status':
        return StatusPage();
      case '/deploy':
        return DeploymentPage();
      case '/profile':
        return ProfilePage();
      case '/paid':
        return PayStatus();
      case '/admin':
        return AdminPage();
      case '/login':
      default:
        return LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDrawerOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isDrawerOpen) {
          setState(() => _isDrawerOpen = false);
        }
      },
      child: GestureDetector(
        onHorizontalDragUpdate: _handleSwipe,
        child: Scaffold(
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Container(
                      color: Colors.blueGrey[800],
                      height: 60,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.menu, color: Colors.white),
                            tooltip: "Open drawer",
                            onPressed: _toggleDrawer,
                          ),
                          Expanded(
                            child: Text(
                              'Deploy-It',
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: widget.body),
                  ],
                ),
              ),

              // Drawer
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                top: 0,
                bottom: 0,
                left: _isDrawerOpen ? 0 : -drawerWidth,
                child: Container(
                  width: drawerWidth,
                  color: Colors.white,
                  child: SafeArea(
                    child: Column(
                      children: [
                        UserAccountsDrawerHeader(
                          accountName: Text(userName),
                          accountEmail: Text(userEmail),
                          currentAccountPicture: CircleAvatar(
                            backgroundColor: Colors.indigo,
                            child: Icon(Icons.person, color: Colors.white, size: 30),
                          ),
                          decoration: BoxDecoration(color: Colors.blueGrey[800]),
                        ),
                        _drawerButton(Icons.bar_chart, 'Status', '/status'),
                        if (isAPayingUser || isAdmin)
                          _drawerButton(Icons.storage, 'Deploy', '/deploy'),
                        _drawerButton(Icons.account_circle, 'User', '/profile'),
                        _drawerButton(Icons.money, 'Billing', '/paid'),
                        if (isAdmin)
                          _drawerButton(Icons.admin_panel_settings, 'Admin', '/admin'),
                        Divider(),
                        SwitchListTile(
                          value: themeNotifier.value == ThemeMode.dark,
                          onChanged: (val) {
                            themeNotifier.value =
                            val ? ThemeMode.dark : ThemeMode.light;
                          },
                          title: Text('Dark Mode'),
                          secondary: Icon(Icons.brightness_6),
                        ),
                        Divider(),
                        _drawerButton(Icons.logout, 'Logout', '/login', isLogout: true),
                      ],
                    ),
                  ),
                ),
              ),

              if (_isDrawerOpen)
                Positioned.fill(
                  left: drawerWidth,
                  child: GestureDetector(
                    onTap: _toggleDrawer,
                    child: Container(color: Colors.black.withAlpha((0.3 * 255).round()))
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerButton(IconData icon, String label, String route, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.redAccent : Colors.indigo),
      title: Text(
        label,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        setState(() => _isDrawerOpen = false);
        Future.delayed(Duration(milliseconds: 300), () async {
          if (isLogout) {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Confirm Logout'),
                content: Text('Are you sure you want to log out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Logout'),
                  ),
                ],
              ),
            );

            if (!mounted) return;

            if (confirm == true) {
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(child: CircularProgressIndicator()),
              );

              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              await Future.delayed(Duration(milliseconds: 500));

              if (!mounted) return; // ✨

              Navigator.of(context).pop();

              if (!mounted) return; // ✨

              Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);

            }
          } else {
            _navigateWithTransition(route);
          }
        });
      },
    );
  }
}
