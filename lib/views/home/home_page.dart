import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevis_lakay/components/colors.dart';
import 'package:sevis_lakay/components/text_styles.dart';
import 'package:sevis_lakay/data/Item.dart' as rowCategory;

import 'package:sevis_lakay/data/row.dart';

import 'package:sevis_lakay/models/category_item.dart';
import 'package:sevis_lakay/views/login_account/login.dart';
import 'package:sevis_lakay/views/profile/Business_account/business_account.dart';
import 'package:sevis_lakay/views/search/search.dart';
import 'package:sevis_lakay/widget/item_tile.dart';
import 'package:sevis_lakay/widget/seach_bar_widget.dart';
import 'package:sevis_lakay/widget/tile_category.dart';
import 'package:sevis_lakay/providers/tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int isSelected = 0;
  int selectedIndex = 0;
  final List<String> types = ['Tous', 'Restaurant', 'Église', 'Club', 'Hôtel'];
  String selectedType = 'Tous';

  void _selectedType(BuildContext context, String type) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SearchScreen(selectedType: type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = ref.watch(tileProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Home', style: AppTextStyles.pageName)),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            flexibleSpace: FlexibleSpaceBar(
              background: SizedBox.expand(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Good Morning', style: AppTextStyles.title),
                              Text(
                                'Find local business in Haiti',
                                style: AppTextStyles.subtitle,
                              ),
                            ],
                          ),
                        ),

                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Login(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 25, right: 10),
                            child: Container(
                              height: 40,
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: AppColors.primaryBlue,
                              ),
                              child: Center(
                                child: Text(
                                  'Log in',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'inter',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_pin,
                            color: AppColors.primaryBlue,
                          ),
                          Text(
                            'Using your current location',
                            style: TextStyle(color: AppColors.primaryBlue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverAppBar(
            expandedHeight: 220,
            flexibleSpace: FlexibleSpaceBar(
              background: SizedBox.expand(
                child: Column(
                  children: [
                    SeachBarWidget(sizeWidth: 350),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.primaryBlue,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.map, color: Colors.white, size: 30),
                                SizedBox(height: 5),
                                Text(
                                  'View Map',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverAppBar(
            expandedHeight: 80,
            pinned: true,
            toolbarHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              background: SizedBox.expand(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Categories', style: AppTextStyles.titleName),
                      SizedBox(height: 15),
                      SizedBox(
                        height: 30,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: types.length,
                          itemBuilder: (context, index) {
                            final type = types[index];
                            final isSelected = type == selectedType;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: ChoiceChip(
                                label: Text(type),
                                selected: isSelected,
                                onSelected: (_) {
                                  _selectedType(context, type);
                                  setState(() {
                                    selectedType = type;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Nearby Businesses', style: AppTextStyles.titleName),
                      InkWell(
                        child: Text(
                          'View Map',
                          style: AppTextStyles.TextButton,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  SizedBox(
                    height:
                        160, // hauteur fixée pour permettre le scroll horizontal
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('business_accounts')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final docs = snapshot.data!.docs;

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;

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
                              child: Container(
                                width: 280,
                                margin: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      // Image circulaire
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child:
                                            (data['photoUrl'] ?? '').isNotEmpty
                                            ? ClipOval(
                                                child: Image.network(
                                                  data['photoUrl'],
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => Image.asset(
                                                        'assets/images/hotel.png',
                                                        width: 60,
                                                        height: 60,
                                                        fit: BoxFit.cover,
                                                      ),
                                                ),
                                              )
                                            : CircleAvatar(
                                                radius: 30,
                                                backgroundColor:
                                                    Colors.grey[300],
                                                child: Icon(
                                                  Icons.business,
                                                  size: 30,
                                                ),
                                              ),
                                      ),
                                      // Infos business
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data['name'] ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                data['address'] ?? '',
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Ouvert à: ${data['openingHour'] ?? ''}',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
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

                  SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Top', style: AppTextStyles.titleName),
                      InkWell(
                        onTap: () {},
                        child: Text('See All', style: AppTextStyles.TextButton),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('business_accounts')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                        return CircularProgressIndicator();

                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
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
                              child: ListTile(
                                leading: (data['photoUrl'] ?? '').isNotEmpty
                                    ? Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: ClipOval(
                                          child: Image.network(
                                            data['photoUrl'],
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Image.asset(
                                                      'assets/images/hotel.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey[300],
                                        ),
                                        child: Icon(Icons.business, size: 40),
                                      ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['name'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(data['address'] ?? ''),
                                  ],
                                ),

                                subtitle: Text(
                                  'Ouvert à: ${data['openingHour'] ?? ''}',
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
