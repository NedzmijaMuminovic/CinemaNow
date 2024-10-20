import 'dart:convert';
import 'package:cinemanow_mobile/layouts/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:cinemanow_mobile/providers/reservation_provider.dart';

class ReservationQRCodeScreen extends StatefulWidget {
  final int reservationId;

  const ReservationQRCodeScreen({super.key, required this.reservationId});

  @override
  _ReservationQRCodeScreenState createState() =>
      _ReservationQRCodeScreenState();
}

class _ReservationQRCodeScreenState extends State<ReservationQRCodeScreen> {
  final ReservationProvider _reservationProvider = ReservationProvider();
  late Future<String> _qrCodeFuture;

  @override
  void initState() {
    super.initState();
    _qrCodeFuture = _reservationProvider.getQRCode(widget.reservationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Movie Ticket',
          style: TextStyle(color: Colors.white70),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white70,
        ),
        backgroundColor: Colors.grey[850],
      ),
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: FutureBuilder<String>(
                future: _qrCodeFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.red));
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white));
                  } else if (snapshot.hasData) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 300,
                          child: Text(
                            'Thank you for purchasing your movie ticket with us. We hope you enjoy your movie experience.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Image.memory(
                          base64Decode(snapshot.data!),
                          width: 250,
                          height: 250,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Scan this QR code at the cinema.',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    );
                  } else {
                    return const Text('No QR code available',
                        style: TextStyle(color: Colors.white));
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const MasterScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Back to Home',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
