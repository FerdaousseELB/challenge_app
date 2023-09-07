import 'package:challenge_app/model/store_model.dart';
import 'package:challenge_app/model/vendeur_model.dart';

import 'gerant_model.dart';

class PointDeVenteInfo {
  final Store pointDeVente;
  final Gerant gerant;
  final List<Vendeur> vendeurs;

  PointDeVenteInfo({
    required this.pointDeVente,
    required this.gerant,
    required this.vendeurs,
  });
}
