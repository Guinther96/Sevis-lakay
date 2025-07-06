import 'package:flutter/material.dart';
import 'package:sevis_lakay/components/colors.dart';
import 'package:sevis_lakay/components/text_styles.dart';
import 'package:sevis_lakay/models/category_Item.dart';

class InfoTileCategory extends StatelessWidget {
  const InfoTileCategory({super.key, required this.item, required this.onTap});
  final CategoryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Material(
        elevation: 6.0,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          width: 350,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    item.image,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Alignement corrigé
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Alignement corrigé
                        children: [
                          Text(item.name, style: AppTextStyles.titleItem),
                          SizedBox(width: 30),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.orange, size: 18),
                              Text(item.valeur.toString()),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_pin, size: 15),
                              Text(item.adress),
                            ],
                          ),
                          Text(
                            item.distance,
                            style: TextStyle(color: AppColors.primaryBlue),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.punch_clock_rounded,
                                size: 15,
                                color: Colors.red,
                              ),
                              Text(
                                'Closed',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                          Text(item.review.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
