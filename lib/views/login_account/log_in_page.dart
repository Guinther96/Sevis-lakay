import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sevis_lakay/components/buttons_double.dart';
import 'package:sevis_lakay/components/colors.dart';
import 'package:sevis_lakay/components/text_field.dart';
import 'package:sevis_lakay/components/text_styles.dart';
import 'package:sevis_lakay/views/profile/user_acccount/user_account.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  String email = '';
  String password = '';

  // ...existing code...

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final formkey = GlobalKey<FormState>();

  registration() async {
    if (passwordController.text.isNotEmpty) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text,
            );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registration successful')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserAccount()),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('The password provided is too weak.')),
          );
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('The account already exists for that email.'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred during registration.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ...existing code...
                Form(
                  key: formkey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          // You can add more validation here if needed
                          return null;
                        },
                        decoration: InputDecoration(hintText: 'Email'),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          // You can add more validation here if needed
                          return null;
                        },
                        decoration: InputDecoration(hintText: 'Password'),
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // ...existing code...
                GestureDetector(
                  onTap: () async {
                    if (formkey.currentState!.validate()) {
                      setState(() {
                        email = emailController.text;
                        password = passwordController.text;
                      });
                      registration();
                      // Navigate to the next screen or perform any other action
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => NextScreen()));
                    }
                  },
                  child: ButtonsDouble(
                    title: 'Login profil',
                    color1: AppColors.primaryBlue,
                    color2: AppColors.primaryBlue,
                    color3: Colors.white,
                    // <-- Ajoute ceci
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
