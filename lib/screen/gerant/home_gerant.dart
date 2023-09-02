import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../model/produit_model.dart';
import '../../model/vendeur_model.dart';
import '../../service/vente_service.dart';

class HomeGerantPage extends StatefulWidget {
  final String? token;

  HomeGerantPage({this.token});

  @override
  _HomeGerantPageState createState() => _HomeGerantPageState();
}

class _HomeGerantPageState extends State<HomeGerantPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Vendeur> _listeDesVendeurs = [];
  List<Produit> _listeDesProduits = [];

  @override
  void initState() {
    super.initState();
    _fetchVendeurs(widget.token);
    _fetchProduits(widget.token);
  }

  Future<void> _fetchVendeurs(String? token) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "";
    int poindDeVente = 0;

    try {
      final apiUrlGerant =
          'https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/gerants.json?auth=$token&orderBy="mail"&equalTo="$email"';
      final responseGerant = await http.get(Uri.parse(apiUrlGerant));
      if (responseGerant.statusCode == 200) {
        final Map<String, dynamic> jsonDataGerant =
        json.decode(responseGerant.body);
        final List<dynamic>? gerants = jsonDataGerant.values.toList();

        if (gerants != null) poindDeVente = gerants[0]['point_de_vente_id'];
      }
      final apiUrl =
          'https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/vendeurs.json?auth=$token&orderBy="point_de_vente_id"&equalTo=$poindDeVente';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic>? data = jsonData.values.toList();
        if (data != null) {
          final List<Vendeur> vendeurs = data
              .where((item) => item != null)
              .map((item) => Vendeur.fromJson(item))
              .toList();
          setState(() {
            _listeDesVendeurs = vendeurs;
          });
        }
      } else {
        print('Échec de la requête : ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur lors de la récupération des données : $error');
    }
  }

  Future<void> _fetchProduits(String? token) async {
    final response = await http.get(
        Uri.parse(
            'https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/produits.json?auth=$token'));
    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body);
      if (data != null) {
        final nonNullData = data.where((item) => item != null).toList();
        final List<Produit> produits = nonNullData.map((item) => Produit.fromJson(item)).toList();
        setState(() {
          _listeDesProduits = produits;
        });
      }
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
        child: ListView.builder(
          itemCount: _listeDesVendeurs.length,
          itemBuilder: (context, index) {
            final vendeur = _listeDesVendeurs[index];
            return _buildVendeurRectangle(vendeur);
          },
        ),
      ),
    );
  }

  // Méthode pour construire l'AppBar
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
              Text('Mes ventes'),
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

  // Méthode pour construire le Drawer
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
              'Menu Gérant',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Ventes'),
            onTap: () {
              // Mettez ici la logique pour gérer la navigation vers la page des ventes du gérant
            },
          ),
          ListTile(
            leading: Icon(Icons.store),
            title: Text('Point de vente'),
            onTap: () {
              // Mettez ici la logique pour gérer la navigation vers la page des points de vente du gérant
            },
          ),
        ],
      ),
    );
  }

  // Méthode pour construire le rectangle pour chaque vendeur
  Widget _buildVendeurRectangle(Vendeur vendeur) {
    return Container(
      width: 200, // Réduire la largeur du rectangle
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1ère ligne : Nom du vendeur
          Center(
            // Centrer le texte
            child: Text(
              vendeur.nom,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8),

          // 2ème ligne : Noms des produits
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var produit in _listeDesProduits)
                Text(
                  produit.nom,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
            ],
          ),
          SizedBox(height: 8),

          // 3ème ligne : Nombre de ventes pour chaque produit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var produit in _listeDesProduits)
                FutureBuilder<int>(
                  future: VenteService.getNombreVentes(produit.id, vendeur.id, widget.token),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Afficher un indicateur de chargement pendant la récupération des données
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // Gérer les erreurs éventuelles lors de la récupération des données
                      return Text('Erreur : ${snapshot.error}');
                    } else {
                      // Afficher le nombre de ventes récupéré
                      return Text(
                        '${snapshot.data ?? 0}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      );
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
