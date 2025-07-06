import 'package:flutter/material.dart';
import 'package:sevis_lakay/models/row_category.dart';

class TileCategory extends StatefulWidget {
  const TileCategory({
    super.key,
    required this.rowCategory,
    required this.isSelected,
  });
  final RowCategories rowCategory;
  final bool isSelected;

  @override
  State<TileCategory> createState() => _TileCategoryState();
}

class _TileCategoryState extends State<TileCategory> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: GestureDetector(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.rowCategory.iconData, size: 16, color: Colors.blue),
            const SizedBox(width: 5),
            Text(
              widget.rowCategory.name,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
