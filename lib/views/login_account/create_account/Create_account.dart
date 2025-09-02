import 'package:flutter/material.dart';
import 'package:sevis_lakay/views/home/home_page.dart';
import 'package:sevis_lakay/views/login_account/login.dart';
import 'package:sevis_lakay/views/splash_screen.dart';
import 'package:sevis_lakay/widget/bottom_navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final confirmEmailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  void _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    setState(() {
      isLoading = true;
    });

    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'myapp://login-callback',
      );

      setState(() {
        isLoading = false;
      });

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie ! Vérifiez votre email.'),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SplashScreen()),
          (Route<dynamic> route) => false, // enlève toutes les anciennes routes
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur inconnue pendant l\'inscription'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Exception : $e')));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    confirmEmailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Inscription'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/images/sevislakay.png', height: 200),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val == null || !val.contains('@')
                      ? 'Entrez un email valide'
                      : null,
                ),
                TextFormField(
                  controller: confirmEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Confirmez l\'email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val != emailController.text
                      ? 'Les emails ne correspondent pas'
                      : null,
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                  validator: (val) => val == null || val.length < 6
                      ? 'Mot de passe trop court (min 6 caractères)'
                      : null,
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _signUp,
                        child: const Text('S\'inscrire'),
                      ),
                SizedBox(height: 20),
                GestureDetector(
                  child: Text(
                    'Déjà inscrit ?',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
