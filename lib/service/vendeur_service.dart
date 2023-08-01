import 'package:challenge_app/model/vendeur_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VendeurService {
  static Future<List<Vendeur>> fetchVendeurs() async {
    final response = await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/vendeurs.json'));
    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body);
      if (data != null) {
        final List<Vendeur> vendeurs = data
            .where((item) => item != null)
            .map((item) => Vendeur.fromJson(item))
            .toList();
        return vendeurs;
      }
    }
    return [];
  }

  static Future<Vendeur?> getVendeurByEmail(String email) async {
    final vendeurs = await fetchVendeurs();
    final vendeur = vendeurs.firstWhere((vendeur) => vendeur.mail == email, orElse: () => Vendeur(id: -1, nom: "", mail: "", pointDeVenteId: 0, cagnottes: {}));
    return vendeur.id != -1 ? vendeur : null;
  }

  static Future<void> updateCagnotte(int vendeurId, String mois, double nouvelleCagnotte) async {
    await http.patch(
      Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/vendeurs/$vendeurId.json'),
      body: json.encode({"cagnottes": {mois: nouvelleCagnotte}}),
    );
  }
}
