import 'package:flutter/material.dart';

Widget buildInputField(
    BuildContext context, String label, String placeholder, IconData icon,
    {TextEditingController? controller,
    bool readOnly = false,
    VoidCallback? onTap,
    MouseCursor? cursor}) {
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
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onTap,
              child: AbsorbPointer(
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
            ),
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

Widget buildButton({
  required String text,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    ),
  );
}

class NoScreeningsView extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const NoScreeningsView({
    super.key,
    this.title = 'No Screenings Available',
    this.message = 'Try selecting a different date or search term.',
    this.icon = Icons.movie,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
