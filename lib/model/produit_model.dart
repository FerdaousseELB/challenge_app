class Produit {
  final int id;
  final String nom;

  Produit({
    required this.id,
    required this.nom,
  });

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['ID'],
      nom: json['nom'],
    );
  }
}
