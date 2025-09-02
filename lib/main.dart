import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sevis_lakay/views/splash_screen.dart';
import 'package:sevis_lakay/widget/bottom_navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

final _appLinks = AppLinks();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zaqjannimzyewcyjvkbj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InphcWphbm5pbXp5ZXdjeWp2a2JqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMyMDc1ODcsImV4cCI6MjA2ODc4MzU4N30.5ane1cluwF-00ijDkvbNyhvJkRmACEEfHndmp99r6DQ',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();

    // ✅ Écoute des liens profonds
    _sub = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          print('Lien reçu : $uri');

          // Vérifie si c’est bien le lien de confirmation
          if (uri.toString().startsWith('myapp://login-callback')) {
            _handleConfirmedUser();
          }
        }
      },
      onError: (err) {
        print('Erreur de lien : $err');
      },
    );
  }

  // ✅ Traitement du lien de confirmation Supabase
  Future<void> _handleConfirmedUser() async {
    await Supabase.instance.client.auth.refreshSession();
    final user = Supabase.instance.client.auth.currentUser;

    if (user?.emailConfirmedAt != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
      );
    } else {
      print('Email toujours pas confirmé');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BottomNavigation(selectedIndex: 0),
    );
  }
}
