import 'package:cinemanow_desktop/layouts/master_screen.dart';
import 'package:cinemanow_desktop/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddScreeningScreen extends StatefulWidget {
  const AddScreeningScreen({super.key});

  @override
  _AddScreeningScreenState createState() => _AddScreeningScreenState();
}

class _AddScreeningScreenState extends State<AddScreeningScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _hallController = TextEditingController();
  final TextEditingController _viewModeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

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
                buildInputField(
                    context, 'Movie', 'Select a movie', Icons.movie),
                buildDateField(
                    context, 'Date', 'Select a date', Icons.calendar_today),
                buildTimeField(
                    context, 'Time', 'Select a time', Icons.access_time),
                buildInputField(
                    context, 'Hall', 'Select a hall', Icons.location_on,
                    controller: _hallController),
                buildInputField(context, 'View Mode', 'Select a view mode',
                    Icons.video_call,
                    controller: _viewModeController),
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
                        onPressed: () {},
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
