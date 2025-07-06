import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreateUserAccountForm extends StatefulWidget {
  const CreateUserAccountForm({super.key});

  @override
  State<CreateUserAccountForm> createState() => _CreateUserAccountFormState();
}

class _CreateUserAccountFormState extends State<CreateUserAccountForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  File? _profileImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadProfileImage(String uid) async {
    if (_profileImage == null) return null;

    final storageRef = FirebaseStorage.instance.ref().child(
      'user_profiles/$uid.jpg',
    );
    await storageRef.putFile(_profileImage!);
    return await storageRef.getDownloadURL();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Créer l'utilisateur
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      final uid = userCredential.user!.uid;

      // 2. Upload image (optionnel)
      final imageUrl = await _uploadProfileImage(uid);

      // 3. Enregistrer dans Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'profileImage': imageUrl,
        'createdAt': Timestamp.now(),
      });

      // 4. Mise à jour du profil Firebase Auth
      await userCredential.user!.updateDisplayName(_nameController.text.trim());
      if (imageUrl != null) {
        await userCredential.user!.updatePhotoURL(imageUrl);
      }

      // 5. Naviguer ou succès
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Compte créé avec succès !")));
      Navigator.pop(context); // ou aller à la page d'accueil
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur: ${e.toString()}")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Créer un compte utilisateur')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? Icon(Icons.add_a_photo, size: 40)
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Nom complet"),
                  validator: (value) => value!.isEmpty ? "Nom requis" : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      !value!.contains('@') ? "Email invalide" : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: "Mot de passe"),
                  obscureText: true,
                  validator: (value) =>
                      value!.length < 6 ? "Min 6 caractères" : null,
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _createAccount,
                        child: Text("Créer le compte"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
