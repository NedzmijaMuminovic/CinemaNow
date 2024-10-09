import 'package:cinemanow_mobile/providers/payment_provider.dart';
import 'package:cinemanow_mobile/models/screening.dart';
import 'package:cinemanow_mobile/models/DTOs/seat_dto.dart';
import 'package:cinemanow_mobile/providers/reservation_provider.dart';
import 'package:cinemanow_mobile/screens/reservation_qr_code.dart';
import 'package:cinemanow_mobile/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScreeningCheckoutScreen extends StatefulWidget {
  final List<SeatDto> selectedSeats;
  final String movieTitle;
  final Screening screening;

  const ScreeningCheckoutScreen({
    super.key,
    required this.selectedSeats,
    required this.movieTitle,
    required this.screening,
  });

  @override
  State<ScreeningCheckoutScreen> createState() =>
      _ScreeningCheckoutScreenState();
}

class _ScreeningCheckoutScreenState extends State<ScreeningCheckoutScreen> {
  String selectedPaymentMethod = 'Stripe';
  bool _isLoading = false;
  final PaymentProvider _paymentProvider = PaymentProvider();

  @override
  void initState() {
    super.initState();
  }

  int _getTotalAmountInCents() {
    final totalAmount =
        widget.selectedSeats.length * (widget.screening.price ?? 0);
    return (totalAmount * 100).toInt();
  }

  void _handlePayment() async {
    if (selectedPaymentMethod == 'Stripe') {
      setState(() {
        _isLoading = true;
      });

      try {
        final paymentIntentData = await _paymentProvider
            .createPaymentIntent(_getTotalAmountInCents());

        await _paymentProvider
            .initializePaymentSheet(paymentIntentData['clientSecret']);

        bool paymentSuccess = await _paymentProvider.presentPaymentSheet();

        if (!paymentSuccess) {
          setState(() {
            _isLoading = false;
          });
          return;
        }

        await _createReservation(
            paymentIntentData['clientSecret'].split('_secret').first);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      await _handleCashPayment();
    }
  }

  Future<void> _handleCashPayment() async {
    await _createReservation(null);
  }

  Future<void> _createReservation(String? stripePaymentIntentId) async {
    try {
      var reservationRequest = {
        "screeningId": widget.screening.id,
        "seatIds": widget.selectedSeats.map((seat) => seat.id).toList(),
        "stripePaymentIntentId": stripePaymentIntentId,
      };

      var reservationProvider = ReservationProvider();
      var createdReservation =
          await reservationProvider.insert(reservationRequest);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your reservation is confirmed!')),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              ReservationQRCodeScreen(reservationId: createdReservation.id!),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm reservation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.movieTitle,
          style: const TextStyle(color: Colors.white70),
        ),
        backgroundColor: Colors.grey[850],
      ),
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Booking Details'),
              const SizedBox(height: 10),
              _buildSelectedDetails(),
              const SizedBox(height: 20),
              _buildSectionTitle('Payment Method'),
              const SizedBox(height: 10),
              _buildPaymentMethodSelector(),
              const SizedBox(height: 20),
              _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                      color: Colors.red,
                    ))
                  : buildButton(
                      text: 'Pay',
                      onPressed: () async {
                        if (selectedPaymentMethod == 'Stripe') {
                          _handlePayment();
                        } else {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                  'Confirm Reservation',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: const Text(
                                  'Are you sure you want to proceed with the reservation?',
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
                            _handlePayment();
                          }
                        }
                      },
                    ),
            ],
          ),
        ),
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

  Widget _buildSelectedDetails() {
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
              DateFormat('MMMM d').format(widget.screening.dateTime!)),
          _buildDetailRow(Icons.access_time, 'Time:',
              DateFormat('HH:mm').format(widget.screening.dateTime!)),
          _buildDetailRow(
              Icons.location_on, 'Hall:', widget.screening.hall?.name ?? 'N/A'),
          _buildDetailRow(Icons.video_call, 'View Mode:',
              widget.screening.viewMode?.name ?? 'N/A'),
          _buildDetailRow(
            Icons.event_seat,
            'Seats:',
            widget.selectedSeats.map((seat) => seat.name).join(', '),
          ),
          _buildDetailRow(Icons.attach_money, 'Ticket Price:',
              '\$${widget.screening.price?.toStringAsFixed(2) ?? 'N/A'}'),
          _buildDetailRow(Icons.monetization_on, 'Total Price:',
              '\$${(widget.selectedSeats.length * (widget.screening.price ?? 0)).toStringAsFixed(2)}'),
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
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildPaymentOption('Stripe', Icons.credit_card),
          const Divider(color: Colors.grey, height: 1),
          _buildPaymentOption('Cash', Icons.attach_money),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String method, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(
        method,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: Radio<String>(
        value: method,
        groupValue: selectedPaymentMethod,
        onChanged: (String? value) {
          setState(() {
            selectedPaymentMethod = value!;
          });
        },
        activeColor: Colors.red,
      ),
      onTap: () {
        setState(() {
          selectedPaymentMethod = method;
        });
      },
    );
  }
}
