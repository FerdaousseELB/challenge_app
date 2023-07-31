import 'package:challenge_app/model/vente_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VenteService {
  static Future<List<Vente>> fetchVentes() async {
    final response = await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/ventes.json'));
    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body);
      if (data != null) {
        final List<Vente> ventes = data
            .where((item) => item != null)
            .map((item) => Vente.fromJson(item))
            .toList();
        return ventes;
      }
    }
    return [];
  }

  static Future<int> getNombreVentes(int produitId, int vendeurId) async {
    final ventes = await fetchVentes();
    final currentDate = DateTime.now();
    final firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);

    int nombreVentes = 0;
    for (var vente in ventes) {
      if (vente.vendeurId == vendeurId && vente.produitId == produitId) {
        if (vente.heureDeVente.isAfter(firstDayOfMonth) || vente.heureDeVente == firstDayOfMonth) {
          nombreVentes++;
        }
      }
    }
    return nombreVentes;
  }

  static Future<void> addVente(Vente vente) async {
    await http.post(
      Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/ventes.json'),
      body: json.encode(vente.toJson()),
    );
  }
}
