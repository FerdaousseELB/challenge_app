import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../model/store_model.dart';

class ScreenStore extends StatefulWidget {
  final String? token;

  ScreenStore({this.token});

  @override
  _ScreenStoreState createState() => _ScreenStoreState();
}

class _ScreenStoreState extends State<ScreenStore> {
  TextEditingController _nomController = TextEditingController();
  TextEditingController _adresseController = TextEditingController();

  Future<List<Store>> fetchPointsDeVente() async {
    final response = await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/pointsDeVente.json?auth=${widget.token}'));
    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body);
      if (data != null) {
        final nonNullData = data.where((item) => item != null).toList();
        final List<Store> pointsDeVente = nonNullData
            .map((store) => Store.fromJson(store))
            .toList();
        return pointsDeVente;
      }
    }
    return [];
  }

  Future<void> ajouterPointDeVente() async {
    final nom = _nomController.text;
    final adresse = _adresseController.text;

    if (nom.isNotEmpty && adresse.isNotEmpty) {
      final pointsDeVente = await fetchPointsDeVente();

      // Trouver le dernier ID et l'incrémenter
      int dernierID = 0;
      for (final pointDeVente in pointsDeVente) {
        if (pointDeVente.id > dernierID) {
          dernierID = pointDeVente.id;
        }
      }
      final newID = dernierID + 1;

      final newStore = {
        "ID": newID, // Utiliser le nouvel ID
        "adresse": adresse,
        "nom": nom
      };

      final response = await http.put(
        Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/pointsDeVente/$newID.json?auth=${widget.token}'),
        body: json.encode(newStore),
      );

      if (response.statusCode == 200) {
        // Le point de vente a été ajouté avec succès.
        // Vous pouvez maintenant mettre à jour l'affichage pour inclure le nouveau point de vente.
        setState(() {
          _nomController.clear();
          _adresseController.clear();
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Les points de vente'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nomController,
                    decoration: InputDecoration(labelText: 'Nom du Point de Vente'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _adresseController,
                    decoration: InputDecoration(labelText: 'Adresse du Point de Vente'),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: ajouterPointDeVente,
                  child: Text('Ajouter'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Store>>(
              future: fetchPointsDeVente(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                } else {
                  final pointsDeVente = snapshot.data ?? [];

                  if (pointsDeVente.isEmpty) {
                    return Center(child: Text('Aucun point de vente trouvé.'));
                  }

                  return ListView.builder(
                    itemCount: pointsDeVente.length,
                    itemBuilder: (context, index) {
                      final pointDeVente = pointsDeVente[index];

                      return ListTile(
                        title: Text(pointDeVente.nom),
                        subtitle: Text(pointDeVente.adresse),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
