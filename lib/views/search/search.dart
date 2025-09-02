import 'package:flutter/material.dart';
import 'package:sevis_lakay/components/colors.dart';
import 'package:sevis_lakay/components/text_styles.dart';
import 'package:sevis_lakay/views/profile/Business_account/business_account.dart';
import 'package:sevis_lakay/widget/bottomsheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchScreen extends StatefulWidget {
  final String selectedType;

  const SearchScreen({super.key, required this.selectedType});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late String selectedType;
  List<Map<String, dynamic>> allBusinesses = [];
  List<Map<String, dynamic>> filteredBusinesses = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = false; // ✅ Pour l'état de chargement

  @override
  void initState() {
    super.initState();
    selectedType = widget.selectedType;
    _fetchBusinesses();
  }

  Future<void> _fetchBusinesses() async {
    setState(() {
      isLoading = true;
    });

    final client = Supabase.instance.client;
    var query = client.from('business_accounts').select();

    if (selectedType != 'Tous') {
      query = query.eq('businesstype', selectedType);
    }

    final response = await query;

    setState(() {
      isLoading = false;
      if (response != null) {
        allBusinesses = List<Map<String, dynamic>>.from(response);
        filteredBusinesses = allBusinesses;
      }
    });
  }

  void _filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredBusinesses = allBusinesses;
      } else {
        filteredBusinesses = allBusinesses.where((business) {
          final name = (business['name'] ?? '').toString().toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Résultats pour $selectedType',
          style: AppTextStyles.pageName.copyWith(color: AppColors.primaryBlue),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primaryBlue),
                      ),
                      hintText: 'Rechercher par nom...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primaryBlue),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onChanged: _filterSearch,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 171, 194, 228),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.filter_list_outlined,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return BottomsheetWidget();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Liste des business
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredBusinesses.isEmpty
                ? const Center(child: Text('Aucun business trouvé.'))
                : ListView.builder(
                    itemCount: filteredBusinesses.length,
                    itemBuilder: (context, index) {
                      final business =
                          filteredBusinesses[index]; // <- tu n'as besoin que de celle-ci
                      final id = business['id']
                          .toString(); // <- ici on extrait l'id
                      final photoUrl = business['photoUrl'] as String?;
                      final name = business['name'] ?? '';
                      final address = business['address'] ?? '';
                      final openingHour = business['openingHour'] ?? '';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BusinessAccount(id: id),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: photoUrl != null && photoUrl.isNotEmpty
                                ? Image.network(
                                    photoUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    Icons.store,
                                    color: AppColors.primaryBlue,
                                  ),
                            title: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(address),
                                if (openingHour.isNotEmpty)
                                  Text("Ouvert à: $openingHour"),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
