import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevis_lakay/components/colors.dart';
import 'package:sevis_lakay/components/text_styles.dart';
import 'package:sevis_lakay/views/profile/Business_account/business_account.dart';

class SearchScreen extends StatefulWidget {
  final String selectedType;

  const SearchScreen({super.key, required this.selectedType});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late String selectedType;

  @override
  void initState() {
    super.initState();
    selectedType = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Résultats pour $selectedType',
          style: AppTextStyles.pageName,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: (selectedType == 'Tous')
              ? FirebaseFirestore.instance
                    .collection('business_accounts')
                    .snapshots()
              : FirebaseFirestore.instance
                    .collection('business_accounts')
                    .where('businessType', isEqualTo: selectedType)
                    .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return Center(child: Text('Aucun business trouvé.'));
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BusinessAccount(id: docs[index].id),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.all(8),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text(
                            data['name'] ?? '',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(data['address'] ?? ''),
                          Text("Ouvert à: ${data['openingHour'] ?? ''}"),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
