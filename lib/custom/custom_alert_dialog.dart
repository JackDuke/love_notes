import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onPressed;
  const CustomAlertDialog({
    required this.title,
    required this.message,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade900,
      title: Text(title, style: const TextStyle(color: Colors.white),),
      content: Text(message, style: const TextStyle(color: Colors.white)),
      actions: <Widget>[
        Container(
          decoration: BoxDecoration(
            // color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextButton(
            onPressed: () => Navigator.pop(context, 'No'),
            child: const Text('No', style: TextStyle(color: Colors.white)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            // color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextButton(
            onPressed: onPressed,
            child: const Text('Sì', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
