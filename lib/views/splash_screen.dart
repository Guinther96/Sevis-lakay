import 'package:flutter/material.dart';
import 'package:sevis_lakay/widget/bottom_navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 4));

    final session = supabase.auth.currentSession;
    final user = supabase.auth.currentUser;

    if (session != null && user != null) {
      // ⚠️ Vérifie si l’email est confirmé
      if (user.emailConfirmedAt != null) {
        // ✅ Email confirmé → accès autorisé
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BottomNavigation(selectedIndex: 0)),
        );
      } else {
        // ❌ Email pas encore confirmé → redirige vers une page spéciale
      }
    } else {
      // Pas de session → on peut afficher une page de bienvenue/connexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BottomNavigation(selectedIndex: 0)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Image.asset('assets/images/sevislakay.png')),
    );
  }
}
