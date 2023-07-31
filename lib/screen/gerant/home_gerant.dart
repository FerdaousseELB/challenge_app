import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../model/vendeur_model.dart';

class HomeGerantPage extends StatefulWidget {
  @override
  _HomeGerantPageState createState() => _HomeGerantPageState();
}

class _HomeGerantPageState extends State<HomeGerantPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  List<Vendeur> _listeDesVendeurs = [];

  @override
  void initState() {
    super.initState();
    _fetchVendeurs();
  }

  // Méthode pour récupérer les vendeurs associés au gérant connecté
  Future<void> _fetchVendeurs() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "";

    final emailParts = email.split("@");
    final emailStart = emailParts.length > 0 ? emailParts[0] : "";

    try {
      final event = await ref.child('gerants').orderByChild('mail').equalTo(email).once();
      final gerantData = event.snapshot.value;

      if (gerantData == null) {
        print('Gérant non trouvé dans la base de données.');
        return;
      }

      List<dynamic> gerantList;
      if (gerantData is List<dynamic>) {
        gerantList = gerantData;
      } else if (gerantData is Map<String, dynamic>) {
        gerantList = gerantData.values.toList();
      } else {
        gerantList = [];
      }

      final gerant = gerantList.firstWhere((element) => element != null, orElse: () => null);

      if (gerant != null) {
        final pointDeVenteId = gerant['point_de_vente_id'];
        final event = await ref.child('vendeurs').orderByChild('point_de_vente_id').equalTo(pointDeVenteId).get();

        if (event.exists) {
          final vendeurList = (event.value as Map<String, dynamic>).values.toList();
          _listeDesVendeurs = vendeurList.map((vendeurData) => _createVendeurFromData(vendeurData)).toList();
          setState(() {});
        } else {
          print('No data available.');
        }
      }
    } catch (error) {
      print('Erreur lors de la récupération des données : $error');
    }
  }

  Vendeur _createVendeurFromData(Map<dynamic, dynamic> vendeurData) {
    final cagnottesJson = vendeurData['cagnottes'] as Map<dynamic, dynamic>;
    final Map<String, double> cagnottes = {};

    if (cagnottesJson != null) {
      cagnottesJson.forEach((key, value) {
        if (key is String && value is num) {
          cagnottes[key] = value.toDouble();
        }
      });
    }

    return Vendeur(
      id: vendeurData['ID'],
      nom: vendeurData['nom'],
      mail: vendeurData['mail'],
      pointDeVenteId: vendeurData['point_de_vente_id'],
      cagnottes: cagnottes,
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
            Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
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
            return ListTile(
              title: Text(vendeur.nom),
              subtitle: Text(vendeur.mail),
              onTap: () {
                // Mettez ici la logique pour gérer la navigation vers la page du vendeur
              },
            );
          },
        ),
      ),
    );
  }
}
