import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    loadUserRole();
  }

  Future<void> loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? 'user';
    setState(() {
      isAdmin = role.toLowerCase() == 'admin';
      isAPayingUser = role.toLowerCase() == 'kunne';
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _handleSwipe,
      child: Scaffold(
        body: Stack(
          children: [
            // Main content with custom AppBar
            SafeArea(
              child: Column(
                children: [
                  // Custom AppBar
                  Container(
                    color: Colors.blueGrey[800],
                    height: 60,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.menu, color: Colors.white),
                          onPressed: _toggleDrawer,
                        ),
                        Text(
                          'Deploy-It',
                          style: TextStyle(color: Colors.white, fontSize: 20),
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
                      _drawerButton(Icons.bar_chart, 'Status', '/status'),
                      if(isAPayingUser || isAdmin)
                        _drawerButton(Icons.storage, 'Deploy', '/deploy'),
                      _drawerButton(Icons.account_circle, 'User', '/profile'),
                      _drawerButton(Icons.money, 'Billing', '/paid'),
                      if (isAdmin)
                        _drawerButton(Icons.admin_panel_settings, 'Admin', '/admin'),
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
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),
              ),
          ],
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
        Future.delayed(Duration(milliseconds: 300), () {
          Navigator.pushReplacementNamed(context, route);
        });
      },
    );
  }
}
