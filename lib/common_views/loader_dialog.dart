import 'package:flutter/material.dart';

// Function to show the loader dialog
void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: UnconstrainedBox(
            child: Container(
              width: 120,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: ThemeData().dialogBackgroundColor,
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 4),
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text("Loading...", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
