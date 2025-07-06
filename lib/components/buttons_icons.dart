import 'package:flutter/material.dart';

class MyButtonIcons extends StatefulWidget {
  const MyButtonIcons({
    super.key,
    required this.borderColor,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.icons,
    required this.title,
  });

  final Color borderColor;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final IconData icons;
  final String title;

  @override
  State<MyButtonIcons> createState() => _MyButtonIconsState();
}

class _MyButtonIconsState extends State<MyButtonIcons> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 150,
      decoration: BoxDecoration(
        border: Border.all(color: widget.borderColor),
        borderRadius: BorderRadius.circular(10),
        color: widget.backgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icons, size: 20, color: widget.iconColor),
          SizedBox(width: 5),
          Text(
            widget.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: widget.textColor,
            ),
          ),
        ],
      ),
    );
  }
}
