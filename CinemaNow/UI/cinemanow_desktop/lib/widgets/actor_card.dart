import 'package:cinemanow_desktop/providers/actor_provider.dart';
import 'package:cinemanow_desktop/screens/add_edit_actor_screen.dart';
import 'package:cinemanow_desktop/widgets/base_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActorCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String surname;
  final int actorId;
  final VoidCallback onDelete;
  final VoidCallback onActorUpdated;

  const ActorCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.surname,
    required this.actorId,
    required this.onDelete,
    required this.onActorUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      imageUrl: imageUrl,
      imageHeight: 280,
      content: [
        Text(
          '$name $surname',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditActorScreen(
                  actorId: actorId,
                  onActorUpdated: onActorUpdated,
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
                    'Are you sure you want to delete this actor?',
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
                    Provider.of<ActorProvider>(context, listen: false);
                await provider.deleteActor(actorId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Actor successfully deleted!')),
                );
                onDelete();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete actor')),
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
