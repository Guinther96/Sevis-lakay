import 'package:flutter/material.dart';
import 'package:sevis_lakay/components/colors.dart';
import 'package:sevis_lakay/views/search/search.dart';

class MoreCategoriesBottomSheet extends StatelessWidget {
  final void Function(String category) onCategorySelected;

  const MoreCategoriesBottomSheet({
    Key? key,
    required this.onCategorySelected,
    required Null Function(dynamic category) selectedCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // pour rendre scrollable si beaucoup d'éléments
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1 : Alimentation et boissons
            const Text(
              'Alimentation et boissons',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCategoryChip(Icons.restaurant, 'Restaurant', context),
                _buildCategoryChip(
                  Icons.shopping_bag,
                  'Vente à emporter',
                  context,
                ),
                _buildCategoryChip(Icons.local_bar, 'Bars', context),
                _buildCategoryChip(Icons.local_cafe, 'Cafés', context),
                _buildCategoryChip(Icons.delivery_dining, 'Livraison', context),
              ],
            ),

            const SizedBox(height: 16),
            // Section 2 : À faire, à voir
            const Text(
              'À faire, à voir',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCategoryChip(Icons.park, 'Parcs', context),
                _buildCategoryChip(
                  Icons.fitness_center,
                  'Salles de sport',
                  context,
                ),
                _buildCategoryChip(Icons.palette, 'Art', context),
                _buildCategoryChip(Icons.attractions, 'Attractions', context),
                _buildCategoryChip(Icons.nightlife, 'Vie nocturne', context),
                _buildCategoryChip(Icons.music_note, 'Concerts', context),
                _buildCategoryChip(Icons.movie, 'Films', context),
                _buildCategoryChip(Icons.museum, 'Musées', context),
                _buildCategoryChip(
                  Icons.local_library,
                  'Bibliothèques',
                  context,
                ),
              ],
            ),

            const SizedBox(height: 16),
            // Section 3 : Shopping
            const Text(
              'Shopping',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCategoryChip(
                  Icons.local_grocery_store,
                  'Supermarchés',
                  context,
                ),
                _buildCategoryChip(
                  Icons.store_mall_directory,
                  'Centres commerciaux',
                  context,
                ),
                // Ajoute d'autres ici
              ],
            ),

            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(IconData icon, String label, BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: Colors.white),
      label: Text(label, style: TextStyle(color: Colors.white)),
      backgroundColor: AppColors.primaryBlue,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SearchScreen(selectedType: label),
          ),
        );
        onCategorySelected(label);
      },
    );
  }
}
