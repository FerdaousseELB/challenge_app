import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../model/store_model.dart';
import '../../model/vendeur_model.dart';

class ScreenVendeurs extends StatefulWidget {
  final String? token;

  ScreenVendeurs({this.token});

  @override
  _ScreenVendeursState createState() => _ScreenVendeursState();
}

class _ScreenVendeursState extends State<ScreenVendeurs> {
  List<Vendeur> vendeurs = [];
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _mailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? selectedPointDeVente;
  List<String> pointsDeVenteDisponibles = [];
  List<Store> pointsDeVente = [];

  @override
  void initState() {
    super.initState();
    fetchVendeurs();
    fetchPointsDeVente();
  }

  Future<void> fetchVendeurs() async {
    final response = await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/vendeurs.json?auth=${widget.token}'));
    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body);

      if (data != null) {
        final nonNullData = data.where((item) => item != null).toList();
        vendeurs = nonNullData
            .map((vendeur) => Vendeur.fromJson(vendeur))
            .toList();
        setState(() {});
      }
    } else {
      print('Erreur lors de la récupération des vendeurs : ${response.statusCode}');
    }
  }

  Future<void> fetchPointsDeVente() async {
    final response = await http.get(Uri.parse(
        'https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/pointsDeVente.json?auth=${widget.token}'));
    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body);
      if (data != null) {
        final nonNullData = data.where((item) => item != null).toList();
        pointsDeVente = nonNullData
            .map((pointDeVente) => Store.fromJson(pointDeVente))
            .toList();

        pointsDeVenteDisponibles = pointsDeVente
            .map((point) => point.nom)
            .toList();
        setState(() {});

      }
    } else {
      print(
          'Erreur lors de la récupération des points de vente : ${response.statusCode}');
    }
  }

  int getPointDeVenteIdByName(String? pointDeVenteNom) {
    final store = pointsDeVente.firstWhere(
          (point) => point.nom == pointDeVenteNom,
      orElse: () => Store(id: 6, nom: '', adresse: ''),
    );

    return store.id;
  }

  Future<void> createVendeur() async {
    if (_formKey.currentState!.validate()) {
      int maxId = 0;
      vendeurs.forEach((vendeur) {
        if (vendeur.id > maxId) {
          maxId = vendeur.id;
        }
      });
      final newVendeurId = maxId + 1;

      try {
        final authResult = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: _mailController.text,
            password: _passwordController.text);

        if (authResult.user != null) {
          final selectedPointId = getPointDeVenteIdByName(selectedPointDeVente);
          final newVendeur = Vendeur(
            id: newVendeurId, // Utilisation du nouvel ID calculé
            nom: _nomController.text,
            mail: _mailController.text,
            pointDeVenteId: selectedPointId,
            cagnottes: {"012000": 0}, // Initialisez la liste des cagnottes comme vide ici
          );

          final response = await http.put(
            Uri.parse(
                'https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/vendeurs/$newVendeurId.json?auth=${widget.token}'),
            body: json.encode(newVendeur.toJson()),
          );

          if (response.statusCode == 200) {
            await fetchVendeurs();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Vendeur créé avec succès.'),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors de la création du vendeur.'),
              ),
            );
          }

          // Réinitialiser les champs du formulaire
          _nomController.clear();
          _mailController.clear();
          _passwordController.clear();
          selectedPointDeVente = null;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la création du compte.'),
            ),
          );
        }
      } catch (e) {
        print('Erreur lors de la création du compte.' + e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création du compte.' + e.toString()),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendeurs'),
      ),
      body: ListView.builder(
        itemCount: vendeurs.length,
        itemBuilder: (context, index) {
          final vendeur = vendeurs[index];
          return ListTile(
            title: Text(vendeur.nom),
            subtitle: Text(vendeur.mail),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Créer un Vendeur'),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: _nomController,
                          decoration: InputDecoration(
                            labelText: 'Nom',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un nom.';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _mailController,
                          decoration: InputDecoration(
                            labelText: 'Mail',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un mail.';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un mot de passe.';
                            }
                            return null;
                          },
                        ),
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            labelText: 'Point de Vente',
                          ),
                          value: selectedPointDeVente,
                          items: pointsDeVenteDisponibles
                              .map((point) => DropdownMenuItem(
                            value: point,
                            child: Text(point),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPointDeVente = value as String?;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Veuillez sélectionner un point de vente.';
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
                      createVendeur();
                      Navigator.of(context).pop();
                    },
                    child: Text('Créer Vendeur'),
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
