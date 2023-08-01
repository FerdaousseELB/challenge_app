import 'package:challenge_app/model/produit_model.dart';
import 'package:challenge_app/model/vendeur_model.dart';
import 'package:challenge_app/model/vente_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../service/produit_service.dart';
import '../../service/vendeur_service.dart';
import '../../service/vente_service.dart';

class HomeVendeurPage extends StatefulWidget {
  @override
  _HomeVendeurPageState createState() => _HomeVendeurPageState();
}

class _HomeVendeurPageState extends State<HomeVendeurPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Produit> _products = [];
  double? _cagnotteMoisEnCours;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchCagnotteMoisEnCours();
  }

  Future<void> _fetchProducts() async {
    final produits = await ProduitService.fetchProduits();
    setState(() {
      _products.addAll(produits);
    });
  }

  Future<void> _fetchCagnotteMoisEnCours() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "";

    final vendeur = await VendeurService.getVendeurByEmail(email);

    if (vendeur != null) {
      final currentMonthYear = DateTime.now().toString().substring(0, 7);

      setState(() {
        _cagnotteMoisEnCours = vendeur.cagnottes[currentMonthYear];
      });
    }
  }

  void _addVente(Produit produit) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "";

    final vendeur = await VendeurService.getVendeurByEmail(email);

    if (vendeur != null) {
      final ventes = await VenteService.fetchVentes();

      int maxId = 0;
      for (var vente in ventes) {
        if (vente.id > maxId) {
          maxId = vente.id;
        }
      }

      final nouvelleVente = Vente(
        id: maxId + 1,
        produitId: produit.id,
        vendeurId: vendeur.id,
        heureDeVente: DateTime.now().toUtc(),
      );

      await VenteService.addVente(nouvelleVente);

      final moisEnCours = DateTime.now().toString().substring(0, 7);
      final nouvelleCagnotte = (vendeur.cagnottes[moisEnCours] ?? 0) + 2.5;
      await VendeurService.updateCagnotte(vendeur.id, moisEnCours, nouvelleCagnotte);

      final nombreVentes = await VenteService.getNombreVentes(produit.id, vendeur.id);

      setState(() {
        vendeur.cagnottes[moisEnCours] = nouvelleCagnotte;
      });
    }
  }

  void _decrementVente(int produitId) {
    // Mettez ici la logique pour décrémenter le nombre de ventes du produit dans la base de données
  }

  Future<int> _fetchVendeurIdByEmail(String email) async {
    final vendeurs = await VendeurService.fetchVendeurs();
    final vendeur = vendeurs.firstWhere(
          (vendeur) => vendeur.mail == email,
      orElse: () => Vendeur(id: -1, nom: "", mail: "", pointDeVenteId: 0, cagnottes: {}),
    );
    return vendeur.id;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "";

    final emailParts = email.split("@");
    final emailStart = emailParts.length > 0 ? emailParts[0] : "";

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
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
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu Vendeur',
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
                // Mettez ici la logique pour gérer la navigation vers la page des ventes du vendeur
              },
            ),
            ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text('Cagnottes'),
              onTap: () {
                // Mettez ici la logique pour gérer la navigation vers la page des cagnottes du vendeur
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: SizedBox(
          width: 350,
          child: ListView.builder(
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final produit = _products[index];

              return Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          produit.nom,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      FutureBuilder<int>(
                        future: () async {
                          int vendeurId = await _fetchVendeurIdByEmail(email);
                          return VenteService.getNombreVentes(produit.id, vendeurId);
                        }(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Erreur');
                          } else {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    _decrementVente(produit.id);
                                  },
                                ),
                                Text(
                                  '${snapshot.data}',
                                  style: TextStyle(fontSize: 18),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    _addVente(produit);
                                  },
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.blue,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ma cagnotte',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 8),
            Text(
              '${_cagnotteMoisEnCours ?? 0} €',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

