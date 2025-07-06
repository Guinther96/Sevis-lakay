import 'package:flutter/material.dart';

class ButtonsDouble extends StatelessWidget {
  const ButtonsDouble({
    super.key,
    required this.title,
    required this.color1,
    required this.color2,
    required this.color3,
  });
  final String title;
  final Color color1;
  final Color color2;
  final Color color3;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 320,
      decoration: BoxDecoration(
        color: color1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color2),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: color3,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
