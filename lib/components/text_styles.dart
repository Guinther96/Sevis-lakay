import 'package:flutter/material.dart';
import 'package:sevis_lakay/components/colors.dart';

class AppTextStyles {
  static const TextStyle pageName = TextStyle(
    color: Colors.black87,
    fontFamily: 'Inter',
    fontWeight: FontWeight.bold,
    fontSize: 24,
  );

  static const TextStyle title = TextStyle(
    color: Colors.black87,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.bold,
    fontSize: 32,
  );
  static const TextStyle titleItem = TextStyle(
    color: Colors.black87,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.bold,
    fontSize: 15,
  );
  static const TextStyle titleName = TextStyle(
    fontFamily: 'Roboto',
    color: Colors.black87,
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );
  static const TextStyle TextButton = TextStyle(
    fontFamily: 'Roboto',
    color: AppColors.primaryBlue,
    fontWeight: FontWeight.bold,
    fontSize: 15,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400, // Regular weight
    color: Colors.grey,
    fontSize: 16,
  );

  static const TextStyle textCategories = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600, // Semi-bold weight
    color: Colors.grey,
    fontSize: 24,
  );

  static const TextStyle categories = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.bold, // Semi-bold weight
    color: Colors.black54,
    fontSize: 15,
  );
}
