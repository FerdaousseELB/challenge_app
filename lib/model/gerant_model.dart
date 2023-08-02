class Gerant {
  final int id;
  final String nom;
  final String mail;
  final int pointDeVenteId;

  Gerant({
    required this.id,
    required this.nom,
    required this.mail,
    required this.pointDeVenteId
  });

  factory Gerant.fromJson(Map<String, dynamic> json) {
    return Gerant(
      id: json['ID'],
      nom: json['nom'],
      mail: json['mail'],
      pointDeVenteId: json['point_de_vente_id']
    );
  }
}