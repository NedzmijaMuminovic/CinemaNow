import 'package:flutter/material.dart';

class AddEditDialog extends StatefulWidget {
  final String title;
  final Function(String) onSave;
  final String? initialValue;

  const AddEditDialog({
    super.key,
    required this.title,
    required this.onSave,
    this.initialValue,
  });

  @override
  _AddEditDialogState createState() => _AddEditDialogState();
}

class _AddEditDialogState extends State<AddEditDialog> {
  late TextEditingController _controller;
  String? _errorMessage;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? "");
    _controller.addListener(_validateInput);
    _errorMessage = null;
  }

  @override
  void dispose() {
    _controller.removeListener(_validateInput);
    _controller.dispose();
    super.dispose();
  }

  void _validateInput() {
    if (!_isDirty) return;

    String input = _controller.text.trim();
    setState(() {
      if (input.isEmpty) {
        _errorMessage = "Please fill in this field.";
        return;
      }

      switch (widget.title) {
        case 'Genre':
          if (!RegExp(r'^[A-Z][a-zA-Z]*$').hasMatch(input)) {
            _errorMessage =
                'Genre should start with a capital letter and contain only letters.';
          } else {
            _errorMessage = null;
          }
          break;
        case 'View Mode':
          if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(input)) {
            _errorMessage =
                'View Mode should contain only letters and numbers.';
          } else {
            _errorMessage = null;
          }
          break;
        case 'Hall':
          if (!RegExp(r'^Hall\s\d+$').hasMatch(input)) {
            _errorMessage =
                'Hall should be in the format "Hall 1", "Hall 2", etc.';
          } else {
            _errorMessage = null;
          }
          break;
        case 'Seat':
          if (!RegExp(r'^[A-H][1-8]$').hasMatch(input)) {
            _errorMessage = 'Seat should be in the format "A1" to "H8".';
          } else {
            _errorMessage = null;
          }
          break;
      }
    });
  }

  void _validateAndSave() {
    setState(() {
      _isDirty = true;
    });
    _validateInput();

    if (_errorMessage == null) {
      widget.onSave(_controller.text.trim());
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.grey[850],
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.initialValue == null
                      ? 'Add New ${widget.title}'
                      : 'Edit ${widget.title}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              onTap: () {
                setState(() {
                  _isDirty = true;
                });
              },
              decoration: InputDecoration(
                labelText: 'Enter ${widget.title} name',
                labelStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Colors.redAccent, width: 2),
                ),
                errorText: _isDirty ? _errorMessage : null,
                errorStyle: const TextStyle(color: Colors.redAccent),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    backgroundColor: Colors.grey[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _validateAndSave,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
