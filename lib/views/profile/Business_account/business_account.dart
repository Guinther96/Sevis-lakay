import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sevis_lakay/components/buttons_icons.dart';
import 'package:sevis_lakay/components/colors.dart';
import 'package:sevis_lakay/components/text_styles.dart';
import 'package:sevis_lakay/models/category_Item.dart';
import 'package:sevis_lakay/models/formulaire_business.dart';
import 'package:sevis_lakay/views/info_tile/reviews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sevis_lakay/views/profile/Business_account/formulaire.dart';

class BusinessAccount extends ConsumerStatefulWidget {
  BusinessAccount({super.key, required this.id});

  final String id;

  @override
  ConsumerState<BusinessAccount> createState() => _BusinessAccountState();
}

class _BusinessAccountState extends ConsumerState<BusinessAccount> {
  late TextEditingController nameController;
  late TextEditingController hourController;
  String _image = '';
  bool isLoading = true;

  late String address;
  late String phone;
  late String email;
  late String description;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    hourController = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    final doc = await FirebaseFirestore.instance
        .collection('business_accounts')
        .doc(widget.id)
        .get();
    if (!doc.exists) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Compte non trouvé')));
      Navigator.of(context).pop();
      return;
    }
    final data = doc.data()!;
    nameController.text = data['name'] ?? '';
    hourController.text = data['openingHour'] ?? '';
    _image = data['photoUrl'] ?? '';
    address = data['address'] ?? '';
    phone = data['phone'] ?? '';
    email = data['email'] ?? '';
    description = data['description'] ?? '';
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> _updateProfile() async {
    await FirebaseFirestore.instance
        .collection('business_accounts')
        .doc(widget.id)
        .update({
          'name': nameController.text,
          'openingHour': hourController.text,
        });
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Mis à jour')));
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Galerie'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Appareil photo'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
        ],
      ),
    );
    if (source == null) return;

    final image = await picker.pickImage(source: source);

    if (image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Aucune image sélectionnée.')));
      return;
    }

    final file = File(image.path);

    if (!await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fichier image introuvable à ${image.path}')),
      );
      return;
    }

    try {
      final ref = FirebaseStorage.instance.ref().child(
        'business/${widget.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final uploadTask = await ref.putFile(file);
      final url = await ref.getDownloadURL();

      print('Upload réussi. URL : $url');

      await FirebaseFirestore.instance
          .collection('business_accounts')
          .doc(widget.id)
          .update({'photoUrl': url});

      if (!mounted) return;
      setState(() {
        _image = url;
      });
    } catch (e) {
      print('Erreur lors de l\'upload : $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors de l\'upload : $e')));
    }
  }

  final tileProvider = StateProvider<bool>((ref) => false);

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // SliverAppBar pour l'image de couverture
          SliverAppBar(
            backgroundColor: Colors.white,
            expandedHeight: 230,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Positioned.fill(
                    child: Builder(
                      builder: (context) {
                        return _image != null &&
                                _image.isNotEmpty &&
                                _image.startsWith('http')
                            ? Image.network(
                                _image,
                                key: UniqueKey(),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                      'assets/images/hotel.png',
                                      fit: BoxFit.cover,
                                    ),
                              )
                            : Image.asset(
                                'assets/images/hotel.png',
                                fit: BoxFit.cover,
                              );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 120,
                    child: ElevatedButton(
                      onPressed: _pickAndUploadImage,
                      child: const Text("Image Profile"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // SliverToBoxAdapter pour tout le reste du contenu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom et actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(labelText: 'Nom'),
                        ),
                      ),
                      GestureDetector(onTap: () {}, child: Icon(Icons.add)),
                      Row(
                        children: [
                          Material(
                            borderRadius: BorderRadius.circular(20),
                            elevation: 3,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: Icon(Icons.favorite),
                                onPressed: () {},
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Material(
                            borderRadius: BorderRadius.circular(20),
                            elevation: 3,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(Icons.share),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.deepOrangeAccent,
                        size: 18,
                      ),
                      Text(
                        'rjtjldjdj',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      Text('jfjdkjer'),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 30,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        'Open',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Infos business
                  Row(
                    children: [
                      Icon(Icons.location_on, color: AppColors.primaryBlue),
                      SizedBox(width: 10),
                      Text(address),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.phone, color: AppColors.primaryBlue),
                      SizedBox(width: 10),
                      Text(phone),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.wifi_protected_setup,
                        color: AppColors.primaryBlue,
                      ),
                      SizedBox(width: 10),
                      Text(email),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 45,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.primaryBlue,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Icon(Icons.send_rounded, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'View on Map',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Ajoute ce bouton dans ta page BusinessAccount (par exemple en haut de la colonne)
                  ElevatedButton(
                    onPressed: () async {
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          // Utilise les contrôleurs déjà présents pour pré-remplir les champs
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                              left: 16,
                              right: 16,
                              top: 16,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Nom',
                                    ),
                                  ),
                                  TextField(
                                    controller: hourController,
                                    decoration: InputDecoration(
                                      labelText: 'Heure',
                                    ),
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Adresse',
                                    ),
                                    controller: TextEditingController(
                                      text: address,
                                    ),
                                    onChanged: (v) => address = v,
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Téléphone',
                                    ),
                                    controller: TextEditingController(
                                      text: phone,
                                    ),
                                    onChanged: (v) => phone = v,
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                    ),
                                    controller: TextEditingController(
                                      text: email,
                                    ),
                                    onChanged: (v) => email = v,
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      labelText: 'À propos',
                                    ),
                                    controller: TextEditingController(
                                      text: description,
                                    ),
                                    onChanged: (v) => description = v,
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('business_accounts')
                                          .doc(widget.id)
                                          .update({
                                            'name': nameController.text,
                                            'openingHour': hourController.text,
                                            'address': address,
                                            'phone': phone,
                                            'email': email,
                                            'description': description,
                                          });
                                      if (!mounted) return;
                                      Navigator.pop(context);
                                      setState(
                                        () {},
                                      ); // Pour rafraîchir l'affichage
                                    },
                                    child: Text('Enregistrer'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                      await _loadData(); // Recharge les données après modification
                    },
                    child: Text('Modifier'),
                  ),
                  Divider(height: 10),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.punch_clock),
                          SizedBox(width: 10),
                          Text(
                            hourController.text.isNotEmpty
                                ? hourController.text
                                : 'Opening Hours',
                            style: AppTextStyles.titleItem,
                          ),
                        ],
                      ),
                      Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 30,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 242, 243, 246),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10, left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Today',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('08:00-18:00'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(height: 10),
                  SizedBox(height: 20),
                  Text('About', style: AppTextStyles.titleItem),
                  Text(description),
                  SizedBox(height: 20),
                  Divider(height: 10),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MyButtonIcons(
                        borderColor: AppColors.primaryBlue,
                        backgroundColor: AppColors.primaryBlue,
                        iconColor: Colors.white,
                        textColor: Colors.white,
                        icons: Icons.location_pin,
                        title: 'Get Directions',
                      ),
                      InkWell(
                        onTap: () {},
                        child: MyButtonIcons(
                          borderColor: AppColors.primaryBlue,
                          backgroundColor: Colors.white,
                          iconColor: AppColors.primaryBlue,
                          textColor: AppColors.primaryBlue,
                          icons: Icons.star,
                          title: 'Write a Review',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Reviews', style: AppTextStyles.titleName),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_border,
                          color: AppColors.primaryBlue,
                          size: 100,
                        ),
                        SizedBox(height: 10),
                        Text('Be the first to review this business'),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Reviews(),
                              ),
                            );
                          },
                          child: MyButtonIcons(
                            borderColor: AppColors.primaryBlue,
                            backgroundColor: Colors.white,
                            iconColor: AppColors.primaryBlue,
                            textColor: AppColors.primaryBlue,
                            icons: Icons.star,
                            title: 'Write a Review',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
