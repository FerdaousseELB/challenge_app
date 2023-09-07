import 'package:challenge_app/model/store_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../model/gerant_model.dart';

class ScreenGerants extends StatefulWidget {
  final String? token;

  ScreenGerants({this.token});

  @override
  _ScreenGerantsState createState() => _ScreenGerantsState();
}

class _ScreenGerantsState extends State<ScreenGerants> {
  List<Gerant> gerants = [];
  List<String> pointsDeVenteDisponibles = [];
  List<Store> pointsDeVente = [];

  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _mailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? selectedPointDeVente;

  @override
  void initState() {
    super.initState();
    fetchGerants();
    fetchPointsDeVente();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _mailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> fetchGerants() async {
    final response = await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/gerants.json?auth=${widget.token}'));
    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body);
      if (data != null) {
        final nonNullData = data.where((item) => item != null).toList();
        gerants = nonNullData
            .map((gerant) => Gerant.fromJson(gerant))
            .toList();
        print('Nombre de gérants récupérés : ${gerants.length}');
        setState(() {});
      }
    } else {
      print('Erreur lors de la récupération des gérants : ${response.statusCode}');
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
            .where((point) =>
        !gerants.any((gerant) => gerant.pointDeVenteId == point.id))
            .map((point) => point.nom)
            .toList();
        setState(() {});
      }
    } else {
      print(
          'Erreur lors de la récupération des points de vente : ${response.statusCode}');
    }
  }

  int? getPointDeVenteIdByName(String? pointDeVenteNom) {
    final store = pointsDeVente.firstWhere(
          (point) => point.nom == pointDeVenteNom,
      orElse: () => Store(id: 6, nom: '', adresse: ''),
    );

    return store.id;
  }

  Future<void> createGerant() async {
    if (_formKey.currentState!.validate()) {
      int maxId = 0;
      gerants.forEach((gerant) {
        if (gerant.id > maxId) {
          maxId = gerant.id;
        }
      });
      final newGerantId = maxId + 1;

      try {
        final authResult = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _mailController.text, password: _passwordController.text);

        if (authResult.user != null) {
          final selectedPointId = getPointDeVenteIdByName(selectedPointDeVente);

          if (selectedPointId != null) {
            final newGerant = Gerant(
              id: newGerantId,
              nom: _nomController.text,
              mail: _mailController.text,
              pointDeVenteId: selectedPointId,
            );

            final response = await http.put(
              Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/gerants/$newGerantId.json?auth=${widget.token}'),
              body: json.encode(newGerant.toJson()),
            );

            if (response.statusCode == 200) {
              await fetchGerants();
              fetchPointsDeVente();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gérant créé avec succès.'),
                ),
              );

              // Réinitialiser les champs du formulaire et la liste déroulante
              _nomController.clear();
              _mailController.clear();
              _passwordController.clear();
              setState(() {
                selectedPointDeVente = null;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur lors de la création du gérant.'),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Point de vente non trouvé.'),
              ),
            );
          }
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
        title: Text('Gérants'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: gerants.length,
              itemBuilder: (context, index) {
                final gerant = gerants[index];
                return ListTile(
                  title: Text(gerant.nom),
                  subtitle: Text(gerant.mail),
                );
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
                title: Text('Créer un Gérant'),
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
                    onPressed: (pointsDeVenteDisponibles.isEmpty ||
                        _nomController.text.isEmpty ||
                        _mailController.text.isEmpty ||
                        _passwordController.text.isEmpty)
                        ? null
                        : () {
                      createGerant();
                      Navigator.of(context).pop();
                    },
                    child: Text('Créer Gérant'),
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
