import 'package:cinemanow_mobile/providers/movie_provider.dart';
import 'package:flutter/material.dart';
import 'package:cinemanow_mobile/models/reservation.dart';
import 'package:cinemanow_mobile/providers/reservation_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReservationDetailsScreen extends StatefulWidget {
  final int reservationId;
  final ReservationProvider reservationProvider;

  ReservationDetailsScreen({
    super.key,
    required this.reservationId,
    ReservationProvider? provider,
  })  : reservationProvider = provider ?? ReservationProvider();

  @override
  _ReservationDetailsScreenState createState() =>
      _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailsScreen> {
  String movieTitle = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchMovieTitle();
  }

  Future<void> _fetchMovieTitle() async {
    try {
      final movieProvider = context.read<MovieProvider>();
      final reservation =
          await widget.reservationProvider.getById(widget.reservationId);
      final movie =
          await movieProvider.getById(reservation.screening?.movieId ?? 0);
      setState(() {
        movieTitle = movie.title ?? 'Movie Details';
      });
    } catch (e) {
      setState(() {
        movieTitle = 'Movie Details';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          movieTitle,
          style: const TextStyle(color: Colors.white70),
        ),
        backgroundColor: Colors.grey[850],
      ),
      body: FutureBuilder<Reservation>(
        future: widget.reservationProvider.getById(widget.reservationId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No reservation found'));
          }

          final reservation = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Screening Details'),
                  const SizedBox(height: 10),
                  _buildScreeningDetails(reservation),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Reservation Details'),
                  const SizedBox(height: 10),
                  _buildReservationDetails(reservation),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildReservationDetails(Reservation reservation) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(Icons.calendar_today, 'Date:',
              DateFormat('MMM d, yyyy').format(reservation.dateTime!)),
          _buildDetailRow(Icons.access_time, 'Time:',
              DateFormat('HH:mm').format(reservation.dateTime!)),
          _buildDetailRow(
              Icons.event_seat,
              'Seats:',
              reservation.seats
                      ?.map((reservationSeat) => reservationSeat.seat?.name)
                      .where((name) => name != null)
                      .join(', ') ??
                  'N/A'),
          _buildDetailRow(
            Icons.monetization_on,
            'Total Price:',
            '\$${reservation.totalPrice?.toStringAsFixed(2) ?? 'N/A'}',
          ),
        ],
      ),
    );
  }

  Widget _buildScreeningDetails(Reservation reservation) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
              Icons.calendar_today,
              'Date:',
              DateFormat('MMM d, yyyy')
                  .format(reservation.screening?.dateTime ?? DateTime.now())),
          _buildDetailRow(
              Icons.access_time,
              'Time:',
              DateFormat('HH:mm')
                  .format(reservation.screening?.dateTime ?? DateTime.now())),
          _buildDetailRow(Icons.location_on, 'Hall:',
              reservation.screening?.hall?.name ?? 'N/A'),
          _buildDetailRow(Icons.video_call, 'View Mode:',
              reservation.screening?.viewMode?.name ?? 'N/A'),
          _buildDetailRow(
            Icons.attach_money,
            'Ticket Price:',
            '\$${reservation.screening?.price?.toStringAsFixed(2) ?? 'N/A'}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
