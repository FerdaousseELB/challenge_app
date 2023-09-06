import 'package:challenge_app/model/produit_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProduitService {
  static Future<List<Produit>> fetchProduits(String? token) async {
    final response = await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/produits.json?auth=$token'));
    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body);
      if (data != null) {
        final nonNullData = data.where((item) => item != null).toList();
        final List<Produit> produits = nonNullData.map((item) => Produit.fromJson(item)).toList();
        return produits;
      }
    }
    return [];
  }
}
