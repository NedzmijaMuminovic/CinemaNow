import 'package:cinemanow_desktop/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePicker extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;

  const DatePicker({
    super.key,
    this.selectedDate,
    required this.onDateSelected,
  });

  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime? _pickedDate;

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: buildDarkTheme(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: child!),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _pickedDate = null;
                    });
                    widget.onDateSelected(null);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Clear Date',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _pickedDate = pickedDate;
      });
      widget.onDateSelected(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _pickDate,
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text(
            widget.selectedDate != null
                ? DateFormat('dd/MM/yyyy').format(widget.selectedDate!)
                : 'Pick a Date',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
