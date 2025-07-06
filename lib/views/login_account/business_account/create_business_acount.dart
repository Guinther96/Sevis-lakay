import 'package:flutter/material.dart';
import 'package:sevis_lakay/components/buttons_double.dart';
import 'package:sevis_lakay/components/colors.dart';
import 'package:sevis_lakay/components/text_field.dart';
import 'package:sevis_lakay/components/text_styles.dart';

class CreateBusinessAccount extends StatefulWidget {
  const CreateBusinessAccount({super.key});

  @override
  State<CreateBusinessAccount> createState() => _CreateBusinessAccountState();
}

class _CreateBusinessAccountState extends State<CreateBusinessAccount> {
  bool ischecked = false;
  bool ischecked2 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/sevislakay.png',
                  fit: BoxFit.cover,
                  width: 150,
                  height: 150,
                ),
                Text('Create account', style: AppTextStyles.title),
                Text(
                  'Join the local business community',
                  style: AppTextStyles.subtitle,
                ),
                SizedBox(height: 40),
                FieldFormulaire(name: 'Business name'),
                SizedBox(height: 20),
                FieldFormulaire(name: 'Sector of activity'),
                SizedBox(height: 20),
                FieldFormulaire(name: 'Business adress'),
                SizedBox(height: 20),
                FieldFormulaire(name: 'Your full name'),
                SizedBox(height: 20),
                FieldFormulaire(name: 'Professional email'),
                SizedBox(height: 20),
                FieldFormulaire(name: 'Phone number'),
                SizedBox(height: 20),
                FieldFormulaire(name: 'Password'),
                SizedBox(height: 20),
                FieldFormulaire(name: 'Confirm your password'),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: ischecked,
                            onChanged: (bool? newValue) {
                              setState(() {
                                ischecked = newValue ?? false;
                              });
                            },
                          ),
                          Text('I accept the general conditions'),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 45),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: ischecked2,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  ischecked2 = newValue ?? true;
                                });
                              },
                            ),
                            Text('I certify that the information is correct'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ButtonsDouble(
                    title: 'Create',
                    color1: AppColors.primaryBlue,
                    color2: AppColors.primaryBlue,
                    color3: Colors.white,
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
