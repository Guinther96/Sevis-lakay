import 'package:flutter/material.dart';
import 'package:sevis_lakay/widget/bottom_navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  bool isLoading = false;

  void _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      setState(() {
        isLoading = false;
      });

      if (response.user != null && response.session != null) {
        // Connexion réussie
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BottomNavigation(selectedIndex: 0),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur inconnue lors de la connexion')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  void _resetPassword() async {
    String? emailInput = await showDialog<String>(
      context: context,
      builder: (context) {
        String tempEmail = '';
        return AlertDialog(
          title: const Text('Réinitialiser le mot de passe'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Entrez votre email'),
            onChanged: (value) => tempEmail = value.trim(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tempEmail),
              child: const Text('Envoyer'),
            ),
          ],
        );
      },
    );

    if (emailInput != null && emailInput.contains('@')) {
      setState(() {
        isLoading = true;
      });
      try {
        await supabase.auth.resetPasswordForEmail(emailInput);
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email de réinitialisation envoyé !')),
        );
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } else if (emailInput != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un email valide')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Connexion'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 20),

          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/images/sevislakay.png', height: 200),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val == null || !val.contains('@')
                      ? 'Entrez un email valide'
                      : null,
                  onSaved: (val) => email = val!.trim(),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                  validator: (val) => val == null || val.length < 6
                      ? 'Mot de passe trop court'
                      : null,
                  onSaved: (val) => password = val!,
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _signIn,
                        child: const Text('Se connecter'),
                      ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _resetPassword,
                  child: Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(color: Theme.of(context).primaryColor),
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
