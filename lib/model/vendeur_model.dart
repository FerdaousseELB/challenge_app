class Vendeur {
  final int id;
  final String nom;
  final String mail;
  final int pointDeVenteId;
  final Map<String, double> cagnottes; // Utiliser des doubles pour les valeurs de cagnottes

  Vendeur({
    required this.id,
    required this.nom,
    required this.mail,
    required this.pointDeVenteId,
    required this.cagnottes,
  });

  factory Vendeur.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? cagnottesJson = json['cagnottes'];
    final Map<String, double> cagnottes = {};

    // Vérifier si 'cagnottesJson' est nul ou non
    if (cagnottesJson != null) {
      cagnottesJson.forEach((key, value) {
        if (value is double || value is int) {
          cagnottes[key] = value.toDouble(); // Convertir la valeur en double
        }
      });
    }

    return Vendeur(
      id: json['ID'],
      nom: json['nom'],
      mail: json['mail'],
      pointDeVenteId: json['point_de_vente_id'],
      cagnottes: cagnottes,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> cagnottesJson = {};
    cagnottes.forEach((key, value) {
      cagnottesJson[key] = value;
    });

    return {
      'ID': id,
      'nom': nom,
      'mail': mail,
      'point_de_vente_id': pointDeVenteId,
      'cagnottes': cagnottesJson,
    };
  }

}
