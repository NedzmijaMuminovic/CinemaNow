import 'package:cinemanow_desktop/providers/screening_provider.dart';
import 'package:cinemanow_desktop/screens/add_edit_screening_screen.dart';
import 'package:cinemanow_desktop/widgets/base_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  final VoidCallback onScreeningUpdated;

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
    required this.onScreeningUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      imageUrl: imageUrl,
      content: [
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
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditScreeningScreen(
                  screeningId: screeningId,
                  onScreeningUpdated: onScreeningUpdated,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[700],
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          icon: const Icon(Icons.edit, color: Colors.white),
          label: const Text('Edit', style: TextStyle(color: Colors.white)),
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
                      child:
                          const Text('No', style: TextStyle(color: Colors.red)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Yes',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                );
              },
            );

            if (shouldDelete == true) {
              try {
                final provider =
                    Provider.of<ScreeningProvider>(context, listen: false);
                await provider.deleteScreening(screeningId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Screening successfully deleted!')),
                );
                onDelete();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete screening')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          icon: const Icon(Icons.delete, color: Colors.white),
          label: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
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
