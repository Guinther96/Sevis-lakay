import 'package:flutter/material.dart';
import 'package:sevis_lakay/components/buttons_double.dart';
import 'package:sevis_lakay/components/colors.dart';
import 'package:sevis_lakay/components/text_styles.dart';
import 'package:sevis_lakay/views/login_account/business_account/create_business_acount.dart';
import 'package:sevis_lakay/views/login_account/create_account/Create_account.dart';
import 'package:sevis_lakay/views/login_account/log_in_page.dart';
import 'package:sevis_lakay/views/profile/Business_account/formulaire.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            children: [
              Image.asset(
                'assets/images/sevislakay.png',
                fit: BoxFit.cover,
                width: 150,
                height: 150,
              ),
              Text('Sign into your account', style: AppTextStyles.pageName),
              Text(
                'Access your profile, manage your   \n                  busisness more',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 50),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LogInPage()),
                  );
                },
                child: ButtonsDouble(
                  title: 'Login',
                  color1: AppColors.primaryBlue,
                  color2: AppColors.primaryBlue,
                  color3: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {},
                child: InkWell(
                  onTap: () {},
                  child: InkWell(
                    onTap: () {},
                    child: ButtonsDouble(
                      title: 'Create account',
                      color1: Colors.white,
                      color2: AppColors.primaryBlue,
                      color3: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BusinessForm()),
                  );
                },
                child: ButtonsDouble(
                  title: 'Create Business account',
                  color1: Colors.white,
                  color2: AppColors.primaryBlue,
                  color3: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
