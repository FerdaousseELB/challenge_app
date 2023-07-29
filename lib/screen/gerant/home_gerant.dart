import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeGerantPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "";

    // Récupérer la partie du mail avant le "@"
    final emailParts = email.split("@");
    final emailStart = emailParts.length > 0 ? emailParts[0] : "";

    return Scaffold(
      key: _scaffoldKey, // Ajouter la clé au Scaffold
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
                    // Ouvrir le menu en utilisant la clé du Scaffold
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
      ),
      body: Center(
        child: Text('Contenu de la page gérant'),
      ),
    );
  }
}
