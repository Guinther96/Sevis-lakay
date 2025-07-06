import 'package:flutter/material.dart';
import 'package:sevis_lakay/models/category_Item.dart';

class RowCategories {
  final String name;
  final IconData iconData;
  final List<CategoryItem> categoryitems;

  RowCategories({
    required this.name,
    required this.iconData,
    required this.categoryitems,
  });

  static map(SizedBox Function(dynamic rowCategory) param0) {}
}
