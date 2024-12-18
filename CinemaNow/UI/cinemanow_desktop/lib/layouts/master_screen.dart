import 'package:cinemanow_desktop/screens/actor_list_screen.dart';
import 'package:cinemanow_desktop/screens/administrators_screen.dart';
import 'package:cinemanow_desktop/screens/management_screen.dart';
import 'package:cinemanow_desktop/screens/movie_list_screen.dart';
import 'package:cinemanow_desktop/screens/reports_screen.dart';
import 'package:cinemanow_desktop/screens/screening_list_screen.dart';
import 'package:cinemanow_desktop/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen(this.child, {super.key});
  final Widget child;

  @override
  State<MasterScreen> createState() => MasterScreenState();
}

class MasterScreenState extends State<MasterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        iconTheme: const IconThemeData(
          color: Colors.grey,
        ),
      ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MasterScreen(
                      Scaffold(
                        body: ScreeningListScreen(),
                      ),
                    ),
                  ),
                );
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MasterScreen(
                      Scaffold(
                        body: MovieListScreen(),
                      ),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.recent_actors,
                color: Colors.white,
                size: 32,
              ),
              title: const Text('Actors',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MasterScreen(
                      Scaffold(
                        body: ActorListScreen(),
                      ),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.list,
                color: Colors.white,
                size: 32,
              ),
              title: const Text('Management',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MasterScreen(
                      Scaffold(
                        body: ManagementScreen(),
                      ),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.supervisor_account,
                color: Colors.white,
                size: 32,
              ),
              title: const Text('Administrators',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MasterScreen(
                      Scaffold(
                        body: AdministratorsScreen(),
                      ),
                    ),
                  ),
                );
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MasterScreen(
                      Scaffold(
                        body: ReportsScreen(),
                      ),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.person,
                color: Colors.white,
                size: 32,
              ),
              title: const Text('Profile',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MasterScreen(
                      Scaffold(
                        body: UserProfileScreen(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: widget.child,
    );
  }
}
