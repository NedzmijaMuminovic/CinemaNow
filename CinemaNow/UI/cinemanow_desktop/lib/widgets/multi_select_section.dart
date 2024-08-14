import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class MultiSelectSection<T> extends StatelessWidget {
  final List<T> allItems;
  final List<T> selectedItems;
  final String title;
  final String buttonText;
  final String labelText;
  final ValueChanged<List<T>> onConfirm;
  final String Function(T) itemLabel;
  final ValueChanged<T> onItemTap;

  const MultiSelectSection({
    super.key,
    required this.allItems,
    required this.selectedItems,
    required this.title,
    required this.buttonText,
    required this.labelText,
    required this.onConfirm,
    required this.itemLabel,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8.0),
              Text(
                labelText,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MultiSelectDialogField<T>(
                items: allItems
                    .map((item) => MultiSelectItem<T>(
                          item,
                          itemLabel(item),
                        ))
                    .toList(),
                initialValue: selectedItems,
                title: Text(
                  title,
                  style: const TextStyle(color: Colors.white),
                ),
                selectedColor: Colors.red,
                selectedItemsTextStyle: const TextStyle(color: Colors.white),
                backgroundColor: Colors.grey[850],
                buttonText: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                onConfirm: onConfirm,
                chipDisplay: MultiSelectChipDisplay(
                  chipColor: Colors.grey[800],
                  textStyle: const TextStyle(color: Colors.white),
                  items: selectedItems
                      .map((item) => MultiSelectItem<T>(item, itemLabel(item)))
                      .toList(),
                  onTap: onItemTap,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                itemsTextStyle: const TextStyle(color: Colors.white),
                listType: MultiSelectListType.LIST,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}
