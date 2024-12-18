import 'package:cinemanow_desktop/providers/screening_provider.dart';
import 'package:cinemanow_desktop/screens/add_edit_screening_screen.dart';
import 'package:cinemanow_desktop/screens/screening_reservations_screen.dart';
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
  final Function(int) onScreeningUpdated;
  final String stateMachine;

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
    required this.stateMachine,
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
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    List<Widget> actions = [];

    if (stateMachine == 'active') {
      actions.add(
        Column(
          children: [
            Container(
              width: 300,
              height: 40,
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ScreeningReservationsScreen(
                        movieTitle: title,
                        screeningId: screeningId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: Colors.amber,
                      width: 1.5,
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.movie,
                      color: Colors.amber,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'View Reservations',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 120,
              child: _buildButton(
                  context: context,
                  label: 'Hide',
                  icon: Icons.visibility_off,
                  color: Colors.orange[700]!,
                  onPressed: () async {
                    final shouldHide = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            'Confirm Hide',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            'Are you sure you want to hide this screening?',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.grey[900],
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('No',
                                  style: TextStyle(color: Colors.red)),
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

                    if (shouldHide == true) {
                      try {
                        final provider = Provider.of<ScreeningProvider>(context,
                            listen: false);
                        await provider.hideScreening(screeningId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Screening successfully hidden!')),
                        );
                        onScreeningUpdated(1);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to hide screening')),
                        );
                      }
                    }
                  }),
            ),
          ],
        ),
      );
    } else if (stateMachine == 'hidden' || stateMachine == 'draft') {
      actions.add(SizedBox(
        width: 120,
        child: _buildButton(
            context: context,
            label: 'Activate',
            icon: Icons.visibility,
            color: Colors.green[800]!,
            onPressed: () async {
              final shouldActivate = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      'Confirm Activation',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'Are you sure you want to activate this screening?',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.grey[900],
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No',
                            style: TextStyle(color: Colors.red)),
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

              if (shouldActivate == true) {
                try {
                  final provider =
                      Provider.of<ScreeningProvider>(context, listen: false);
                  await provider.activateScreening(screeningId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Screening successfully activated!')),
                  );
                  onScreeningUpdated(0);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Failed to activate screening')),
                  );
                }
              }
            }),
      ));

      if (stateMachine == 'draft') {
        actions.add(_buildButton(
            context: context,
            label: 'Hide',
            icon: Icons.visibility_off,
            color: Colors.orange[700]!,
            onPressed: () async {
              final shouldHide = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      'Confirm Hide',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'Are you sure you want to hide this screening?',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.grey[900],
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No',
                            style: TextStyle(color: Colors.red)),
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

              if (shouldHide == true) {
                try {
                  final provider =
                      Provider.of<ScreeningProvider>(context, listen: false);
                  await provider.hideScreening(screeningId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Screening successfully hidden!')),
                  );
                  onScreeningUpdated(1);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to hide screening')),
                  );
                }
              }
            }));
      }
    }

    if (stateMachine != 'active') {
      actions.add(_buildButton(
        context: context,
        label: 'Edit',
        icon: Icons.edit,
        color: Colors.grey[700]!,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditScreeningScreen(
                screeningId: screeningId,
                onScreeningUpdated: () {
                  if (stateMachine == 'draft') {
                    onScreeningUpdated(2);
                  } else if (stateMachine == 'hidden') {
                    onScreeningUpdated(1);
                  } else {
                    onScreeningUpdated(0);
                  }
                },
              ),
            ),
          );
        },
      ));
      actions.add(_buildButton(
        context: context,
        label: 'Delete',
        icon: Icons.delete,
        color: Colors.red,
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
                    child:
                        const Text('Yes', style: TextStyle(color: Colors.red)),
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
      ));
    }

    return actions;
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
      ),
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        overflow: TextOverflow.ellipsis,
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.red, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
