/*import 'package:challenge_app/model/produit_model.dart';
import 'package:challenge_app/model/vendeur_model.dart';
import 'package:challenge_app/model/vente_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    final response = await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/produits.json'));
    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body);
      if (data != null) {
        final nonNullData = data.where((item) => item != null).toList(); // Filtrer les éléments non null
        _products.addAll(nonNullData.map((item) => Produit.fromJson(item)).toList());
        setState(() {});
      }
    }
  }

  /*Future<List<Vente>> _fetchVentes() async {
    final response = await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/ventes.json'));
    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body);
      if (data != null) {
        final List<Vente> ventes = data
            .where((item) => item != null) // Filtrer les éléments null
            .map((item) => Vente.fromJson(item))
            .toList();
        return ventes;
      }
    }
    return [];
  }*/

  Future<void> _fetchCagnotteMoisEnCours() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "";

    // Récupérer la liste des vendeurs à partir de la base de données
    final List<Vendeur> vendeurs = await _fetchVendeurs();

    // Filtrer les vendeurs en fonction de l'email
    final vendeur = vendeurs.firstWhere((vendeur) => vendeur.mail == email, orElse: () => Vendeur(id: -1, nom: "", mail: "", pointDeVenteId: "", cagnottes: {}));

    // Vérifier si le vendeur a été trouvé (si l'id est différent de -1)
    if (vendeur.id != -1) {
      // Récupérer le mois actuel (au format "mmYYYY")
      final currentDate = DateTime.now();
      final currentMonthYear = "${currentDate.month.toString().padLeft(2, '0')}${currentDate.year}";

      // Récupérer la cagnotte du mois en cours depuis les données du vendeur
      _cagnotteMoisEnCours = vendeur.cagnottes[currentMonthYear];
    }

    setState(() {});
  }


  Future<List<Vendeur>> _fetchVendeurs() async {
    final response = await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/vendeurs.json'));
    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body);
      if (data != null) {
        final List<Vendeur> vendeurs = data
            .where((item) => item != null) // Filtrer les éléments null
            .map((item) => Vendeur.fromJson(item))
            .toList();
        return vendeurs;
      }
    }
    return [];
  }

  Future<List<Vente>> _fetchVentes() async {
    final response = await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/ventes.json'));
    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body);
      if (data != null) {
        final List<Vente> ventes = data
            .where((item) => item != null) // Filtrer les éléments null
            .map((item) => Vente.fromJson(item))
            .toList();
        return ventes;
      }
    }
    return [];
  }


  Future<int> _getNombreVentes(int produitId) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "";

    // Récupérer la liste des vendeurs à partir de la base de données
    final List<Vendeur> vendeurs = await _fetchVendeurs();

    // Filtrer les vendeurs en fonction de l'email
    final vendeur = vendeurs.firstWhere((vendeur) => vendeur.mail == email, orElse: () => Vendeur(id: -1, nom: "", mail: "", pointDeVenteId: "", cagnottes: {}));

    // Vérifier si le vendeur a été trouvé (si l'id est différent de -1)
    if (vendeur.id != -1) {
      final List<Vente> ventes = await _fetchVentes();

      // Obtenir la date du premier jour du mois en cours
      final currentDate = DateTime.now();
      final firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);

      int nombreVentes = 0;
      for (var vente in ventes) {
        if (vente.vendeurId == vendeur.id && vente.produitId == produitId) {
          // Vérifier si la date de la vente est dans le mois en cours
          if (vente.heureDeVente.isAfter(firstDayOfMonth) || vente.heureDeVente == firstDayOfMonth) {
            nombreVentes++;
          }
        }
      }
      return nombreVentes;
    }

    // Si le vendeur n'a pas été trouvé, renvoyer -1 pour indiquer une erreur ou une absence de vendeur avec cet email
    return -1;
  }


  void _addVente(Produit produit) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "";

    // Récupérer la liste des vendeurs à partir de la base de données
    final List<Vendeur> vendeurs = await _fetchVendeurs();

    // Filtrer les vendeurs en fonction de l'email
    final vendeur = vendeurs.firstWhere((vendeur) => vendeur.mail == email, orElse: () => Vendeur(id: -1, nom: "", mail: "", pointDeVenteId: "", cagnottes: {}));

    // Vérifier si le vendeur a été trouvé (si l'id est différent de -1)
    if (vendeur.id != -1) {
      // Créer une nouvelle vente avec les détails appropriés
      // Récupérer la liste des ventes à partir de la base de données
      final List<Vente> ventes = await _fetchVentes();

      // Trouver le plus grand ID actuel dans la liste des ventes
      int maxId = 0;
      for (var vente in ventes) {
        if (vente.id > maxId) {
          maxId = vente.id;
        }
      }

      // Créer une nouvelle vente avec le nouvel ID en ajoutant 1 au plus grand ID trouvé
      final vente = Vente(
        id: maxId + 1, // Utiliser le nouvel ID pour la nouvelle vente
        produitId: produit.id,
        vendeurId: vendeur.id,
        heureDeVente: DateTime.now().toUtc(),
      );

      // Effectuer une requête POST vers Firebase pour ajouter la nouvelle vente
      final response = await http.post(
        Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/ventes.json'),
        body: json.encode(vente.toJson()),
      );

      if (response.statusCode == 200) {
        // Mettre à jour la cagnotte du mois en cours en ajoutant 2.5 €
        final moisEnCours = DateTime.now().month.toString().padLeft(2, '0') + DateTime.now().year.toString();
        final nouvelleCagnotte = (vendeur.cagnottes[moisEnCours] ?? 0) + 2.5;

        // Effectuer une requête POST vers Firebase pour mettre à jour la cagnotte
        await http.patch(
          Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/vendeurs/${vendeur.id}.json'),
          body: json.encode({"cagnottes": {moisEnCours: nouvelleCagnotte}}),
        );

        // Mettre à jour la liste des ventes et la cagnotte dans l'état de la page
        final nombreVentes = await _getNombreVentes(produit.id);
        setState(() {
         // produit.nombreVentes = nombreVentes;
          vendeur.cagnottes[moisEnCours] = nouvelleCagnotte;
        });
      }
    }
  }


  // Fonction pour décrémenter le nombre de ventes d'un produit
  void _decrementVente(int produitId) {
    // Mettez ici la logique pour décrémenter le nombre de ventes du produit dans la base de données
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
                        future: _getNombreVentes(produit.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator(); // Afficher un indicateur de chargement en attendant la résolution de la Future
                          } else if (snapshot.hasError) {
                            return Text('Erreur'); // Gérer l'erreur s'il y en a une
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
                                    //_addVente(produit);
                                    _decrementVente(produit.id);
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
              '$_cagnotteMoisEnCours €',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
*/

import 'package:challenge_app/model/produit_model.dart';
import 'package:challenge_app/model/vendeur_model.dart';
import 'package:challenge_app/model/vente_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      orElse: () => Vendeur(id: -1, nom: "", mail: "", pointDeVenteId: "", cagnottes: {}),
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

