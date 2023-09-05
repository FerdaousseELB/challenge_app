import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginAdminService {
  static Future<bool> isUserAdmin(String userEmail, String? token) async {
    final response = await http.get(
        Uri.parse(
            'https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/admins.json?auth=$token'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        // Si la réponse est une liste
        final adminsEmails = data.where((admin) => admin?['mail'] != null).map((admin) => admin['mail']).toList();
        return adminsEmails.contains(userEmail);
      }
    }
    return false;
  }
}
