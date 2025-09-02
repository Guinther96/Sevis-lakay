import 'package:sevis_lakay/models/business_account_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusinessAccountService {
  Future<String> createBusiness(
    BusinessAccountModel business,
    String user_id,
  ) async {
    final response = await Supabase.instance.client
        .from('business_accounts')
        .insert({
          'name': business.name,
          'address': business.address,
          'phone': business.phone,
          'email': business.email,
          'description': business.description,
          'openingHour': business.openingHour,
          'businesstype': business.businesstype,
          'photoUrl': business.photoUrl,
          'user_id': user_id.isEmpty ? null : user_id,
        })
        .select()
        .single(); // récupère la ligne insérée

    return response['id'].toString();
  }

  Future<List<BusinessAccountModel>> fetchAllBusinesses() async {
    final response = await Supabase.instance.client
        .from('business_accounts')
        .select('*');

    // Si la table est vide, retourne une liste vide
    if (response == null || response.isEmpty) {
      return [];
    }

    // Map chaque élément en BusinessAccountModel
    return response
        .map<BusinessAccountModel>(
          (item) => BusinessAccountModel.fromJson(item),
        )
        .toList();
  }
}
