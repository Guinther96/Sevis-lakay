import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sevis_lakay/components/colors.dart';
import 'package:sevis_lakay/views/favorites/favoritesScreen.dart';
import 'package:sevis_lakay/views/home/button_login.dart';
import 'package:sevis_lakay/views/home/home_page.dart';
import 'package:sevis_lakay/views/profile/Business_account/business_account.dart';
import 'package:sevis_lakay/views/profile/Business_account/formulaire.dart';
import 'package:sevis_lakay/views/profile/user_acccount/help_center.dart';
import 'package:sevis_lakay/views/profile/user_acccount/personel_info.dart';
import 'package:sevis_lakay/views/profile/user_acccount/settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String? avatarUrl;
  String? userName; // 👈 ajout
  bool isLoading = true;
  bool hasBusinessAccount = false;

  final user = Supabase.instance.client.auth.currentUser;
  Map<String, dynamic>? businessAccountData;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _loadProfile();
      _checkBusinessAccount();
    } else {
      isLoading = false;
    }
  }

  Future<void> _loadProfile() async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', user!.id)
        .maybeSingle();

    if (response != null) {
      _nameController.text = response['full_name'] ?? '';
      avatarUrl = response['avatar_url'];
      userName = response['full_name'] ?? ''; // 👈 ajout
    } else {
      await supabase.from('profiles').insert({'id': user!.id});
      _nameController.text = '';
      avatarUrl = null;
      userName = ''; // 👈 ajout
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _checkBusinessAccount() async {
    final response = await supabase
        .from('business_accounts')
        .select()
        .eq('user_id', user!.id)
        .maybeSingle();

    setState(() {
      hasBusinessAccount = response != null;
      businessAccountData = response;
    });
  }

  Future<void> _updateProfile() async {
    final fullName = _nameController.text.trim();
    await supabase
        .from('profiles')
        .update({
          'full_name': fullName,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        })
        .eq('id', user!.id);

    setState(() {
      userName = fullName; // 👈 ajout
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profil mis à jour')));
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final file = File(picked.path);
      final fileExt = picked.path.split('.').last;
      final fileName = 'avatar_${user!.id}.$fileExt';

      final storage = supabase.storage.from('profiles');

      await storage.upload(
        fileName,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      final publicUrl = storage.getPublicUrl(fileName);

      await supabase
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', user!.id);

      setState(() {
        avatarUrl = publicUrl;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Image mise à jour')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune image sélectionnée')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Profil'),
        ),
        body: const Center(child: Text('Vous devez être connecté.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Profil',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl!)
                          : null,
                      child: avatarUrl == null
                          ? const Icon(Icons.add_a_photo, size: 30)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Nom modifiable au clic
                  GestureDetector(
                    onTap: () async {
                      final newName = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          final controller = TextEditingController(
                            text: userName ?? '',
                          );
                          return AlertDialog(
                            title: const Text('Modifier le nom d\'utilisateur'),
                            content: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                labelText: 'Nouveau nom',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                    controller.text.trim(),
                                  );
                                },
                                child: const Text('Enregistrer'),
                              ),
                            ],
                          );
                        },
                      );

                      if (newName != null && newName.isNotEmpty) {
                        await supabase
                            .from('profiles')
                            .update({'full_name': newName})
                            .eq('id', user!.id);

                        setState(() {
                          _nameController.text = newName;
                          userName = newName;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nom mis à jour')),
                        );
                      }
                    },
                    child: Text(
                      userName != null && userName!.isNotEmpty
                          ? userName!
                          : 'Name User',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.business),
                    label: Text(
                      hasBusinessAccount
                          ? 'Aller à mon compte business'
                          : 'Créer un compte business',
                    ),
                    onPressed: () {
                      if (hasBusinessAccount) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BusinessAccount(
                              id: businessAccountData!['id'].toString(),
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateBusinessAccountPage(),
                          ),
                        );
                      }
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(),
                      Text(
                        'Account',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PersonalInfoScreen(),
                            ),
                          );
                        },
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person_2_outlined,
                                      color: AppColors.primaryBlue,
                                    ),
                                    SizedBox(width: 5),
                                    Text('Personal information'),
                                  ],
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_right_sharp),
                            ],
                          ),
                        ),
                      ),
                      Divider(),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FavoritesPage(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.favorite_border,
                                    color: AppColors.primaryBlue,
                                  ),
                                  SizedBox(width: 5),
                                  Text('Favorites'),
                                ],
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_right_sharp),
                          ],
                        ),
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  color: AppColors.primaryBlue,
                                ),
                                SizedBox(width: 5),
                                Text('Notifications'),
                              ],
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_right_sharp),
                        ],
                      ),
                      Divider(),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsPage(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.settings,
                                    color: AppColors.primaryBlue,
                                  ),
                                  SizedBox(width: 5),
                                  Text('Settings'),
                                ],
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_right_sharp),
                          ],
                        ),
                      ),
                      Divider(),
                      Text(
                        'Support',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HelpCenterPage(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.help_outline,
                                    color: AppColors.primaryBlue,
                                  ),
                                  SizedBox(width: 5),
                                  Text('Help Center'),
                                ],
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_right_sharp),
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (!mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => HomePage()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Déconnexion'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
