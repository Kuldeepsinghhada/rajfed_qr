import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  Color? bgColor = Colors.green.shade400;
  CommonButton(
      {super.key, required this.text, required this.onPressed, this.bgColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor ?? Colors.green.shade400, // Button color
          foregroundColor: Colors.white, // Text color
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(4), // Common corners with radius 4
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
