import 'package:cinemanow_mobile/providers/movie_provider.dart';
import 'package:cinemanow_mobile/screens/screening_checkout_screen.dart';
import 'package:cinemanow_mobile/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cinemanow_mobile/providers/screening_provider.dart';
import 'package:cinemanow_mobile/models/screening.dart';

class ScreeningBookingScreen extends StatefulWidget {
  final int movieId;

  const ScreeningBookingScreen({super.key, required this.movieId});

  @override
  _ScreeningBookingScreenState createState() => _ScreeningBookingScreenState();
}

class _ScreeningBookingScreenState extends State<ScreeningBookingScreen> {
  List<List<String>> seatLayout = [
    ['A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8'],
    ['B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8'],
    ['C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8'],
    ['D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7', 'D8'],
    ['E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8'],
    ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8'],
  ];

  List<String> selectedSeats = [];
  List<String> reservedSeats = ['B2', 'B3', 'C4', 'D5'];
  DateTime? selectedDate;
  String? selectedTime;
  List<Screening> screenings = [];
  bool isLoading = true;
  String movieTitle = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchMovieTitle();
    _loadScreenings();
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

  Future<void> _loadScreenings() async {
    final screeningProvider =
        Provider.of<ScreeningProvider>(context, listen: false);
    try {
      final result =
          await screeningProvider.getScreeningsByMovieId(widget.movieId);
      setState(() {
        screenings = result;
        if (screenings.isNotEmpty) {
          selectedDate = screenings.first.dateTime!.toLocal();
          var timesForSelectedDate = _getTimesForDate(selectedDate!);
          if (timesForSelectedDate.isNotEmpty) {
            selectedTime = timesForSelectedDate.first;
          }
        }
        isLoading = false;
      });
    } catch (e) {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  List<String> _getTimesForDate(DateTime date) {
    return screenings
        .where((s) =>
            s.dateTime!.toLocal().year == date.year &&
            s.dateTime!.toLocal().month == date.month &&
            s.dateTime!.toLocal().day == date.day)
        .map((s) => DateFormat('HH:mm').format(s.dateTime!.toLocal()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          movieTitle,
          style: const TextStyle(color: Colors.white70),
        ),
        backgroundColor: Colors.grey[850],
      ),
      backgroundColor: Colors.grey[900],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildSeatSelector(),
                  const SizedBox(height: 20),
                  _buildDateTimeSelector(),
                  const SizedBox(height: 20),
                  buildButton(
                    text: 'Checkout',
                    onPressed: () {
                      if (selectedSeats.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please select at least one seat before proceeding to checkout.'),
                          ),
                        );
                      } else if (selectedDate == null || selectedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please select a date and time before proceeding to checkout.'),
                          ),
                        );
                      } else {
                        final selectedScreening = screenings.firstWhere(
                          (s) =>
                              s.dateTime!.toLocal().year ==
                                  selectedDate!.year &&
                              s.dateTime!.toLocal().month ==
                                  selectedDate!.month &&
                              s.dateTime!.toLocal().day == selectedDate!.day &&
                              DateFormat('HH:mm')
                                      .format(s.dateTime!.toLocal()) ==
                                  selectedTime,
                          orElse: () =>
                              throw Exception('No matching screening found'),
                        );

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ScreeningCheckoutScreen(
                              selectedSeats: selectedSeats,
                              movieTitle: movieTitle,
                              selectedDate: selectedDate,
                              selectedTime: selectedTime,
                              screening: selectedScreening,
                            ),
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

  Widget _buildDateTimeSelector() {
    if (selectedDate == null || screenings.isEmpty) {
      return const Text(
        'No screenings available for this movie',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      );
    }

    final dates = screenings
        .map((s) =>
            DateTime(s.dateTime!.year, s.dateTime!.month, s.dateTime!.day))
        .toSet()
        .toList()
      ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Select Date',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: dates.map((date) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = date;
                    var timesForSelectedDate = _getTimesForDate(date);
                    selectedTime = timesForSelectedDate.isNotEmpty
                        ? timesForSelectedDate.first
                        : null;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: selectedDate?.year == date.year &&
                            selectedDate?.month == date.month &&
                            selectedDate?.day == date.day
                        ? Colors.red
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    DateFormat('MMM d').format(date),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Select Time',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (selectedDate != null && _getTimesForDate(selectedDate!).isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _getTimesForDate(selectedDate!).map((time) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTime = time;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: selectedTime == time ? Colors.red : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      time,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }).toList(),
            ),
          )
        else
          const Text(
            'No times available for this date',
            style: TextStyle(color: Colors.white),
          ),
      ],
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
          itemCount: seatLayout.fold(0, (sum, row) => sum! + row.length),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            int seatIndex = 0;
            String? seatId;

            for (var row in seatLayout) {
              if (index < seatIndex + row.length) {
                seatId = row[index - seatIndex];
                break;
              }
              seatIndex += row.length;
            }

            if (seatId == null) return Container();

            Color seatColor;
            if (reservedSeats.contains(seatId)) {
              seatColor = Colors.blueAccent;
            } else if (selectedSeats.contains(seatId)) {
              seatColor = Colors.red;
            } else {
              seatColor = Colors.transparent;
            }

            return GestureDetector(
              onTap: reservedSeats.contains(seatId)
                  ? null
                  : () {
                      setState(() {
                        if (selectedSeats.contains(seatId)) {
                          selectedSeats.remove(seatId);
                        } else {
                          selectedSeats.add(seatId!);
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
