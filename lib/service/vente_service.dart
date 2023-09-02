import 'package:challenge_app/model/vente_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VenteService {
  static Future<List<Vente>> fetchVentes(String? token) async {
    final response = await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/ventes.json?auth=$token'));
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

  static Future<int> getNombreVentes(int produitId, int vendeurId, String? token) async {
    final ventes = await fetchVentes(token);
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

  static Future<void> addVente(Vente vente, String? token) async {
    final newData = {
      'ID': vente.id,
      'produit_id': vente.produitId,
      'vendeur_id': vente.vendeurId,
      'heure_de_vente': vente.heureDeVente.toUtc().toIso8601String()
    };
    await http.put(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/ventes/${vente.id}.json?auth=$token'), body: json.encode(newData));

  }

  static Future<List<Vente>> fetchVentesByVendeurId(int vendeurId, String? token) async {
    final response = await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/ventes.json?auth=$token'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      final List<Vente> ventes = [];

      if (data != null) {
        for (var entry in data) {
          if (entry != null && entry is Map) {
            final vente = Vente(
              id: entry['ID'],
              produitId: entry['produit_id'],
              vendeurId: entry['vendeur_id'],
              heureDeVente: DateTime.parse(entry['heure_de_vente']),
            );

            if (vente.vendeurId == vendeurId) {
              ventes.add(vente);
            }
          }
        }
      }

      return ventes;
    } else {
      throw Exception('Failed to fetch ventes');
    }
  }
}
