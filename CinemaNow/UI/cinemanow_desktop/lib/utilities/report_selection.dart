import 'package:flutter/material.dart';

class ReportSelectionDialog extends StatefulWidget {
  final Function(Set<ReportType>) onConfirm;

  const ReportSelectionDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  State<ReportSelectionDialog> createState() => _ReportSelectionDialogState();
}

class _ReportSelectionDialogState extends State<ReportSelectionDialog> {
  final Set<ReportType> selectedReports = {};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 8.0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.assessment_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Select Reports to Export',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.grey[900],
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: ReportType.values.map((type) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      unselectedWidgetColor: Colors.grey[400],
                    ),
                    child: CheckboxListTile(
                      title: Text(
                        type.displayName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: selectedReports.contains(type)
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      value: selectedReports.contains(type),
                      activeColor: Colors.red.shade600,
                      checkColor: Colors.white,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedReports.add(type);
                          } else {
                            selectedReports.remove(type);
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16.0),
                  bottomRight: Radius.circular(16.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: selectedReports.isEmpty
                        ? null
                        : () {
                            widget.onConfirm(selectedReports);
                            Navigator.pop(context);
                          },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.file_download,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Export Selected',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ReportType {
  userCount,
  cinemaIncome,
  movieWatched,
  movieRevenue,
  topCustomers;

  String get displayName {
    switch (this) {
      case ReportType.userCount:
        return 'App Users';
      case ReportType.cinemaIncome:
        return 'Cinema Income';
      case ReportType.movieWatched:
        return 'Most Watched Movies';
      case ReportType.movieRevenue:
        return 'Movie Revenue';
      case ReportType.topCustomers:
        return 'Top Customers';
    }
  }
}
