import 'package:flutter/material.dart';
import 'package:sevis_lakay/components/colors.dart';
import 'package:sevis_lakay/components/text_styles.dart';
import 'package:sevis_lakay/widget/seach_bar_widget.dart';

class Mapscreen extends StatefulWidget {
  const Mapscreen({super.key});

  @override
  State<Mapscreen> createState() => _MapscreenState();
}

class _MapscreenState extends State<Mapscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
      appBar: AppBar(title: Text('Map', style: AppTextStyles.pageName)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16),
              child: SeachBarWidget(sizeWidth: 350),
            ),
            SizedBox(height: 100),
            Center(
              child: Icon(
                Icons.location_pin,
                size: 150,
                color: AppColors.primaryBlue,
              ),
            ),
            Text('Map view', style: AppTextStyles.title),
            Text('1 businesses found', style: AppTextStyles.subtitle),
            SizedBox(height: 30),
            Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 100,
                width: 320,
                decoration: BoxDecoration(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      Icon(Icons.location_pin, color: AppColors.primaryBlue),
                      SizedBox(width: 10),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Text(
                              'Cafe kokiyaj',
                              style: AppTextStyles.titleItem,
                            ),
                          ),
                          Text('Restaurants', style: AppTextStyles.subtitle),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(left: 250),
              child: Column(
                children: [
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(50),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.copy_all,
                        color: AppColors.primaryBlue,
                        size: 30,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(50),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.menu,
                        color: AppColors.primaryBlue,
                        size: 30,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(50),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.location_pin,
                        color: AppColors.primaryBlue,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
