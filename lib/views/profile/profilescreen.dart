import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sevis_lakay/components/buttons_double.dart';
import 'package:sevis_lakay/components/colors.dart';
import 'package:sevis_lakay/components/text_styles.dart';
import 'package:sevis_lakay/views/login_account/create_account/Create_account.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  bool hasBusinessAccount = false;
  bool isLoading = true;

  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _checkBusinessAccount();
    } else {
      isLoading = false;
    }
  }

  Future<void> _checkBusinessAccount() async {
    final doc = await FirebaseFirestore.instance
        .collection('business_accounts')
        .doc(currentUser!.uid)
        .get();
    setState(() {
      hasBusinessAccount = doc.exists;
      isLoading = false;
    });
  }

  void _showCreateAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Créer un compte business'),
          content: Text('Voulez-vous créer un compte business ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/createBusinessAccount');
              },
              child: Text('Créer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Profil', style: AppTextStyles.pageName)),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (currentUser == null) {
      // L'utilisateur n'est pas connecté
      return Scaffold(
        appBar: AppBar(title: Text('Profil', style: AppTextStyles.pageName)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Vous devez vous connecter pour accéder à votre profil.',
                textAlign: TextAlign.center,
                style: AppTextStyles.title,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    // L'utilisateur est connecté
    return Scaffold(
      appBar: AppBar(title: Text('Profil', style: AppTextStyles.pageName)),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Créer votre compte business'),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateUserAccountForm(),
                                ),
                              );
                            },
                            child: Text('Créer le compte'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 229, 228, 228),
                  radius: 60,
                  backgroundImage: currentUser!.photoURL != null
                      ? NetworkImage(currentUser!.photoURL!)
                      : null,
                  child: currentUser!.photoURL == null
                      ? Icon(Icons.person, size: 80, color: Colors.grey)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              Text('User profile', style: AppTextStyles.title),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 201, 214, 220),
                        radius: 25,
                        child: Icon(Icons.light_mode),
                      ),
                      SizedBox(height: 5),
                      Text('Ajouter un\n    avis'),
                    ],
                  ),
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 201, 214, 220),
                        radius: 25,
                        child: Icon(
                          Icons.camera_alt,
                          color: hasBusinessAccount
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                      SizedBox(height: 5),
                      hasBusinessAccount
                          ? Text('Ajouter une\n     photo')
                          : Opacity(
                              opacity: 0.5,
                              child: Text('Créer un compte\npour ajouter'),
                            ),
                    ],
                  ),
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 201, 214, 220),
                        radius: 25,
                        child: GestureDetector(
                          onTap: () {
                            if (hasBusinessAccount) {
                              Navigator.pushNamed(context, '/businessAccount');
                            } else {
                              _showCreateAccountDialog();
                            }
                          },
                          child: Icon(
                            Icons.other_houses,
                            color: hasBusinessAccount
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      hasBusinessAccount
                          ? Text('Ajouter un\ncommerce')
                          : Opacity(
                              opacity: 0.5,
                              child: Text('Créer un compte\npour ajouter'),
                            ),
                    ],
                  ),
                ],
              ),
              Divider(),
              buildSectionItem(
                icon: Icons.person,
                text: 'Personal information',
              ),
              buildSectionItem(icon: Icons.favorite, text: 'Favorites'),
              buildSectionItem(
                icon: Icons.notifications,
                text: 'Notifications',
              ),
              buildSectionItem(icon: Icons.settings, text: 'Settings'),
              buildSupportSection(),
              SizedBox(height: 50),
              if (!hasBusinessAccount)
                ButtonsDouble(
                  title: 'Create your business account',
                  color1: Colors.white,
                  color2: AppColors.primaryBlue,
                  color3: AppColors.primaryBlue,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSectionItem({required IconData icon, required String text}) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.primaryBlue),
                  SizedBox(width: 10),
                  Text(text, style: AppTextStyles.categories),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 15),
          ],
        ),
      ),
    );
  }

  Widget buildSupportSection() {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10),
            child: Text('Supports', style: AppTextStyles.titleName),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Icon(Icons.help, color: AppColors.primaryBlue),
                      SizedBox(width: 10),
                      Text('Help center', style: AppTextStyles.categories),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
