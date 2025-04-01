import 'package:flutter/material.dart';

class NavigationBar extends StatefulWidget {
  final Widget body;

  const NavigationBar({super.key, required this.body});

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
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
                          'My App',
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
                color: Colors.blueGrey[900],
                child: SafeArea(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('Home', style: TextStyle(color: Colors.white)),
                        onTap: () {},
                      ),
                      ListTile(
                        title: Text('Settings', style: TextStyle(color: Colors.white)),
                        onTap: () {},
                      ),
                      ListTile(
                        title: Text('Logout', style: TextStyle(color: Colors.white)),
                        onTap: () {},
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
