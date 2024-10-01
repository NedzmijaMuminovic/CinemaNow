import 'dart:convert';
import 'package:cinemanow_mobile/models/DTOs/reservation_movie_dto.dart';
import 'package:cinemanow_mobile/providers/auth_provider.dart';
import 'package:cinemanow_mobile/screens/reservation_details_screen.dart';
import 'package:cinemanow_mobile/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cinemanow_mobile/providers/reservation_provider.dart';

class UserScreeningListScreen extends StatefulWidget {
  const UserScreeningListScreen({super.key});

  @override
  _UserScreeningListScreenState createState() =>
      _UserScreeningListScreenState();
}

class _UserScreeningListScreenState extends State<UserScreeningListScreen> {
  bool _isFutureSelected = true;
  List<ReservationMovieDto> _filteredReservations = [];

  @override
  Widget build(BuildContext context) {
    final reservationProvider = Provider.of<ReservationProvider>(context);
    final userId = AuthProvider.userId;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [_isFutureSelected, !_isFutureSelected],
              onPressed: (int index) {
                setState(() {
                  _isFutureSelected = index == 0;
                });
              },
              color: Colors.white,
              selectedColor: Colors.white,
              fillColor: Colors.red,
              borderColor: Colors.red,
              selectedBorderColor: Colors.red,
              borderRadius: BorderRadius.circular(8),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Future',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Past',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<ReservationMovieDto>>(
                future: reservationProvider.getReservationsByUserId(userId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.red,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final reservations = snapshot.data ?? [];

                  _filteredReservations = reservations.where((reservation) {
                    final screeningDate = reservation.screeningDate.toLocal();
                    return _isFutureSelected
                        ? screeningDate.isAfter(DateTime.now())
                        : screeningDate.isBefore(DateTime.now());
                  }).toList();

                  if (_filteredReservations.isEmpty) {
                    return const NoScreeningsView(
                      title: 'No Reservations Found',
                      message: 'Try making some new reservations.',
                      icon: Icons.movie,
                    );
                  }

                  return ListView.builder(
                    itemCount: _filteredReservations.length,
                    itemBuilder: (context, index) {
                      final reservation = _filteredReservations[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child:
                            _buildMovieCard(reservation, reservationProvider),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieCard(ReservationMovieDto reservation,
      ReservationProvider reservationProvider) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReservationDetailsScreen(
                reservationId: reservation.reservationId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: reservation.movieImageBase64 != null &&
                      reservation.movieImageBase64!.isNotEmpty
                  ? Image.memory(
                      base64Decode(reservation.movieImageBase64!),
                      width: 120,
                      height: 180,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/default.jpg',
                      width: 120,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reservation.movieTitle ?? 'Unknown Title',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('MMM d, yyyy')
                            .format(reservation.screeningDate.toLocal()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        '${reservation.screeningDate.toLocal().hour.toString().padLeft(2, '0')}:${reservation.screeningDate.toLocal().minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (reservation.screeningDate
                      .toLocal()
                      .isAfter(DateTime.now()))
                    ElevatedButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                'Confirm Deletion',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'Are you sure you want to cancel this reservation?',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.grey[900],
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text(
                                    'No',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text(
                                    'Yes',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmed == true) {
                          await reservationProvider
                              .delete(reservation.reservationId);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'You have successfully cancelled your reservation.',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                          setState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 50),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
