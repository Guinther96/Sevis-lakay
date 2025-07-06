import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sevis_lakay/data/Item.dart';

final tileProvider = Provider((ref) {
  return categoryItems;
});
