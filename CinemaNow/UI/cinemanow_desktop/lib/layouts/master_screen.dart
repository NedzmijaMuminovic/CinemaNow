import 'package:flutter/material.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen(this.child, {super.key});
  final Widget child;

  @override
  State<MasterScreen> createState() => MasterScreenState();
}

class MasterScreenState extends State<MasterScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Text('Home'),
    Text('Movies'),
    Text('Reports'),
    Text('Admin'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(backgroundColor: Colors.grey[850]),
      drawer: Drawer(
        backgroundColor: Colors.grey[850],
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.grey[850],
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height: 200,
                width: 200,
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.home,
                color: Colors.white,
                size: 32,
              ),
              title: const Text('Home',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.movie,
                color: Colors.white,
                size: 32,
              ),
              title: const Text('Movies',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.bar_chart,
                color: Colors.white,
                size: 32,
              ),
              title: const Text('Reports',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.person,
                color: Colors.white,
                size: 32,
              ),
              title: const Text('Admin',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: widget.child,
    );
  }
}
