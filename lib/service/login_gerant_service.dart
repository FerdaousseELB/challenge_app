import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginGerantService {
  static Future<bool> isUserGerant(String userEmail) async {
    final response =
    await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/gerants.json'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        // If the response is a List
        final gerantsEmails = data.where((gerant) => gerant?['mail'] != null).map((gerant) => gerant['mail']).toList();
        return gerantsEmails.contains(userEmail);
      }
    }
    return false;
  }
}
