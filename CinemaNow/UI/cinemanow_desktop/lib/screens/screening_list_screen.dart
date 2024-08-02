import 'dart:convert';

import 'package:cinemanow_desktop/models/screening.dart';
import 'package:cinemanow_desktop/models/search_result.dart';
import 'package:cinemanow_desktop/providers/screening_provider.dart';
import 'package:cinemanow_desktop/widgets/date_picker.dart';
import 'package:cinemanow_desktop/screens/add_screening_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ScreeningListScreen extends StatefulWidget {
  const ScreeningListScreen({super.key});

  @override
  _ScreeningListScreenState createState() => _ScreeningListScreenState();
}

class _ScreeningListScreenState extends State<ScreeningListScreen> {
  late ScreeningProvider provider;
  SearchResult<Screening>? result;
  final TextEditingController _ftsEditingController = TextEditingController();
  DateTime? _selectedDate;
  bool _noScreeningsAvailable = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchScreenings();
  }

  @override
  void initState() {
    super.initState();
    _fetchScreenings();
  }

  Future<void> _fetchScreenings({dynamic filter}) async {
    try {
      final provider = context.read<ScreeningProvider>();
      result = await provider.getScreenings(filter: filter);
      setState(() {
        _noScreeningsAvailable = result?.result.isEmpty ?? true;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearch(),
            const SizedBox(height: 16),
            _buildResultView(),
          ],
        ),
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
                  child: TextField(
                    controller: _ftsEditingController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: DatePicker(
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () async {
            var filter = {
              'fts': _ftsEditingController.text,
            };

            if (_selectedDate != null) {
              filter['date'] = DateFormat('yyyy-MM-dd').format(_selectedDate!);
            }

            await _fetchScreenings(filter: filter);
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
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddScreeningScreen(),
              ),
            );
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
            'Add',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    if (_noScreeningsAvailable) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              'No Screenings Available',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different date or search term.',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount;
          if (constraints.maxWidth > 1200) {
            crossAxisCount = 3;
          } else if (constraints.maxWidth > 900) {
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
              String? imageUrl = result?.result[index].movie?.imageBase64;
              return ScreeningCard(
                imageUrl: imageUrl != null
                    ? 'data:image/jpeg;base64,$imageUrl'
                    : 'assets/images/default.jpg',
                title: result?.result[index].movie?.title ?? 'Unknown Title',
                date: result?.result[index].date != null
                    ? DateFormat('dd/MM/yyyy')
                        .format(result!.result[index].date!)
                    : 'Unknown Date',
                time: result?.result[index].time != null
                    ? DateFormat('HH:mm').format(
                        DateFormat('HH:mm').parse(result!.result[index].time!))
                    : 'Unknown Time',
                hall: result?.result[index].hall?.name ?? 'Unknown Hall',
                viewMode:
                    result?.result[index].viewMode?.name ?? 'Unknown View Mode',
                price: result?.result[index].price != null
                    ? result!.result[index].price.toString()
                    : 'Unknown Price',
                screeningId: result?.result[index].id ?? 0,
                onDelete: _fetchScreenings,
              );
            },
          );
        },
      ),
    );
  }
}

class ScreeningCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String date;
  final String time;
  final String hall;
  final String viewMode;
  final String price;
  final int screeningId;
  final VoidCallback onDelete;

  const ScreeningCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.time,
    required this.hall,
    required this.viewMode,
    required this.price,
    required this.screeningId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16.0)),
            child: imageUrl.startsWith('data:image')
                ? Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image:
                            MemoryImage(base64Decode(imageUrl.split(',').last)),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  )
                : Image.asset(
                    imageUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InfoRow(icon: Icons.calendar_today, text: date),
                          InfoRow(icon: Icons.access_time, text: time),
                          InfoRow(icon: Icons.location_on, text: hall),
                          InfoRow(icon: Icons.video_call, text: viewMode),
                          InfoRow(icon: Icons.attach_money, text: price),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16.0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label:
                      const Text('Edit', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            'Confirm Deletion',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            'Are you sure you want to delete this screening?',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.grey[900],
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text(
                                'No',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                'Yes',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    if (shouldDelete == true) {
                      try {
                        final provider = Provider.of<ScreeningProvider>(context,
                            listen: false);
                        await provider.deleteScreening(screeningId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Screening successfully deleted!')),
                        );
                        onDelete();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to delete screening'),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text('Delete',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.red, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
