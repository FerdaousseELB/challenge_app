import 'package:flutter/material.dart';
import 'package:challenge_app/service/vente_service.dart';
import 'package:challenge_app/model/vente_model.dart';

class ScreenVente extends StatelessWidget {
  final int vendeurId;

  ScreenVente({required this.vendeurId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes ventes'),
      ),
      body: Center(
        child: FutureBuilder<List<Vente>>(
          future: VenteService.fetchVentesByVendeurId(vendeurId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Erreur lors du chargement des ventes');
            } else {
              List<Vente> ventes = snapshot.data ?? []; // Liste des ventes

              return ListView.builder(
                itemCount: ventes.length,
                itemBuilder: (context, index) {
                  Vente vente = ventes[index];

                  String venteInfo = 'Vente ${vente.id} - ${vente.heureDeVente.toLocal()}';

                  return Card(
                    child: ListTile(
                      title: Text(venteInfo),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
