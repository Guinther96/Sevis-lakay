import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevis_lakay/views/profile/Business_account/business_account.dart';
import 'package:sevis_lakay/widget/location_input.dart';

class BusinessForm extends StatefulWidget {
  const BusinessForm({super.key});

  @override
  State<BusinessForm> createState() => _BusinessFormState();
}

class _BusinessFormState extends State<BusinessForm> {
  late TextEditingController nameController;
  late TextEditingController hourController;
  late TextEditingController addressController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController descriptionController;

  final _formKey = GlobalKey<FormState>();

  String name = '';
  String address = '';
  String phone = '';
  String email = '';
  String openingHour = '';
  String description = '';
  String photoUrl = '';
  String businessType = 'Restaurant'; // Valeur par défaut

  final List<String> businessTypes = [
    'Restaurant',
    'Église',
    'Club',
    'Hôtel',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    hourController = TextEditingController();
    addressController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    descriptionController = TextEditingController();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final doc = await FirebaseFirestore.instance
          .collection('business_accounts')
          .add({
            'name': name,
            'address': address,
            'phone': phone,
            'email': email,
            'openingHour': openingHour,
            'description': description,
            'businessType': businessType, // 👈 nouveau champ
            'photoUrl': 'https://url_de_ton_image_par_defaut.png',
            'createdAt': Timestamp.now(),
          });

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => BusinessAccount(id: doc.id)),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Créer un compte')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  validator: (val) =>
                      val!.isEmpty ? 'Veuillez entrer un nom' : null,
                  onSaved: (val) => name = val!,
                  decoration: InputDecoration(labelText: 'Nom'),
                ),
                TextFormField(
                  controller: addressController,
                  validator: (val) =>
                      val!.isEmpty ? 'Veuillez entrer une adresse' : null,
                  onSaved: (val) => address = val!,
                  decoration: InputDecoration(labelText: 'Adresse'),
                ),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (val) => val!.isEmpty
                      ? 'Veuillez entrer un numéro de téléphone'
                      : null,
                  onSaved: (val) => phone = val!,
                  decoration: InputDecoration(labelText: 'Téléphone'),
                ),
                TextFormField(
                  controller: emailController,
                  validator: (val) =>
                      val!.isEmpty ? 'Veuillez entrer un email' : null,
                  onSaved: (val) => email = val!,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  controller: hourController,
                  keyboardType: TextInputType.datetime,
                  validator: (val) => val!.isEmpty
                      ? 'Veuillez entrer l\'heure d\'ouverture'
                      : null,
                  onSaved: (val) => openingHour = val!,
                  decoration: InputDecoration(labelText: 'Heure d\'ouverture'),
                ),
                TextFormField(
                  controller: descriptionController,
                  keyboardType: TextInputType.multiline,
                  validator: (val) =>
                      val!.isEmpty ? 'Veuillez entrer une description' : null,
                  onSaved: (val) => description = val!,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                SizedBox(height: 16),

                /// 🔽 Type de business (NOUVEAU)
                DropdownButtonFormField<String>(
                  value: businessType,
                  items: businessTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        businessType = value;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Type de business',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                LocationInput(),

                SizedBox(height: 20),
                ElevatedButton(onPressed: _submit, child: Text('Continuer')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
