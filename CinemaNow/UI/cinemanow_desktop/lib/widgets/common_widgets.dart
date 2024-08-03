import 'package:flutter/material.dart';

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

Widget buildDateTimeField(
    BuildContext context,
    String label,
    String placeholder,
    IconData icon,
    TextEditingController controller,
    VoidCallback onTap) {
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
            readOnly: true,
            onTap: onTap,
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
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              prefixIcon: Icon(icon, color: Colors.white),
            ),
            style: const TextStyle(color: Colors.white),
            dropdownColor: Colors.grey[800],
            iconEnabledColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            alignment: Alignment.centerLeft,
          ),
        ),
      ],
    ),
  );
}
