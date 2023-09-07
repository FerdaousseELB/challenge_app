import 'package:challenge_app/screen/admin/screen_gerants.dart';
import 'package:challenge_app/screen/admin/screen_store.dart';
import 'package:challenge_app/screen/admin/screen_vendeurs.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../model/VendeurAvecVentes.dart';
import '../../model/store_model.dart';
import '../../model/vendeur_model.dart';
import '../../model/vente_model.dart';

class HomeAdminPage extends StatefulWidget {
  final String? token;

  HomeAdminPage({this.token});

  @override
  _HomeAdminPageState createState() => _HomeAdminPageState();
}

class _HomeAdminPageState extends State<HomeAdminPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Store> pointsDeVente = [];
  List<Vente> ventes = [];
  List<Vendeur> vendeurs = [];
  List<VendeurAvecVentes> vendeursAvecVentes = [];

  @override
  void initState() {
    super.initState();
    fetchVendeurs();
    fetchPointsDeVente();
    fetchVentes(); // Chargez d'abord les ventes et les vendeurs
  }

  Future<void> fetchPointsDeVente() async {
    final response = await http.get(
        Uri.parse(
            'https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/pointsDeVente.json?auth=${widget.token}'));

    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body);
      if (data != null) {
        setState(() {
          final nonNullData = data.where((item) => item != null).toList();
          pointsDeVente = nonNullData
              .map((store) => Store.fromJson(store))
              .toList();

          // Triez la liste des points de vente par ordre décroissant du nombre de ventes
          pointsDeVente.sort((a, b) {
            final nombreDeVentesA = ventes.where((vente) =>
            vendeurs
                .firstWhere(
                  (vendeur) => vendeur.id == vente.vendeurId,
              orElse: () => Vendeur(
                id: -1,
                nom: '',
                mail: '',
                pointDeVenteId: -1,
                cagnottes: {},
              ),
            )
                .pointDeVenteId == a.id)
                .length;
            final nombreDeVentesB = ventes.where((vente) =>
            vendeurs
                .firstWhere(
                  (vendeur) => vendeur.id == vente.vendeurId,
              orElse: () => Vendeur(
                id: -1,
                nom: '',
                mail: '',
                pointDeVenteId: -1,
                cagnottes: {},
              ),
            )
                .pointDeVenteId == b.id)
                .length;

            return nombreDeVentesB.compareTo(nombreDeVentesA);
          });
        });
      }
    }
  }

  Future<void> fetchVendeurs() async {
    final response = await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/vendeurs.json?auth=${widget.token}'));
    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body);
      if (data != null) {
        setState(() {
          vendeurs = data
              .where((item) => item != null)
              .map((item) => Vendeur.fromJson(item))
              .toList();

          // Compter le nombre de ventes pour chaque vendeur
          vendeursAvecVentes = vendeurs.map((vendeur) {
            final nombreDeVentes = ventes.where((vente) => vente.vendeurId == vendeur.id).length;
            return VendeurAvecVentes(vendeur, nombreDeVentes);
          }).toList();

          // Triez la liste des vendeurs en ordre décroissant en fonction du nombre de ventes
          vendeursAvecVentes.sort((a, b) => b.nombreDeVentes.compareTo(a.nombreDeVentes));

          setState(() {});
        });
      }
    }
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

        setState(() {
          // Mise à jour de la variable 'ventes'
          this.ventes = ventes;

          // Réinitialisation de 'vendeursAvecVentes'
          vendeursAvecVentes.clear();

          // Compter le nombre de ventes pour chaque vendeur
          vendeursAvecVentes = vendeurs.map((vendeur) {
            final nombreDeVentes = ventes.where((vente) => vente.vendeurId == vendeur.id).length;
            return VendeurAvecVentes(vendeur, nombreDeVentes);
          }).toList();

          // Triez la liste des vendeurs en ordre décroissant en fonction du nombre de ventes
          vendeursAvecVentes.sort((a, b) => b.nombreDeVentes.compareTo(a.nombreDeVentes));
        });
      }
    } else {
      print('Erreur lors de la récupération des ventes : ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "";

    final emailParts = email.split("@");
    final emailStart = emailParts.length > 0 ? emailParts[0] : "";

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(emailStart),
      drawer: _buildDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 8),
            Expanded(
              child: ListView.builder(
                itemCount: 2, // Deux listes à afficher
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Première liste : Les 3 premiers points de vente
                    return _buildTopPointsDeVente();
                  } else {
                    // Deuxième liste : Les 3 premiers vendeurs
                    return _buildTopVendeurs();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPointsDeVente() {
    return Column(
      children: [
        Text(
          'Les 3 premiers points de vente',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          itemCount: pointsDeVente.length > 3 ? 3 : pointsDeVente.length,
          itemBuilder: (context, index) {
            final pointDeVente = pointsDeVente[index];
            final nombreDeVentes = ventes.where((vente) =>
            vendeurs
                .firstWhere(
                  (vendeur) => vendeur.id == vente.vendeurId,
              orElse: () => Vendeur(
                id: -1,
                nom: '',
                mail: '',
                pointDeVenteId: -1,
                cagnottes: {},
              ),
            )
                .pointDeVenteId == pointDeVente.id)
                .length;

            return Card(
              elevation: 3, // L'ombre de la carte
              margin: EdgeInsets.all(8), // Marge autour de la carte
              child: ListTile(
                title: Text(pointDeVente.nom,
                    style: TextStyle(
                        color: _getPointDeVenteTextColor(index))),
                subtitle: Text('Nombre de ventes: $nombreDeVentes',
                    style: TextStyle(
                        color: _getPointDeVenteTextColor(index))),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTopVendeurs() {
    return Column(
      children: [
        Text(
          'Les 3 premiers vendeurs',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          itemCount: vendeursAvecVentes.length > 3
              ? 3
              : vendeursAvecVentes.length,
          itemBuilder: (context, index) {
            final vendeurAvecVentes = vendeursAvecVentes[index];

            return Card(
              elevation: 3, // L'ombre de la carte
              margin: EdgeInsets.all(8), // Marge autour de la carte
              child: ListTile(
                title: Text(vendeurAvecVentes.vendeur.nom,
                    style: TextStyle(color: _getVendeurTextColor(index))),
                subtitle: Text(
                    'Nombre de ventes: ${vendeurAvecVentes.nombreDeVentes}',
                    style: TextStyle(color: _getVendeurTextColor(index))),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getPointDeVenteTextColor(int index) {
    if (index == 0) {
      return Colors.green;
    } else if (index == 1) {
      return Colors.blue;
    } else {
      return Colors.red;
    }
  }

  Color _getVendeurTextColor(int index) {
    if (index == 0) {
      return Colors.green;
    } else if (index == 1) {
      return Colors.blue;
    } else {
      return Colors.red;
    }
  }

  AppBar _buildAppBar(String emailStart) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              Text('Tableau de bord'),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Text(emailStart),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushNamedAndRemoveUntil(
                context, '/', (Route<dynamic> route) => false);
          },
        ),
      ],
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Points de Vente'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScreenStore(token: widget.token)),
              ).then((_) {
                Navigator.pop(context);
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.person_pin),
            title: Text('Gérants'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScreenGerants(token: widget.token)), // Utilisez votre propre logique de gestion des Gérants ici
              ).then((_) {
                Navigator.pop(context);
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Vendeurs'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScreenVendeurs(token: widget.token)), // Utilisez votre propre logique de gestion des Gérants ici
              ).then((_) {
                Navigator.pop(context);
              });
            },
          ),
        ],
      ),
    );
  }
}
