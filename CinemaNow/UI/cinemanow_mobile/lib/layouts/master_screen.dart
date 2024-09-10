import 'package:cinemanow_mobile/screens/actor_list_screen.dart';
import 'package:cinemanow_mobile/screens/movie_list_screen.dart';
import 'package:cinemanow_mobile/screens/screening_list_screen.dart';
import 'package:cinemanow_mobile/screens/user_profile_screen.dart';
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
