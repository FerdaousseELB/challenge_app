class Vendeur {
  final int id;
  final String nom;
  final String mail;
  final String pointDeVenteId;
  final Map<String, double> cagnottes; // Utiliser des doubles pour les valeurs de cagnottes

  Vendeur({
    required this.id,
    required this.nom,
    required this.mail,
    required this.pointDeVenteId,
    required this.cagnottes,
  });

  factory Vendeur.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> cagnottesJson = json['cagnottes'];
    final Map<String, double> cagnottes = {};
    cagnottesJson.forEach((key, value) {
      cagnottes[key] = value.toDouble(); // Convertir la valeur en double
    });

    return Vendeur(
      id: json['ID'],
      nom: json['nom'],
      mail: json['mail'],
      pointDeVenteId: json['point_de_vente_id'],
      cagnottes: cagnottes,
    );
  }
}
