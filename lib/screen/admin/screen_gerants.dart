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
  List<Gerant> gerants = []; // Remplacez "Gerant" par le nom de votre modèle de gérant

  @override
  void initState() {
    super.initState();
    fetchGerants();
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gérants'),
      ),
        body: Container(
          child: ListView.builder(
            itemCount: gerants.length,
            itemBuilder: (context, index) {
              final gerant = gerants[index];
              return ListTile(
                title: Text(gerant.nom),
                subtitle: Text(gerant.mail),
                // Ajoutez d'autres informations sur le gérant ici
              );
            },
          ),
        ),
    );
  }
}
