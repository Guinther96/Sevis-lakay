import 'package:flutter/material.dart';
import 'package:sevis_lakay/components/buttons_icons.dart';
import 'package:sevis_lakay/components/colors.dart';
import 'package:sevis_lakay/components/text_styles.dart';
import 'package:sevis_lakay/data/Item.dart';
import 'package:sevis_lakay/models/category_item.dart';
import 'package:sevis_lakay/providers/favorites_provider.dart';
import 'package:sevis_lakay/views/info_tile/reviews.dart';
import 'package:sevis_lakay/providers/tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InfoTileScreen extends ConsumerStatefulWidget {
  final CategoryItem item;
  InfoTileScreen(this.item, {super.key});

  @override
  ConsumerState<InfoTileScreen> createState() => _InfoTileState();
}

class _InfoTileState extends ConsumerState<InfoTileScreen> {
  final tileProvider = StateProvider<bool>((ref) => false);

  @override
  Widget build(BuildContext context) {
    final favorite = ref.watch(favoriteTileProvider);
    final isFavorite = favorite.contains(widget.item);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            expandedHeight: 230,
            floating: false,
            pinned: true,

            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(widget.item.image),
            ),
          ),
          SliverAppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            toolbarHeight: 100,
            expandedHeight: 110,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.item.name, style: AppTextStyles.pageName),
                        Row(
                          children: [
                            Material(
                              borderRadius: BorderRadius.circular(20),
                              elevation: 3,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite ? Colors.red : null,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(favoriteTileProvider.notifier)
                                        .toggleTileFavoriteStatus(widget.item);
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Material(
                              borderRadius: BorderRadius.circular(20),
                              elevation: 3,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,

                                child: Icon(Icons.share),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.deepOrangeAccent,
                          size: 18,
                        ),
                        Text(
                          widget.item.valeur.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 10),
                        Text(widget.item.review),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 30,
                      width: 50,

                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          widget.item.open,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
            automaticallyImplyLeading: false,

            pinned: true,

            expandedHeight: 1120,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.primaryBlue),
                        SizedBox(width: 10),
                        Text(widget.item.adress),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.phone, color: AppColors.primaryBlue),
                        SizedBox(width: 10),
                        Text(widget.item.num),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.wifi_protected_setup,
                          color: AppColors.primaryBlue,
                        ),
                        SizedBox(width: 10),
                        Text(widget.item.site),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 45,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.primaryBlue,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Icon(Icons.send_rounded, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'View on Map',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(height: 10),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.punch_clock),
                            SizedBox(width: 10),
                            Text(
                              'Business Hours',
                              style: AppTextStyles.titleItem,
                            ),
                          ],
                        ),

                        Icon(Icons.keyboard_arrow_down),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 30,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 242, 243, 246),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Today',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('08:00-18:00'),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(height: 10),
                    SizedBox(height: 20),
                    Text('About', style: AppTextStyles.titleItem),
                    Text(
                      'hsjdh whdn jwhwj jwirjd jwh jwd jwnd jwdhnhjsdncjwh \ndncjwnjfwnhji wjenf wjefnwe',
                    ),
                    SizedBox(height: 20),
                    Divider(height: 10),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MyButtonIcons(
                          borderColor: AppColors.primaryBlue,
                          backgroundColor: AppColors.primaryBlue,
                          iconColor: Colors.white,
                          textColor: Colors.white,
                          icons: Icons.location_pin,
                          title: 'Get Directions',
                        ),

                        InkWell(
                          onTap: () {},
                          child: MyButtonIcons(
                            borderColor: AppColors.primaryBlue,
                            backgroundColor: Colors.white,
                            iconColor: AppColors.primaryBlue,
                            textColor: AppColors.primaryBlue,
                            icons: Icons.star,
                            title: 'Write a Review',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text('Reviews', style: AppTextStyles.titleName),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_border,
                            color: AppColors.primaryBlue,
                            size: 100,
                          ),
                          SizedBox(height: 10),
                          Text('Be the first to review this business'),
                          SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Reviews(),
                                ),
                              );
                            },
                            child: MyButtonIcons(
                              borderColor: AppColors.primaryBlue,
                              backgroundColor: Colors.white,
                              iconColor: AppColors.primaryBlue,
                              textColor: AppColors.primaryBlue,
                              icons: Icons.star,
                              title: 'Write a Review',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
