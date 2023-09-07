import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../model/store_model.dart';
import '../../model/vendeur_model.dart';
import '../../model/vente_model.dart';

class VendeurAvecVentes {
  final Vendeur vendeur;
  final int nombreDeVentes;

  VendeurAvecVentes(this.vendeur, this.nombreDeVentes);
}

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
  List<VendeurAvecVentes> vendeursAvecVentes = [];

  @override
  void initState() {
    super.initState();
    fetchVendeurs();
    fetchPointsDeVente();
    fetchVentes();
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

  Future<void> fetchVentes() async {
    final response = await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/ventes.json?auth=${widget.token}'));
    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body);

      if (data != null) {
        final nonNullData = data.where((item) => item != null).toList();
        final ventes = nonNullData
            .map((vente) => Vente.fromJson(vente))
            .toList();

        // Compter le nombre de ventes pour chaque vendeur
        vendeursAvecVentes = vendeurs.map((vendeur) {
          final nombreDeVentes = ventes.where((vente) => vente.vendeurId == vendeur.id).length;
          return VendeurAvecVentes(vendeur, nombreDeVentes);
        }).toList();

        // Triez la liste des vendeurs en ordre décroissant en fonction du nombre de ventes
        vendeursAvecVentes.sort((a, b) => b.nombreDeVentes.compareTo(a.nombreDeVentes));

        setState(() {});
      }
    } else {
      print('Erreur lors de la récupération des ventes : ${response.statusCode}');
    }
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
        itemCount: vendeursAvecVentes.length,
        itemBuilder: (context, index) {
          final vendeurAvecVentes = vendeursAvecVentes[index];
          final vendeur = vendeurAvecVentes.vendeur;
          final nombreDeVentes = vendeurAvecVentes.nombreDeVentes;

          // Définissez des couleurs pour les trois premiers vendeurs
          Color itemColor;
          if (index == 0) {
            itemColor = Colors.green; // Couleur pour le premier vendeur
          } else if (index == 1) {
            itemColor = Colors.blue; // Couleur pour le deuxième vendeur
          } else if (index == 2) {
            itemColor = Colors.red; // Couleur pour le troisième vendeur
          } else {
            itemColor = Colors.black; // Couleur par défaut pour les autres vendeurs
          }

          return ListTile(
            title: Text(
              vendeur.nom,
              style: TextStyle(
                color: itemColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(vendeur.mail),
            trailing: Text(
              '$nombreDeVentes ventes',
              style: TextStyle(
                color: itemColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
      // Le reste de votre code reste inchangé
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
