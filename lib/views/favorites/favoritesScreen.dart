import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sevis_lakay/providers/favorites_provider.dart';

class FavoritePage extends ConsumerWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteItems = ref.watch(favoriteTileProvider);

    if (favoriteItems.isEmpty) {
      return const Center(child: Text("Aucun favori pour le moment."));
    }

    return ListView.builder(
      itemCount: favoriteItems.length,
      itemBuilder: (context, index) {
        final item = favoriteItems[index];
        return ListTile(
          leading: Image.network(item.image),
          title: Text(item.name),
        );
      },
    );
  }
}
