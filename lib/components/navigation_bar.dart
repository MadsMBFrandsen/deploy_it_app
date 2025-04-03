import 'package:flutter/material.dart';

class NavigationBarCustom extends StatefulWidget {
  final Widget body;

  const NavigationBarCustom({super.key, required this.body});

  @override
  State<NavigationBarCustom> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBarCustom> {
  bool _isDrawerOpen = false;
  final double drawerWidth = 250;

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

            // Custom drawer
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
                      ListTile(
                        leading: Icon(Icons.bar_chart, color: Colors.indigo),
                        title: Text('Status', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        onTap: () {
                          setState(() => _isDrawerOpen = false);
                          Future.delayed(Duration(milliseconds: 300), () {
                            Navigator.pushReplacementNamed(context, '/status');
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.storage, color: Colors.teal),
                        title: Text('Deploy', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        onTap: () {
                           setState(() => _isDrawerOpen = false);
                           Future.delayed(Duration(milliseconds: 300), () {
                             Navigator.pushReplacementNamed(context, '/deploy');
                           });
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.account_circle, color: Colors.deepPurple),
                        title: Text('User', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        onTap: () {
                          setState(() => _isDrawerOpen = false);
                          Future.delayed(Duration(milliseconds: 300), () {
                            Navigator.pushReplacementNamed(context, '/profile');
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 32.0),
                        child: ListTile(
                          leading: Icon(Icons.money, color: Colors.green),
                          title: Text('Billing', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          onTap: () {
                            setState(() => _isDrawerOpen = false);
                            Future.delayed(Duration(milliseconds: 300), () {
                              Navigator.pushReplacementNamed(context, '/paid');
                            });
                          },
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.admin_panel_settings, color: Colors.amber),
                        title: Text('Admin', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        onTap: () {
                          setState(() => _isDrawerOpen = false);
                          Future.delayed(Duration(milliseconds: 300), () {
                            Navigator.pushReplacementNamed(context, '/admin');
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.redAccent),
                        title: Text('Logout', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        onTap: () {
                          setState(() => _isDrawerOpen = false);
                          Future.delayed(Duration(milliseconds: 300), () {
                            Navigator.pushReplacementNamed(context, '/logout');
                          });
                        },
                      ),
                    ],

                  ),
                ),
              ),
            ),

            // Tap to close overlay
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
}
