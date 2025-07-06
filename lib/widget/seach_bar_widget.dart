import 'package:flutter/material.dart';
import 'package:sevis_lakay/components/colors.dart';
import 'package:sevis_lakay/components/text_styles.dart';

class SeachBarWidget extends StatelessWidget {
  const SeachBarWidget({super.key, required this.sizeWidth});
  final int sizeWidth;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: sizeWidth.toDouble(),

      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 204, 212, 225)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          filled: true,
          fillColor: AppColors.primaryBlue.withOpacity(0.1),
          hintText: 'Search Businesses',
          hintStyle: TextStyle(
            color: AppTextStyles.subtitle.color,
            fontSize: 20,
            fontFamily: AppTextStyles.subtitle.fontFamily,
            fontWeight: AppTextStyles.subtitle.fontWeight,
          ),
        ),
      ),
    );
  }
}
