import 'package:challenge_app/screen/vendeur/screen_cagnotte.dart';
import 'package:challenge_app/screen/vendeur/screen_vente.dart';
import 'package:flutter/material.dart';
import 'screen/gerant/home_gerant.dart';
import 'screen/vendeur/home_vendeur.dart';
import 'screen/gerant/login_gerant.dart';
import 'screen/vendeur/login_vendeur.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:challenge_app/screen/admin/login_admin.dart'; // Importez la page de connexion de l'administrateur
import 'package:challenge_app/screen/admin/home_admin.dart'; // Importez la page d'accueil de l'administrateur


Future<void> main() async {
  runApp(ChallengeApp());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class ChallengeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Challenge App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => ChallengePage(),
        '/login_gerant': (context) => LoginGerantPage(),
        '/login_vendeur': (context) => LoginVendeurPage(),
        '/login_admin': (context) => LoginAdminPage(), // Ajoutez la route de la page de connexion de l'administrateur
        '/home_gerant': (context) => HomeGerantPage(),
        '/home_vendeur': (context) => HomeVendeurPage(),
        '/home_admin': (context) => HomeAdminPage(), // Ajoutez la route de la page d'accueil de l'administrateur
        '/screenCagnotte': (context) => ScreenCagnotte(vendeurId: 0),
        '/screenVente': (context) => ScreenVente(vendeurId: 0),
      },
    );
  }
}

class ChallengePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Challenge Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Connectez-vous en tant que :',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login_vendeur');
              },
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                child: Text('Vendeur'),
              ),
            ),
            Text(
              'Ou',
              style: TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login_gerant');
              },
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                child: Text('Gérant'),
              ),
            ),
            Text(
              'Ou', // Ajoutez un autre texte pour séparer les boutons
              style: TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login_admin'); // Ajoutez la navigation vers la page de connexion de l'administrateur
              },
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                child: Text('Administrateur'), // Texte pour le bouton "Administrateur"
              ),
            ),
          ],
        ),
      ),
    );
  }
}
