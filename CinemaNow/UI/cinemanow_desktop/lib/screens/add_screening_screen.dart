import 'package:cinemanow_desktop/layouts/master_screen.dart';
import 'package:cinemanow_desktop/models/hall.dart';
import 'package:cinemanow_desktop/models/movie.dart';
import 'package:cinemanow_desktop/models/view_mode.dart';
import 'package:cinemanow_desktop/providers/hall_provider.dart';
import 'package:cinemanow_desktop/providers/movie_provider.dart';
import 'package:cinemanow_desktop/providers/screening_provider.dart';
import 'package:cinemanow_desktop/providers/view_mode_provider.dart';
import 'package:cinemanow_desktop/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddScreeningScreen extends StatefulWidget {
  final VoidCallback? onScreeningAdded;

  const AddScreeningScreen({super.key, this.onScreeningAdded});

  @override
  _AddScreeningScreenState createState() => _AddScreeningScreenState();
}

class _AddScreeningScreenState extends State<AddScreeningScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  List<Movie> _movies = [];
  List<Hall> _halls = [];
  List<ViewMode> _viewModes = [];
  Movie? _selectedMovie;
  Hall? _selectedHall;
  ViewMode? _selectedViewMode;

  @override
  void initState() {
    super.initState();
    _fetchData();
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

  Future<void> _uploadScreening() async {
    if (_selectedMovie == null ||
        _selectedHall == null ||
        _selectedViewMode == null) {
      print('Error: Missing selected values');
      return;
    }

    try {
      final dateFormat = DateFormat.yMd();
      final timeFormat = DateFormat.Hm();

      final date = dateFormat.parse(_dateController.text);
      final time = timeFormat.parse(_timeController.text);

      final dateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);

      if (_dateController.text.isNotEmpty &&
          _timeController.text.isNotEmpty &&
          _priceController.text.isNotEmpty) {
        final screeningProvider =
            Provider.of<ScreeningProvider>(context, listen: false);
        final newScreening = {
          'movieId': _selectedMovie!.id,
          'hallId': _selectedHall!.id,
          'viewModeId': _selectedViewMode!.id,
          'date': dateTime.toIso8601String(),
          'price': double.parse(_priceController.text),
        };

        await screeningProvider.insert(newScreening);
        if (widget.onScreeningAdded != null) {
          widget.onScreeningAdded!();
        }
        Navigator.of(context).pop();
      } else {
        print('Error: Missing required fields');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: buildDarkTheme(context),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat.yMd().format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: buildDarkTheme(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.red,
              onPrimary: Colors.white,
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add a New Screening',
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
                buildDateField(
                    context, 'Date', 'Select a date', Icons.calendar_today),
                buildTimeField(
                    context, 'Time', 'Select a time', Icons.access_time),
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
                        onPressed: _uploadScreening,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32.0, vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text('Upload',
                            style: TextStyle(color: Colors.white)),
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

  Widget buildInputField(
      BuildContext context, String label, String placeholder, IconData icon,
      {TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                hintText: placeholder,
                hintStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(icon, color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDateField(
      BuildContext context, String label, String placeholder, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _dateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                hintText: placeholder,
                hintStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(icon, color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTimeField(
      BuildContext context, String label, String placeholder, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _timeController,
              readOnly: true,
              onTap: () => _selectTime(context),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                hintText: placeholder,
                hintStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(icon, color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildDropdown<T>({
  required String label,
  required T? selectedValue,
  required List<T> items,
  required String Function(T) displayValue,
  required void Function(T?) onChanged,
  required IconData icon,
  String? placeholder,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<T>(
            value: selectedValue,
            items: items.map((T value) {
              return DropdownMenuItem<T>(
                value: value,
                child: Text(displayValue(value)),
              );
            }).toList(),
            onChanged: onChanged,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[800],
              hintText: placeholder,
              hintStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              prefixIcon: Icon(icon, color: Colors.white),
            ),
            style: const TextStyle(color: Colors.white),
            dropdownColor: Colors.grey[800],
            iconEnabledColor: Colors.white,
            icon: Icon(Icons.arrow_drop_down, color: Colors.white),
            alignment: Alignment.centerLeft,
          ),
        ),
      ],
    ),
  );
}
