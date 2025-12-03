import 'package:flutter/material.dart';

class CustomTileAction extends StatelessWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final EdgeInsets padding;

  const CustomTileAction({
    required this.onPressed,
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    required this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: padding,
        margin: const EdgeInsets.only(left: 16.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Icon(icon, color: iconColor),
      ),
    );
  }
}