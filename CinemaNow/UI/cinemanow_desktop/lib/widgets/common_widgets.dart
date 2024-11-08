import 'package:flutter/material.dart';

Widget buildInputField(
    BuildContext context, String label, String placeholder, IconData icon,
    {TextEditingController? controller,
    bool readOnly = false,
    VoidCallback? onTap,
    MouseCursor? cursor,
    String? errorMessage}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              child: MouseRegion(
                cursor: cursor ?? SystemMouseCursors.text,
                child: GestureDetector(
                  onTap: onTap,
                  child: AbsorbPointer(
                    absorbing: readOnly,
                    child: TextSelectionTheme(
                      data: const TextSelectionThemeData(
                        selectionColor: Colors.red,
                      ),
                      child: TextFormField(
                        controller: controller,
                        readOnly: readOnly,
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
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        cursorColor: Colors.red,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(left: 120, top: 4.0),
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
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
  VoidCallback onTap, {
  String? errorMessage,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onTap,
                  child: AbsorbPointer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
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
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: selectedValue,
                items: items.map((T value) {
                  return DropdownMenuItem<T>(
                    value: value,
                    child: Text(
                      displayValue(value),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                isExpanded: true,
                hint: Row(
                  children: [
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      placeholder ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                selectedItemBuilder: (BuildContext context) {
                  return items.map<Widget>((T value) {
                    return Row(
                      children: [
                        Icon(icon, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          displayValue(value),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
                dropdownColor: Colors.grey[800],
                iconEnabledColor: Colors.white,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
