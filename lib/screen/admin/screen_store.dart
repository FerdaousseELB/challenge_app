import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../model/store_model.dart';

class ScreenStore extends StatefulWidget {
  final String? token;

  ScreenStore({this.token});

  @override
  _ScreenStoreState createState() => _ScreenStoreState();
}

class _ScreenStoreState extends State<ScreenStore> {

  Future<List<Store>> fetchPointsDeVente() async {
    final response = await http.get(Uri.parse('https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app/pointsDeVente.json?auth=${widget.token}'));
    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body);
      if (data != null) {
        final nonNullData = data.where((item) => item != null).toList();
        final List<Store> pointsDeVente = nonNullData
            .map((store) => Store.fromJson(store))
            .toList();
        return pointsDeVente;
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Les points de vente'),
      ),
      body: FutureBuilder<List<Store>>(
        future: fetchPointsDeVente(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Erreur : ${snapshot.error}');
          } else {
            final pointsDeVente = snapshot.data ?? [];

            if (pointsDeVente.isEmpty) {
              return Text('Aucun point de vente trouvé.');
            }

            return ListView.builder(
              itemCount: pointsDeVente.length,
              itemBuilder: (context, index) {
                final pointDeVente = pointsDeVente[index];

                return ListTile(
                  title: Text(pointDeVente.nom),
                  subtitle: Text(pointDeVente.adresse),
                );
              },
            );
          }
        },
      ),
    );
  }
}
