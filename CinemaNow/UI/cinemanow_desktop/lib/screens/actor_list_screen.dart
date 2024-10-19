import 'package:cinemanow_desktop/models/actor.dart';
import 'package:cinemanow_desktop/models/search_result.dart';
import 'package:cinemanow_desktop/providers/actor_provider.dart';
import 'package:cinemanow_desktop/screens/add_edit_actor_screen.dart';
import 'package:cinemanow_desktop/widgets/actor_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActorListScreen extends StatefulWidget {
  const ActorListScreen({super.key});

  @override
  _ActorListScreenState createState() => _ActorListScreenState();
}

class _ActorListScreenState extends State<ActorListScreen> {
  late ActorProvider provider;
  SearchResult<Actor>? result;
  final TextEditingController _queryEditingController = TextEditingController();
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchActors();
  }

  @override
  void initState() {
    super.initState();
    _fetchActors();
  }

  Future<void> _fetchActors({String? query}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<ActorProvider>();
      result = await provider.getActors(query: query);
      setState(() {});
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSearch(),
                const SizedBox(height: 16),
                _isLoading
                    ? const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.red,
                          ),
                        ),
                      )
                    : _buildResultView(),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddEditActorScreen(
                      onActorAdded: _fetchActors,
                    ),
                  ),
                );
              },
              backgroundColor: Colors.grey[850],
              child: Icon(
                Icons.add,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Expanded(
                  child: TextSelectionTheme(
                    data: const TextSelectionThemeData(
                      selectionColor: Colors.red,
                    ),
                    child: TextField(
                      controller: _queryEditingController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                      ),
                      cursorColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () async {
            final query = _queryEditingController.text;
            await _fetchActors(query: query);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[850],
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            minimumSize: const Size(0, 55),
          ),
          child: Text(
            'Search',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    if (result == null || result!.result.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                'No Actors Available',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching for a different actor.',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount;
          if (constraints.maxWidth > 1200) {
            crossAxisCount = 3;
          } else if (constraints.maxWidth > 800) {
            crossAxisCount = 2;
          } else {
            crossAxisCount = 1;
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1,
            ),
            itemCount: result?.result.length,
            itemBuilder: (context, index) {
              String? imageUrl = result?.result[index].imageBase64;
              return ActorCard(
                imageUrl: imageUrl != null
                    ? 'data:image/jpeg;base64,$imageUrl'
                    : 'assets/images/default.jpg',
                name: result?.result[index].name ?? 'Unknown Name',
                surname: result?.result[index].surname ?? 'Unknown Surname',
                actorId: result?.result[index].id ?? 0,
                onDelete: _fetchActors,
                onActorUpdated: _fetchActors,
              );
            },
          );
        },
      ),
    );
  }
}
