import 'package:cinemanow_desktop/providers/genre_provider.dart';
import 'package:cinemanow_desktop/providers/hall_provider.dart';
import 'package:cinemanow_desktop/providers/seat_provider.dart';
import 'package:cinemanow_desktop/providers/view_mode_provider.dart';
import 'package:cinemanow_desktop/widgets/add_edit_dialog.dart';
import 'package:flutter/material.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  _ManagementScreenState createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  List<Map<String, dynamic>> genres = [];
  List<Map<String, dynamic>> viewModes = [];
  List<Map<String, dynamic>> halls = [];
  List<Map<String, dynamic>> seats = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      var genreProvider = GenreProvider();
      var genreResult = await genreProvider.getGenres();
      genres = genreResult.result
          .map((genre) => {'id': genre.id, 'name': genre.name!})
          .toList();

      var viewModeProvider = ViewModeProvider();
      var viewModeResult = await viewModeProvider.getViewModes();
      viewModes = viewModeResult.result
          .map((viewMode) => {'id': viewMode.id, 'name': viewMode.name!})
          .toList();

      var hallProvider = HallProvider();
      var hallResult = await hallProvider.getHalls();
      halls = hallResult.result
          .map((hall) => {'id': hall.id, 'name': hall.name!})
          .toList();

      var seatProvider = SeatProvider();
      var seatResult = await seatProvider.getSeats();
      seats = seatResult.result
          .map((seat) => {'id': seat.id, 'name': seat.name!})
          .toList();

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.red,
            ))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Genres', genres, Icons.movie, () {
                    _showAddDialog(context, 'Genre', (value) async {
                      var genreProvider = GenreProvider();
                      await genreProvider.insert({'name': value});
                      await _fetchData();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Genre successfully added!')));
                    });
                  }),
                  const SizedBox(height: 20),
                  _buildSection('View Modes', viewModes, Icons.video_call, () {
                    _showAddDialog(context, 'View Mode', (value) async {
                      var viewModeProvider = ViewModeProvider();
                      await viewModeProvider.insert({'name': value});
                      await _fetchData();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('View mode successfully added!')));
                    });
                  }),
                  const SizedBox(height: 20),
                  _buildSection('Halls', halls, Icons.location_on, () {
                    _showAddDialog(context, 'Hall', (value) async {
                      var hallProvider = HallProvider();
                      await hallProvider.insert({'name': value});
                      await _fetchData();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Hall successfully added!')));
                    });
                  }),
                  const SizedBox(height: 20),
                  _buildSection('Seats', seats, Icons.event_seat, () {
                    _showAddDialog(context, 'Seat', (value) async {
                      var seatProvider = SeatProvider();
                      await seatProvider.insert({'name': value});
                      await _fetchData();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Seat successfully added!')));
                    });
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> items,
      IconData icon, Function onAdd) {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon:
                      const Icon(Icons.add_circle_outline, color: Colors.white),
                  onPressed: () => onAdd(),
                ),
              ],
            ),
            const Divider(color: Colors.grey),
            SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.label, color: Colors.white),
                    title: Text(
                      items[index]['name'],
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () {
                            _showAddDialog(
                              context,
                              title.substring(0, title.length - 1),
                              (value) async {
                                switch (title) {
                                  case 'Genres':
                                    var genreProvider = GenreProvider();
                                    await genreProvider.update(
                                        items[index]['id'], {'name': value});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Genre successfully updated!')));
                                    break;
                                  case 'View Modes':
                                    var viewModeProvider = ViewModeProvider();
                                    await viewModeProvider.update(
                                        items[index]['id'], {'name': value});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'View mode successfully updated!')));
                                    break;
                                  case 'Halls':
                                    var hallProvider = HallProvider();
                                    await hallProvider.update(
                                        items[index]['id'], {'name': value});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Hall successfully updated!')));
                                    break;
                                  case 'Seats':
                                    var seatProvider = SeatProvider();
                                    await seatProvider.update(
                                        items[index]['id'], {'name': value});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Seat successfully updated!')));
                                    break;
                                }
                                await _fetchData();
                              },
                              initialValue: items[index]['name'],
                            );
                          },
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            bool? confirm = await _showConfirmationDialog(
                              context,
                              "Delete $title?",
                              "Are you sure you want to delete ${items[index]['name']}?",
                            );
                            if (confirm == true) {
                              switch (title) {
                                case 'Genres':
                                  var genreProvider = GenreProvider();
                                  await genreProvider
                                      .deleteGenre(items[index]['id']);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Genre successfully deleted!')));
                                  break;
                                case 'View Modes':
                                  var viewModeProvider = ViewModeProvider();
                                  await viewModeProvider
                                      .delete(viewModes[index]['id']);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'View mode successfully deleted!')));
                                  break;
                                case 'Halls':
                                  var hallProvider = HallProvider();
                                  await hallProvider.delete(halls[index]['id']);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Hall successfully deleted!')));
                                  break;
                                case 'Seats':
                                  var seatProvider = SeatProvider();
                                  await seatProvider.delete(seats[index]['id']);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Seat successfully deleted!')));
                                  break;
                              }
                              await _fetchData();
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog(
    BuildContext context,
    String title,
    Function(String) onSave, {
    String? initialValue,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AddEditDialog(
          title: title,
          onSave: onSave,
          initialValue: initialValue,
        );
      },
    );
  }

  Future<bool?> _showConfirmationDialog(
      BuildContext context, String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            content,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey[900],
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
