import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginVendeurService {
  static Future<bool> isUserVendeur(String userEmail) async {
    final response =
    await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/vendeurs.json'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        // If the response is a List
        final vendeursEmails = data.where((vendeur) => vendeur?['mail'] != null).map((vendeur) => vendeur['mail']).toList();
        return vendeursEmails.contains(userEmail);
      }
    }
    return false;
  }
}
