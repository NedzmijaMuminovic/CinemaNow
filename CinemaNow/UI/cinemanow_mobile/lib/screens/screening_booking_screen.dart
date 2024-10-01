import 'package:cinemanow_mobile/models/screening.dart';
import 'package:cinemanow_mobile/models/DTOs/seat_dto.dart';
import 'package:cinemanow_mobile/providers/movie_provider.dart';
import 'package:cinemanow_mobile/screens/screening_checkout_screen.dart';
import 'package:cinemanow_mobile/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinemanow_mobile/providers/screening_provider.dart';

class ScreeningBookingScreen extends StatefulWidget {
  final int movieId;
  final int screeningId;

  const ScreeningBookingScreen({
    super.key,
    required this.movieId,
    required this.screeningId,
  });

  @override
  _ScreeningBookingScreenState createState() => _ScreeningBookingScreenState();
}

class _ScreeningBookingScreenState extends State<ScreeningBookingScreen> {
  List<SeatDto> seats = [];
  List<SeatDto> selectedSeats = [];
  bool isLoading = true;
  String movieTitle = 'Loading...';
  String? errorMessage;
  Screening? screeningDetails;

  @override
  void initState() {
    super.initState();
    _fetchMovieTitle();
    _loadSeats();
  }

  Future<void> _loadSeats() async {
    final screeningProvider =
        Provider.of<ScreeningProvider>(context, listen: false);
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      final result =
          await screeningProvider.getSeatsForScreening(widget.screeningId);
      final screening =
          await screeningProvider.getScreeningById(widget.screeningId);
      setState(() {
        seats = result;
        screeningDetails = screening;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load seats. Please try again. Error: $e';
      });
    }
  }

  Future<void> _fetchMovieTitle() async {
    try {
      final movieProvider = context.read<MovieProvider>();
      final movie = await movieProvider.getById(widget.movieId);
      setState(() {
        movieTitle = movie.title ?? 'Movie Booking';
      });
    } catch (e) {
      setState(() {
        movieTitle = 'Movie Booking';
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.red,
            ))
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildSeatSelector(),
                      const SizedBox(height: 20),
                      buildButton(
                        text: 'Checkout',
                        onPressed: () {
                          if (selectedSeats.isNotEmpty &&
                              screeningDetails != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScreeningCheckoutScreen(
                                  selectedSeats: selectedSeats,
                                  movieTitle: movieTitle,
                                  screening: screeningDetails!,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please select at least one seat to proceed.'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildScreenIndicator() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          width: double.infinity,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[600],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              'Screen',
              style:
                  TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeatSelector() {
    return Column(
      children: [
        const Text(
          'Select Seats',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildScreenIndicator(),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: seats.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final seat = seats[index];
            final seatName = seat.name;

            Color seatColor;
            if (seat.isReserved!) {
              seatColor = Colors.blueAccent;
            } else if (selectedSeats.contains(seat)) {
              seatColor = Colors.red;
            } else {
              seatColor = Colors.transparent;
            }

            return GestureDetector(
              onTap: seat.isReserved!
                  ? null
                  : () {
                      setState(() {
                        if (selectedSeats.contains(seat)) {
                          selectedSeats.remove(seat);
                        } else {
                          selectedSeats.add(seat);
                        }
                      });
                    },
              child: Container(
                decoration: BoxDecoration(
                  color: seatColor,
                  border: Border.all(
                    color: Colors.red,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    seatName!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegend(color: Colors.red, text: 'Selected'),
            _buildLegend(color: Colors.blueAccent, text: 'Reserved'),
            _buildLegend(color: Colors.transparent, text: 'Available'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: Colors.red,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
