import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginVendeurService {
  static Future<bool> isUserVendeur(String userEmail, String token) async {
    final response = await http.get(
      Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/vendeurs.json?auth=$token')
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data != null && data is List<dynamic> && data.length > 0) {
        // Ignorer le premier élément (null) et travailler avec les éléments restants.
        final vendeursEmails = data
            .skip(1) // Ignorer le premier élément
            .where((vendeur) => vendeur?['mail'] != null)
            .map((vendeur) => vendeur['mail'])
            .toList();

        return vendeursEmails.contains(userEmail);
      }
    }
    return false;
  }
}
