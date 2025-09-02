import 'package:flutter/material.dart';
import 'package:sevis_lakay/models/business_account_model.dart';
import 'package:sevis_lakay/models/servives/business_account_services.dart';
import 'package:sevis_lakay/views/profile/Business_account/business_account.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class CreateBusinessAccountPage extends StatefulWidget {
  const CreateBusinessAccountPage({super.key});

  @override
  State<CreateBusinessAccountPage> createState() =>
      _CreateBusinessAccountPageState();
}

class _CreateBusinessAccountPageState extends State<CreateBusinessAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = BusinessAccountService();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _openingHourController = TextEditingController();
  final _closingHourController = TextEditingController();

  String _selectedType = 'Restaurant';
  bool _isSubmitting = false;

  // Méthode sécurisée pour vérifier si le business est ouvert
  bool isOpenNow(String openingHour, String closing_hour) {
    try {
      if (openingHour.isEmpty || closing_hour.isEmpty) return false;

      final now = DateTime.now();
      final format = DateFormat("H:mm");

      final openTime = format.parse(openingHour);
      final closeTime = format.parse(closing_hour);

      final openDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        openTime.hour,
        openTime.minute,
      );
      final closeDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        closeTime.hour,
        closeTime.minute,
      );

      return now.isAfter(openDateTime) && now.isBefore(closeDateTime);
    } catch (e) {
      // Retourne false si le parsing échoue
      return false;
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to create a business account');
      }

      final business = BusinessAccountModel(
        name: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        description: _descriptionController.text,
        opening_hour: _openingHourController.text,
        closing_hour: _closingHourController.text,
        businesstype: _selectedType,
        photoUrl: '',
        user_id: user.id,
        openingHour: '',
      );

      final newBusinessId = await _service.createBusiness(business, user.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Business enregistré avec succès")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BusinessAccount(id: newBusinessId.toString()),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final open = isOpenNow(
      _openingHourController.text,
      _closingHourController.text,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Créer un business'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nom"),
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: "Adresse"),
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Téléphone"),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) =>
                    v != null && v.contains('@') ? null : "Email invalide",
              ),
              TextFormField(
                controller: _openingHourController,
                decoration: const InputDecoration(
                  labelText: "Heure d'ouverture (HH:mm)",
                ),
                keyboardType: TextInputType.datetime,
              ),
              TextFormField(
                controller: _closingHourController,
                decoration: const InputDecoration(
                  labelText: "Heure de fermeture (HH:mm)",
                ),
                keyboardType: TextInputType.datetime,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items:
                    [
                          'Restaurant',
                          'Clubs',
                          'Églises',
                          'Hôtels',
                          'Bars',
                          'Ventes à emporter',
                          'Cafés',
                          'Livraison',
                          'Parcs',
                          'Salles de sport',
                          'Art',
                          'Attractions',
                          'Vie nocturne',
                          'Concerts',
                          'Événements',
                          'Films',
                          'Musées',
                          'Autres',
                          'Supermarchés',
                          'Magasins',
                          'Centres commerciaux',
                        ]
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (value) =>
                    setState(() => _selectedType = value ?? 'Restaurant'),
                decoration: const InputDecoration(
                  labelText: "Type de business",
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    open ? Icons.check_circle : Icons.cancel,
                    color: open ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    open ? "Ouvert" : "Fermé",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: open ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text("Créer"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
