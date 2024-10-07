import 'package:cinemanow_mobile/layouts/master_screen.dart';
import 'package:cinemanow_mobile/models/screening.dart';
import 'package:cinemanow_mobile/models/DTOs/seat_dto.dart';
import 'package:cinemanow_mobile/providers/reservation_provider.dart';
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
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _expiryDateController.addListener(() {
      String text = _expiryDateController.text;
      if (text.length == 2 && !text.contains('/')) {
        _expiryDateController.text = '$text/';
        _expiryDateController.selection = TextSelection.fromPosition(
          TextPosition(offset: _expiryDateController.text.length),
        );
      }
    });
  }

  bool _isStripeFormValid() {
    bool isCardNumberValid = RegExp(r'^[0-9]{13,19}$').hasMatch(
        _cardNumberController.text.replaceAll(RegExp(r'\s+\b|\b\s'), ''));

    bool isExpiryDateValid = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$')
        .hasMatch(_expiryDateController.text);

    bool isCvcValid = RegExp(r'^[0-9]{3}$').hasMatch(_cvcController.text);

    if (!isCardNumberValid) {
      _showValidationError('Invalid card number. Please enter 13-19 digits.');
      return false;
    }

    if (!isExpiryDateValid) {
      _showValidationError('Invalid expiry date. Please use MM/YY format.');
      return false;
    }

    if (!isCvcValid) {
      _showValidationError('Invalid CVC. Please enter 3 digits.');
      return false;
    }

    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handlePayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (selectedPaymentMethod == 'Stripe') {
      } else {
        await _handleCashPayment();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleCashPayment() async {
    await _createReservation(null);
  }

  Future<void> _createReservation(String? stripePaymentToken) async {
    try {
      var reservationRequest = {
        "screeningId": widget.screening.id,
        "seatIds": widget.selectedSeats.map((seat) => seat.id).toList(),
        "stripePaymentToken": stripePaymentToken,
      };

      var reservationProvider = ReservationProvider();
      await reservationProvider.insert(reservationRequest);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your reservation is confirmed!')),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MasterScreen()),
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
              if (selectedPaymentMethod == 'Stripe')
                _buildStripePaymentFields(),
              const SizedBox(height: 20),
              Center(
                child: buildButton(
                  text: 'Confirm Payment',
                  onPressed: () async {
                    if (selectedPaymentMethod == 'Stripe' &&
                        !_isStripeFormValid()) {
                      return;
                    }

                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                            'Confirm Payment',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            'Are you sure you want to proceed with the payment?',
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

                    if (confirmed == true) {
                      _handlePayment();
                    }
                  },
                ),
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
          _buildPaymentOption('Pay in Cash', Icons.attach_money),
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

  Widget _buildStripePaymentFields() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _cardNumberController,
            label: 'Card Number',
            icon: Icons.credit_card,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _expiryDateController,
                  label: 'MM/YY',
                  icon: Icons.date_range,
                  keyboardType: TextInputType.datetime,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _cvcController,
                  label: 'CVC',
                  icon: Icons.security,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.red),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
      cursorColor: Colors.red,
    );
  }
}
