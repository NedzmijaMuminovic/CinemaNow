import 'package:cinemanow_desktop/providers/reservation_provider.dart';
import 'package:cinemanow_desktop/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScreeningReservationsScreen extends StatefulWidget {
  final String movieTitle;
  final int screeningId;

  const ScreeningReservationsScreen({
    super.key,
    required this.movieTitle,
    required this.screeningId,
  });

  @override
  State<ScreeningReservationsScreen> createState() =>
      _ScreeningReservationsScreenState();
}

class _ScreeningReservationsScreenState
    extends State<ScreeningReservationsScreen> {
  List<Map<String, dynamic>> reservations = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    try {
      var reservationProvider = ReservationProvider();
      var fetchedReservations = await reservationProvider
          .getReservationsByScreeningId(widget.screeningId);
      setState(() {
        reservations = fetchedReservations.map((reservation) {
          return {
            'user': "${reservation.user?.name} ${reservation.user?.surname}",
            'reservationDate': reservation.dateTime!.toIso8601String(),
            'seats': reservation.seats!.map((seat) => seat.seat?.name).toList(),
            'ticketPrice': reservation.screening?.price ?? 0.0,
            'totalPrice': reservation.totalPrice,
            'paymentType': reservation.paymentType,
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load reservations: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.movieTitle,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.red,
            ))
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : _buildReservationsList(),
    );
  }

  Widget _buildReservationsList() {
    if (reservations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied,
              color: Colors.white70,
              size: 80,
            ),
            SizedBox(height: 24),
            Text(
              'No reservations available',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 24,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      reservation['user'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Reservation Date: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(reservation['reservationDate']))}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.event_seat, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Seats: ${reservation['seats'].join(', ')}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.payment, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Payment Type: ${reservation['paymentType']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.attach_money, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Ticket Price: \$${formatNumber(reservation['ticketPrice'])}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'Total Price: \$${formatNumber(reservation['totalPrice'])}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
