import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeAdminPage extends StatefulWidget {
  final String? token;

  HomeAdminPage({this.token});

  @override
  _HomeAdminPageState createState() => _HomeAdminPageState();
}

class _HomeAdminPageState extends State<HomeAdminPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bonjour Admin',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }

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
              Text('Accueil Admin'),
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
              'Menu Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.add_location),
            title: Text('Ajout de Point de Vente'),
            onTap: () {
              // Mettez ici la logique pour gérer la navigation vers la page d'ajout de Point de Vente
            },
          ),
          ListTile(
            leading: Icon(Icons.person_add),
            title: Text('Ajout de Gérant'),
            onTap: () {
              // Mettez ici la logique pour gérer la navigation vers la page d'ajout de Gérant
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Ajout de Vendeur'),
            onTap: () {
              // Mettez ici la logique pour gérer la navigation vers la page d'ajout de Vendeur
            },
          ),
        ],
      ),
    );
  }
}
