import 'package:flutter/material.dart';

/// Shows a dialog with a refresh button when there is no internet connection.
Future<void> showNoInternetDialog(
    BuildContext context, VoidCallback onRefresh) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('No Internet Connection',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content:
          const Text('Please check your internet connection and try again.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
          onPressed: () {
            Navigator.of(context).pop();
            onRefresh();
          },
        ),
      ],
    ),
  );
}
