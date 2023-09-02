import 'package:challenge_app/model/vendeur_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VendeurService {
  static Future<List<Vendeur>> fetchVendeurs(String? token) async {
    final response = await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/vendeurs.json?auth=$token'));
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

  static Future<Vendeur?> getVendeurByEmail(String email, String? token) async {
    final vendeurs = await fetchVendeurs(token);
    final vendeur = vendeurs.firstWhere((vendeur) => vendeur.mail == email, orElse: () => Vendeur(id: -1, nom: "", mail: "", pointDeVenteId: 0, cagnottes: {}));
    return vendeur.id != -1 ? vendeur : null;
  }

  static Future<void> updateCagnotte(int vendeurId, String mois, double nouvelleCagnotte, String? token) async {
    final response = await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/vendeurs/$vendeurId.json?auth=$token'));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final cagnottes = responseData['cagnottes'] as Map<String, dynamic>;

      // Mettre à jour la cagnotte pour le mois spécifié
      cagnottes[mois] = nouvelleCagnotte;

      // Envoyer les cagnottes mises à jour à Firebase
      await http.patch(
        Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/vendeurs/$vendeurId.json?auth=$token'),
        body: json.encode({"cagnottes": cagnottes}),
      );
    } else {
      throw Exception('Failed to update cagnotte.');
    }
  }

}
