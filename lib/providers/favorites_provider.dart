import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sevis_lakay/models/category_item.dart';

class FavoriteTilesNotifier extends StateNotifier<List<CategoryItem>> {
  FavoriteTilesNotifier() : super([]);

  void toggleTileFavoriteStatus(CategoryItem categoryItem) {
    final tileIsFavorite = state.contains(categoryItem);

    if (tileIsFavorite) {
      state = state.where((item) => item != categoryItem).toList();
    } else {
      state = [...state, categoryItem];
    }
  }
}

final favoriteTileProvider =
    StateNotifierProvider<FavoriteTilesNotifier, List<CategoryItem>>((ref) {
      return FavoriteTilesNotifier();
    });
