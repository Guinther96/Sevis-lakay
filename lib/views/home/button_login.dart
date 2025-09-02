import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as supa;
import 'package:sevis_lakay/components/buttons_double.dart';
import 'package:sevis_lakay/components/colors.dart';
import 'package:sevis_lakay/views/login_account/create_account/Create_account.dart';
import 'package:sevis_lakay/views/login_account/login.dart';
import 'package:sevis_lakay/views/profile/Business_account/formulaire.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class ButtonLogin extends StatefulWidget {
  const ButtonLogin({super.key});

  @override
  State<ButtonLogin> createState() => _ButtonLoginState();
}

class _ButtonLoginState extends State<ButtonLogin> {
  Future<void> signInWithProvider(supa.OAuthProvider provider) async {
    final supabase = supa.Supabase.instance.client;

    await supabase.auth.signInWithOAuth(
      provider,
      redirectTo: 'io.supabase.flutter://login-callback',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, title: const Text('Login')),
      body: Center(
        child: Column(
          children: [
            Image.asset('assets/images/sevislakay.png', height: 250),
            const SizedBox(height: 50),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: ButtonsDouble(
                title: 'Create Account',
                color1: AppColors.primaryBlue,
                color3: Colors.white,
                color2: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateBusinessAccountPage(),
                  ),
                );
              },
              child: ButtonsDouble(
                title: 'Create Account business',
                color3: Colors.white,
                color1: AppColors.primaryBlue,
                color2: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text("Continuer avec Google"),
              onPressed: () => signInWithProvider(supa.OAuthProvider.google),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.facebook),
              label: const Text("Continuer avec Facebook"),
              onPressed: () => signInWithProvider(supa.OAuthProvider.facebook),
            ),
          ],
        ),
      ),
    );
  }
}
