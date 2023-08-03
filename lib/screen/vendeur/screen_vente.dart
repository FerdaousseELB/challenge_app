import 'package:flutter/material.dart';
import 'package:challenge_app/service/vente_service.dart';
import 'package:challenge_app/model/vente_model.dart';
import 'package:challenge_app/model/produit_model.dart';
import 'package:challenge_app/service/produit_service.dart';

class ScreenVente extends StatefulWidget {
  final int vendeurId;

  ScreenVente({required this.vendeurId});

  @override
  _ScreenVenteState createState() => _ScreenVenteState();
}

class _ScreenVenteState extends State<ScreenVente> {
  List<Vente> _ventes = []; // Liste mutable
  List<Produit> _produits = []; // Liste mutable des produits

  @override
  void initState() {
    super.initState();
    _fetchProduits();
    _fetchVentes();
  }

  Future<void> _fetchProduits() async {
    final produits = await ProduitService.fetchProduits();
    setState(() {
      _produits.addAll(produits);
    });
  }

  Future<void> _fetchVentes() async {
    final ventes = await VenteService.fetchVentesByVendeurId(widget.vendeurId);
    setState(() {
      _ventes.addAll(ventes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes ventes'),
        actions: [
          IconButton(
            icon: Icon(Icons.sort_by_alpha),
            onPressed: () {
              setState(() {
                _sortVentesByNom(); // Tri par nom de produit
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              setState(() {
                _sortVentesByDate(); // Tri par date de vente
              });
            },
          ),
        ],
      ),
      body: Center(
        child: ListView.builder(
          itemCount: _ventes.length,
          itemBuilder: (context, index) {
            Vente vente = _ventes[index];

            String venteInfo = _getVenteInfo(vente);

            return Card(
              child: ListTile(
                title: Text(venteInfo),
              ),
            );
          },
        ),
      ),
    );
  }

  void _sortVentesByNom() {
    _ventes.sort((vente1, vente2) {
      String nomProduit1 = _getNomProduit(vente1);
      String nomProduit2 = _getNomProduit(vente2);
      return nomProduit1.compareTo(nomProduit2);
    });
  }

  void _sortVentesByDate() {
    _ventes.sort((vente1, vente2) {
      return vente1.heureDeVente.compareTo(vente2.heureDeVente);
    });
  }

  String _getVenteInfo(Vente vente) {
    // Recherche du produit correspondant à la vente
    Produit produit = _produits.firstWhere((produit) => produit.id == vente.produitId, orElse: () => Produit(id: -1, nom: ""));

    // Construction de l'information de vente avec le nom du produit
    String venteInfo = 'Vente du produit : ${produit.nom} - ${vente.heureDeVente.toLocal()}';

    return venteInfo;
  }

  String _getNomProduit(Vente vente) {
    Produit produit = _produits.firstWhere((produit) => produit.id == vente.produitId, orElse: () => Produit(id: -1, nom: ""));
    return produit.nom;
  }
}
