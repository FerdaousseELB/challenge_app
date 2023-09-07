import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../model/PointdeVenteInfo.dart';
import '../../model/gerant_model.dart';
import '../../model/store_model.dart';
import '../../model/vendeur_model.dart';

class ScreenStore extends StatefulWidget {
  final String? token;

  ScreenStore({this.token});

  @override
  _ScreenStoreState createState() => _ScreenStoreState();
}

class _ScreenStoreState extends State<ScreenStore> {
  TextEditingController _nomController = TextEditingController();
  TextEditingController _adresseController = TextEditingController();

  // Ajoutez la clé de formulaire ici
  final _formKey = GlobalKey<FormState>();

  Future<List<PointDeVenteInfo>> fetchPointsDeVente() async {
    final response = await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/pointsDeVente.json?auth=${widget.token}'));
    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body);
      if (data != null) {
        final nonNullData = data.where((item) => item != null).toList();
        final List<Store> pointsDeVente = nonNullData
            .map((store) => Store.fromJson(store))
            .toList();

        final List<Gerant> gerants = await fetchGerants();
        final List<Vendeur> vendeurs = await fetchVendeurs();

        final List<PointDeVenteInfo> pointsDeVenteInfo = pointsDeVente.map((pointDeVente) {
          final gerant = gerants.firstWhere(
                (gerant) => gerant.pointDeVenteId == pointDeVente.id,
            orElse: () => Gerant(id: -1, nom: 'Inconnu', mail: '', pointDeVenteId: -1),
          );

          final vendeursDuPoint = vendeurs.where(
                (vendeur) => vendeur.pointDeVenteId == pointDeVente.id,
          ).toList();

          return PointDeVenteInfo(
            pointDeVente: pointDeVente,
            gerant: gerant,
            vendeurs: vendeursDuPoint,
          );
        }).toList();

        return pointsDeVenteInfo;
      }
    }
    return [];
  }

  Future<List<Gerant>> fetchGerants() async {
    final response = await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/gerants.json?auth=${widget.token}'));
    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body);
      if (data != null) {
        final nonNullData = data.where((item) => item != null).toList();
        final List<Gerant> gerants = nonNullData
            .map((gerant) => Gerant.fromJson(gerant))
            .toList();
        return gerants;
      }
    }
    return [];
  }

  Future<List<Vendeur>> fetchVendeurs() async {
    final response = await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/vendeurs.json?auth=${widget.token}'));
    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body);
      if (data != null) {
        final nonNullData = data.where((item) => item != null).toList();
        final List<Vendeur> vendeurs = nonNullData
            .map((vendeur) => Vendeur.fromJson(vendeur))
            .toList();
        return vendeurs;
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
        if (pointDeVente.pointDeVente.id > dernierID) {
          dernierID = pointDeVente.pointDeVente.id;
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
          Expanded(
            child: FutureBuilder<List<PointDeVenteInfo>>(
              future: fetchPointsDeVente(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                } else {
                  final pointsDeVenteInfo = snapshot.data ?? [];

                  if (pointsDeVenteInfo.isEmpty) {
                    return Center(child: Text('Aucun point de vente trouvé.'));
                  }

                  return ListView.builder(
                    itemCount: pointsDeVenteInfo.length,
                    itemBuilder: (context, index) {
                      final info = pointsDeVenteInfo[index];

                      return ListTile(
                        title: Text(info.pointDeVente.nom),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gérant: ${info.gerant.nom}'),
                            Text('Nombre de vendeurs: ${info.vendeurs.length}'),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Ajouter un Point de Vente'),
                content: SingleChildScrollView(
                  child: Form(
                    // Utilisez la clé du formulaire ici
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nomController,
                          decoration: InputDecoration(labelText: 'Nom du Point de Vente'),
                          // Vous pouvez ajouter des validateurs ici si nécessaire
                          validator: (value) {
                            if (value == null) {
                              return 'Veuillez entrer un nom.';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _adresseController,
                          decoration: InputDecoration(labelText: 'Adresse du Point de Vente'),
                          // Vous pouvez ajouter des validateurs ici si nécessaire
                          validator: (value) {
                            if (value == null) {
                              return 'Veuillez entrer une adresse.';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Annuler'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Validez le formulaire avant d'ajouter le point de vente
                      if (_formKey.currentState!.validate()) {
                        // Ajoutez le point de vente ici
                        ajouterPointDeVente();
                        Navigator.of(context).pop(); // Fermez la boîte de dialogue
                      }
                    },
                    child: Text('Ajouter'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
