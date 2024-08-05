import 'package:cinemanow_desktop/layouts/master_screen.dart';
import 'package:cinemanow_desktop/models/hall.dart';
import 'package:cinemanow_desktop/models/movie.dart';
import 'package:cinemanow_desktop/models/view_mode.dart';
import 'package:cinemanow_desktop/providers/hall_provider.dart';
import 'package:cinemanow_desktop/providers/movie_provider.dart';
import 'package:cinemanow_desktop/providers/screening_provider.dart';
import 'package:cinemanow_desktop/providers/view_mode_provider.dart';
import 'package:cinemanow_desktop/theme/theme.dart';
import 'package:cinemanow_desktop/utilities/utils.dart';
import 'package:cinemanow_desktop/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditScreeningScreen extends StatefulWidget {
  final int screeningId;
  final VoidCallback? onScreeningUpdated;

  const EditScreeningScreen({
    super.key,
    required this.screeningId,
    this.onScreeningUpdated,
  });

  @override
  _EditScreeningScreenState createState() => _EditScreeningScreenState();
}

class _EditScreeningScreenState extends State<EditScreeningScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  List<Movie> _movies = [];
  List<Hall> _halls = [];
  List<ViewMode> _viewModes = [];
  Movie? _selectedMovie;
  Hall? _selectedHall;
  ViewMode? _selectedViewMode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDataAndDetails();
  }

  Future<void> _fetchDataAndDetails() async {
    await Future.wait([
      _fetchData(),
      _fetchScreeningDetails(),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchData() async {
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    final hallProvider = Provider.of<HallProvider>(context, listen: false);
    final viewModeProvider =
        Provider.of<ViewModeProvider>(context, listen: false);

    final movies = await movieProvider.get();
    final halls = await hallProvider.get();
    final viewModes = await viewModeProvider.get();

    setState(() {
      _movies = movies.result;
      _halls = halls.result;
      _viewModes = viewModes.result;
    });
  }

  Future<void> _fetchScreeningDetails() async {
    final screeningProvider =
        Provider.of<ScreeningProvider>(context, listen: false);

    final screening =
        await screeningProvider.getScreeningById(widget.screeningId);

    setState(() {
      _selectedMovie = screening.movie;
      _selectedHall = screening.hall;
      _selectedViewMode = screening.viewMode;
      _dateController.text =
          DateFormat('MM/dd/yyyy').format(screening.dateTime!);
      _timeController.text =
          TimeOfDay.fromDateTime(screening.dateTime!).format(context);
      _priceController.text = formatNumber(screening.price);
    });
  }

  Future<void> _updateScreening() async {
    if (_selectedMovie == null ||
        _selectedHall == null ||
        _selectedViewMode == null ||
        _dateController.text.isEmpty ||
        _timeController.text.isEmpty ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
      return;
    }

    try {
      final DateTime date =
          DateFormat('MM/dd/yyyy').parseStrict(_dateController.text);
      final TimeOfDay? time = parseTimeOfDay(_timeController.text);

      if (time == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid time format.'),
          ),
        );
        return;
      }

      final DateTime dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      if (_dateController.text.isNotEmpty &&
          _timeController.text.isNotEmpty &&
          _priceController.text.isNotEmpty) {
        final screeningProvider =
            Provider.of<ScreeningProvider>(context, listen: false);

        final priceText = _priceController.text.replaceAll(',', '.');
        final price = double.tryParse(priceText);

        if (price == null || price <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Price must be a positive number.'),
            ),
          );
          return;
        }

        await screeningProvider.updateScreening(
          widget.screeningId,
          _selectedMovie!,
          _selectedHall!,
          _selectedViewMode!,
          dateTime,
          price,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Screening successfully updated!'),
          ),
        );

        if (widget.onScreeningUpdated != null) {
          widget.onScreeningUpdated!();
        }
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update screening'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                    color: Colors.red,
                  ))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Screening',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      buildDropdown<Movie>(
                        label: 'Movie',
                        selectedValue: _selectedMovie,
                        items: _movies,
                        displayValue: (movie) => movie.title!,
                        onChanged: (movie) {
                          setState(() {
                            _selectedMovie = movie;
                          });
                        },
                        icon: Icons.movie,
                        placeholder: 'Select a movie',
                      ),
                      buildDateTimeField(
                        context,
                        'Date',
                        'Select a date',
                        Icons.calendar_today,
                        _dateController,
                        () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                            builder: (context, child) {
                              return Theme(
                                data: buildDarkTheme(context),
                                child: child!,
                              );
                            },
                          );

                          if (pickedDate != null) {
                            setState(() {
                              _dateController.text =
                                  DateFormat('MM/dd/yyyy').format(pickedDate);
                            });
                          }
                        },
                      ),
                      buildDateTimeField(
                        context,
                        'Time',
                        'Select a time',
                        Icons.access_time,
                        _timeController,
                        () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: buildDarkTheme(context),
                                child: child!,
                              );
                            },
                          );

                          if (pickedTime != null) {
                            setState(() {
                              _timeController.text = pickedTime.format(context);
                            });
                          }
                        },
                      ),
                      buildDropdown<Hall>(
                        label: 'Hall',
                        selectedValue: _selectedHall,
                        items: _halls,
                        displayValue: (hall) => hall.name!,
                        onChanged: (hall) {
                          setState(() {
                            _selectedHall = hall;
                          });
                        },
                        icon: Icons.location_on,
                        placeholder: 'Select a hall',
                      ),
                      buildDropdown<ViewMode>(
                        label: 'View Mode',
                        selectedValue: _selectedViewMode,
                        items: _viewModes,
                        displayValue: (viewMode) => viewMode.name!,
                        onChanged: (viewMode) {
                          setState(() {
                            _selectedViewMode = viewMode;
                          });
                        },
                        icon: Icons.video_call,
                        placeholder: 'Select view mode',
                      ),
                      buildInputField(
                          context, 'Price', 'Enter price', Icons.attach_money,
                          controller: _priceController),
                      const SizedBox(height: 20),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[850],
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0, vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                'Back',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _updateScreening,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0, vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                'Update',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
