import 'package:flutter/material.dart';

class ScreenVendeurs extends StatelessWidget {
  final String? token;

  ScreenVendeurs({this.token});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendeurs'),
      ),
      body: Center(
        child: Text('Contenu de la page Vendeurs'),
      ),
    );
  }
}
