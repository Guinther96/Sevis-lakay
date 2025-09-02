import 'package:flutter/material.dart';
import 'package:sevis_lakay/components/colors.dart';
import 'package:sevis_lakay/components/text_styles.dart';
import 'package:sevis_lakay/widget/bottom_plus.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:sevis_lakay/views/home/button_login.dart';
import 'package:sevis_lakay/views/profile/Business_account/business_account.dart';
import 'package:sevis_lakay/views/search/search.dart';
import 'package:sevis_lakay/widget/seach_bar_widget.dart';
import 'package:sevis_lakay/providers/tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class HomePage extends ConsumerStatefulWidget {
  HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  double latitude = 0;
  double longitude = 0;
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  Widget _buildUserProfile(Map<String, dynamic> profile) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: profile['avatar_url'] != null
              ? NetworkImage(profile['avatar_url'])
              : null,
          child: profile['avatar_url'] == null
              ? Icon(Icons.person, size: 40)
              : null,
        ),

        Text(profile['email'] ?? ''),
      ],
    );
  }

  int isSelected = 0;
  int selectedIndex = 0;
  final List<String> types = ['Tous', 'Restaurant', 'Église', 'Club', 'Hôtel'];
  String selectedType = 'Tous';
  final List<IconData> typeIcons = [
    Icons.all_inclusive, // Tous
    Icons.restaurant,
    Icons.church,
    Icons.nightlife, // Club
    Icons.hotel,
  ];

  void _selectedType(BuildContext context, String type) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SearchScreen(selectedType: type)),
    );
    // If you need to update latitude and longitude, fetch them here from a valid source.
  }

  Future<void> _openMap() async {
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Impossible d’ouvrir la carte')));
    }
  }

  Future<int> getReviewsCount(String businessId) async {
    final response = await Supabase.instance.client
        .from('reviews')
        .select('id')
        .eq('business_id', businessId)
        .count(CountOption.exact);

    return response.count ?? 0;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUser();
    });
  }

  Future<void> _checkUser() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      print('Current user: $user'); // Debug

      if (user != null) {
        final response = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        print('Profile data: $response'); // Debug

        if (mounted) {
          setState(() {
            userProfile = response;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching profile: $e'); // Debug
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool _checkBusinessStatus(String? openingHour, String? closingHour) {
    if (openingHour == null ||
        closingHour == null ||
        openingHour.isEmpty ||
        closingHour.isEmpty) {
      return false;
    }

    try {
      final now = DateTime.now();
      final format = DateFormat("HH:mm");
      final openTime = format.parse(openingHour);
      final closeTime = format.parse(closingHour);

      final nowTime = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
      );
      final openDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        openTime.hour,
        openTime.minute,
      );
      final closeDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        closeTime.hour,
        closeTime.minute,
      );

      if (closeDateTime.isBefore(openDateTime)) {
        return nowTime.isAfter(openDateTime) || nowTime.isBefore(closeDateTime);
      } else {
        return nowTime.isAfter(openDateTime) && nowTime.isBefore(closeDateTime);
      }
    } catch (e) {
      debugPrint("Error parsing business hours: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    final item = ref.watch(tileProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Home', style: AppTextStyles.pageName),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
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
                          padding: const EdgeInsets.only(left: 10),
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

                        Builder(
                          builder: (context) {
                            if (user == null) {
                              return InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ButtonLogin(),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 5,
                                    right: 10,
                                  ),
                                  child: Icon(
                                    Icons.login,
                                    size: 40,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              );
                            } else if (isLoading) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  top: 5,
                                  right: 10,
                                ),
                                child: SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            } else if (userProfile != null) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  right: 10,
                                ),
                                child: _buildUserProfile(userProfile!),
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_pin,
                            color: AppColors.primaryBlue,
                            size: 15,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Using your current location',
                              style: TextStyle(color: AppColors.primaryBlue),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          SliverAppBar(
            backgroundColor: Colors.white,
            expandedHeight: 220,
            flexibleSpace: FlexibleSpaceBar(
              background: SizedBox.expand(
                child: Column(
                  children: [
                    SeachBarWidget(sizeWidth: 350),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: InkWell(
                        onTap: _openMap,
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
                                  Icon(
                                    Icons.map,
                                    color: Colors.white,
                                    size: 30,
                                  ),
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
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverAppBar(
            backgroundColor: Colors.white,
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
                          itemCount:
                              types.length + 1, // +1 pour le bouton "Plus"
                          itemBuilder: (context, index) {
                            if (index < types.length) {
                              final type = types[index];
                              final icon = typeIcons[index];
                              final isSelected = type == selectedType;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: ChoiceChip(
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryBlue,
                                  backgroundColor: Colors.white,
                                  onSelected: (_) {
                                    _selectedType(context, type);
                                    setState(() {
                                      selectedType = type;
                                    });
                                  },
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        icon,
                                        size: 18,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.primaryBlue,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        type,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              // Dernier élément : l'icône pour "Plus"
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: ActionChip(
                                  backgroundColor: Colors.white,
                                  avatar: const Icon(Icons.more_horiz),
                                  label: const Text('Plus'),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      backgroundColor: Colors.white,
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (context) {
                                        return MoreCategoriesBottomSheet(
                                          selectedCategory: (category) {
                                            // Gère la sélection de la catégorie ici si besoin
                                          },
                                          onCategorySelected:
                                              (String category) {
                                                setState(() {
                                                  selectedType = category;
                                                });
                                              },
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            }
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
                    height: 160,
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: Supabase.instance.client
                          .from('business_accounts')
                          .stream(primaryKey: ['id'])
                          .order('name'),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final docs = snapshot.data!;

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index];
                            final isOpen = _checkBusinessStatus(
                              data['opening_hour']?.toString(),
                              data['closing_hour']?.toString(),
                            );

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BusinessAccount(
                                      id: data['id'].toString(),
                                    ),
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
                                  color: Colors.white,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child:
                                            (data['photoUrl'] ?? '').isNotEmpty
                                            ? Container(
                                                width: 100,
                                                height: 130,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      data['photoUrl'],
                                                    ),
                                                    fit: BoxFit.cover,
                                                    onError:
                                                        (error, stackTrace) {},
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
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 4),
                                              Text(
                                                data['name'] ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 16,
                                                    color: Colors.grey[700],
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    data['address'] ?? '',
                                                    style: TextStyle(
                                                      color: Colors.grey[700],
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 16,
                                                    color: Colors.grey[700],
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    data['opening_hour'] !=
                                                                null &&
                                                            data['closing_hour'] !=
                                                                null
                                                        ? '${data['opening_hour']} - ${data['closing_hour']}'
                                                        : 'Horaires non définis',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 20),
                                              FutureBuilder<int>(
                                                future: getReviewsCount(
                                                  data['id'].toString(),
                                                ),
                                                builder: (context, reviewSnapshot) {
                                                  if (!reviewSnapshot.hasData) {
                                                    return Text('...');
                                                  }
                                                  return Row(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: isOpen
                                                                  ? Colors
                                                                        .green[50]
                                                                  : Colors
                                                                        .red[50],
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                              border: Border.all(
                                                                color: isOpen
                                                                    ? Colors
                                                                          .green
                                                                    : Colors
                                                                          .red,
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                  isOpen
                                                                      ? Icons
                                                                            .check_circle
                                                                      : Icons
                                                                            .cancel,
                                                                  size: 14,
                                                                  color: isOpen
                                                                      ? Colors
                                                                            .green
                                                                      : Colors
                                                                            .red,
                                                                ),
                                                                SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  isOpen
                                                                      ? 'OUVERT'
                                                                      : 'FERMÉ',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        isOpen
                                                                        ? Colors
                                                                              .green
                                                                        : Colors
                                                                              .red,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(width: 50),
                                                      Icon(
                                                        Icons.star,
                                                        color: Colors.orange,
                                                        size: 16,
                                                      ),
                                                    ],
                                                  );
                                                },
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
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: Supabase.instance.client
                        .from('business_accounts')
                        .stream(primaryKey: ['id']),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index];
                          final isOpen = _checkBusinessStatus(
                            data['opening_hour']?.toString(),
                            data['closing_hour']?.toString(),
                          );

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BusinessAccount(
                                    id: data['id'].toString(),
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.white,
                              margin: EdgeInsets.all(8),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    (data['photoUrl'] ?? '').isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              data['photoUrl'],
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : CircleAvatar(
                                            radius: 40,
                                            backgroundColor: Colors.grey[300],
                                            child: Icon(
                                              Icons.business,
                                              size: 40,
                                            ),
                                          ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                data['name'] ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              SizedBox(width: 80),
                                              Icon(
                                                Icons.star,
                                                color: Colors.orange,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 16,
                                                color: Colors.grey[700],
                                              ),
                                              SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  data['address'] ?? '',
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 16,
                                                color: Colors.grey[700],
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                data['opening_hour'] != null &&
                                                        data['closing_hour'] !=
                                                            null
                                                    ? '${data['opening_hour']} - ${data['closing_hour']}'
                                                    : 'Horaires non définis',
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6),
                                          Row(
                                            children: [
                                              // Badge ouvert/fermé
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isOpen
                                                      ? Colors.green[50]
                                                      : Colors.red[50],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: isOpen
                                                        ? Colors.green
                                                        : Colors.red,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      isOpen
                                                          ? Icons.check_circle
                                                          : Icons.cancel,
                                                      size: 14,
                                                      color: isOpen
                                                          ? Colors.green
                                                          : Colors.red,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      isOpen
                                                          ? 'OUVERT'
                                                          : 'FERMÉ',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: isOpen
                                                            ? Colors.green
                                                            : Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              // Reviews
                                              FutureBuilder<int>(
                                                future: getReviewsCount(
                                                  data['id'].toString(),
                                                ),
                                                builder: (context, reviewSnapshot) {
                                                  if (!reviewSnapshot.hasData) {
                                                    return Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star,
                                                          color: Colors.orange,
                                                          size: 16,
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text('...'),
                                                      ],
                                                    );
                                                  }
                                                  return Row(
                                                    children: [
                                                      SizedBox(width: 80),
                                                      Text(
                                                        '${reviewSnapshot.data} reviews',
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
