import 'package:flutter/material.dart';
import 'package:challenge_app/service/vendeur_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScreenCagnotte extends StatefulWidget {
  final int vendeurId;
  final String? token;
  ScreenCagnotte({required this.vendeurId, this.token});
  @override
  _ScreenCagnotteState createState() => _ScreenCagnotteState();
}

class _ScreenCagnotteState extends State<ScreenCagnotte> {
  List<String> _cagnottes = [];

  @override
  void initState() {
    super.initState();
    _fetchCagnottes();
  }

  Future<void> _fetchCagnottes() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "";

    final vendeur = await VendeurService.getVendeurByEmail(email, widget.token);

    if (vendeur != null) {
      setState(() {
        _cagnottes = vendeur.cagnottes.entries.map((entry) => "${entry.key.substring(0, 2)} - ${entry.key.substring(2, 6)} : ${entry.value} €").toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes cagnottes'),
      ),
      body: Center(
        child: SizedBox(
          width: 350,
          child: ListView.builder(
            itemCount: _cagnottes.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(
                    _cagnottes[index],
                    style: TextStyle(fontSize: 18),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
