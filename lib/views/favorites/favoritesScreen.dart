import 'package:flutter/material.dart';
import 'package:sevis_lakay/components/text_styles.dart';
import 'package:sevis_lakay/views/profile/Business_account/business_account.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool isLoading = true;
  List<dynamic> favoriteBusinesses = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('favorites')
          .select('business_accounts(*)') // jointure implicite
          .eq('user_id', user.id);

      // response sera une liste où chaque item a une clé business_accounts avec l'objet business
      setState(() {
        favoriteBusinesses = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Mes Favoris', style: AppTextStyles.pageName),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Favoris', style: AppTextStyles.pageName),
      ),
      body: favoriteBusinesses.isEmpty
          ? Center(child: Text('Aucun favori pour le moment'))
          : ListView.builder(
              itemCount: favoriteBusinesses.length,
              itemBuilder: (context, index) {
                final business = favoriteBusinesses[index]['business_accounts'];
                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: business['photoUrl'] != null
                        ? Image.network(
                            business['photoUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.store),
                    title: Text(business['name'] ?? 'Nom inconnu'),
                    subtitle: Text(business['address'] ?? ''),
                    onTap: () {
                      // aller à la page du business
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BusinessAccount(id: business['id'].toString()),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
