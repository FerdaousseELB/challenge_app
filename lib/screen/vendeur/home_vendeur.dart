import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../service/produit_service.dart';
import '../../service/vendeur_service.dart';
import '../../service/vente_service.dart';
import 'package:challenge_app/model/produit_model.dart';
import 'package:challenge_app/model/vendeur_model.dart';
import 'package:challenge_app/model/vente_model.dart';
import 'package:challenge_app/screen/vendeur/screen_cagnotte.dart';
import 'package:challenge_app/screen/vendeur/screen_vente.dart';

class HomeVendeurPage extends StatefulWidget {
  final String? token; // Déclarez le paramètre token

  HomeVendeurPage({this.token}); // Ajoutez un constructeur qui prend le paramètre token

  @override
  _HomeVendeurPageState createState() => _HomeVendeurPageState();
}

class _HomeVendeurPageState extends State<HomeVendeurPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Produit> _products = [];
  double? _cagnotteMoisEnCours;
  late int vendeurId;
  bool _isUpdatingCagnotte = false; // Nouvelle variable pour indiquer si la cagnotte est en cours de mise à jour

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchCagnotteMoisEnCours();
    _fetchVendeurId();
  }

  Future<void> _fetchProducts() async {
    final produits = await ProduitService.fetchProduits(widget.token);
    setState(() {
      _products.addAll(produits);
    });
  }

  Future<void> _fetchCagnotteMoisEnCours() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "";

    final vendeur = await VendeurService.getVendeurByEmail(email, widget.token);

    if (vendeur != null) {
      final currentDate = DateTime.now();
      final currentMonthYear = '${currentDate.month.toString().padLeft(2, '0')}${currentDate.year}';

      setState(() {
        _cagnotteMoisEnCours = vendeur.cagnottes[currentMonthYear];
      });
    }
  }

  void _addVente(Produit produit) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "";

    final vendeur = await VendeurService.getVendeurByEmail(email, widget.token);

    if (vendeur != null) {
      if (!_isUpdatingCagnotte) { // Vérifier si la cagnotte n'est pas en cours de mise à jour
        setState(() {
          _isUpdatingCagnotte = true; // Mettre à jour le booléen pour indiquer que la cagnotte est en cours de mise à jour
        });

        final ventes = await VenteService.fetchVentes(widget.token);

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

        await VenteService.addVente(nouvelleVente, widget.token);

        final moisEnCours = '${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().year}';

        final nouvelleCagnotte = (vendeur.cagnottes[moisEnCours] ?? 0) + 2.5;
        await VendeurService.updateCagnotte(vendeur.id, moisEnCours, nouvelleCagnotte, widget.token);

        setState(() {
          vendeur.cagnottes[moisEnCours] = nouvelleCagnotte;
          _cagnotteMoisEnCours = nouvelleCagnotte;
          _isUpdatingCagnotte = false; // Mettre à jour le booléen pour indiquer que la cagnotte a fini d'être mise à jour
        });
      }
    }
  }

  void _decrementVente(int produitId) {
    // Mettez ici la logique pour décrémenter le nombre de ventes du produit dans la base de données
  }

  Future<int> _fetchVendeurIdByEmail(String email) async {
    final vendeurs = await VendeurService.fetchVendeurs(widget.token);
    final vendeur = vendeurs.firstWhere(
          (vendeur) => vendeur.mail == email,
      orElse: () => Vendeur(id: -1, nom: "", mail: "", pointDeVenteId: 0, cagnottes: {}),
    );
    return vendeur.id;
  }

  Future<void> _fetchVendeurId() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "";

    final vendeurs = await VendeurService.fetchVendeurs(widget.token);
    final vendeur = vendeurs.firstWhere(
          (vendeur) => vendeur.mail == email,
      orElse: () => Vendeur(id: -1, nom: "", mail: "", pointDeVenteId: 0, cagnottes: {}),
    );

    setState(() {
      vendeurId = vendeur.id;
    });
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScreenVente(vendeurId: vendeurId, token: widget.token)),
                ).then((_) {
                  // Cette fonction sera appelée lorsque vous reviendrez de la page ScreenVente
                  // Vous pouvez y fermer le menu en utilisant Navigator.pop
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text('Cagnottes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScreenCagnotte(vendeurId: vendeurId, token: widget.token)),
                ).then((_) {
                  // Cette fonction sera appelée lorsque vous reviendrez de la page ScreenCagnotte
                  // Vous pouvez y fermer le menu en utilisant Navigator.pop
                  Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: SizedBox(
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
                      Container(
                        width: 55, // Ajustez la largeur du carré selon vos préférences
                        height: 55, // Ajustez la hauteur du carré selon vos préférences
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('images/${produit.nom}.jpg'),
                            fit: BoxFit.cover, // Ajustez le mode de redimensionnement selon vos préférences
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          produit.nom,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      FutureBuilder<int>(
                        future: () async {
                          int vendeurId = await _fetchVendeurIdByEmail(email);
                          return VenteService.getNombreVentes(produit.id, vendeurId, widget.token);
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
                                Container(
                                  width: 40, // Ajustez la largeur selon vos préférences
                                  height: 40, // Ajustez la hauteur selon vos préférences
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue, // Couleur du cercle
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      _decrementVente(produit.id);
                                    },
                                    color: Colors.white, // Couleur de l'icône
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '${snapshot.data}',
                                  style: TextStyle(fontSize: 18),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  width: 40, // Ajustez la largeur selon vos préférences
                                  height: 40, // Ajustez la hauteur selon vos préférences
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue, // Couleur du cercle
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      _addVente(produit);
                                    },
                                    // Désactiver le bouton d'ajout de vente pendant la mise à jour de la cagnotte
                                    // en vérifiant la valeur de _isUpdatingCagnotte
                                    disabledColor: _isUpdatingCagnotte ? Colors.grey : null,
                                  ),
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
