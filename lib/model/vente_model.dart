class Vente {
  final int id;
  final int produitId;
  final int vendeurId;
  final DateTime heureDeVente; // Mettre à jour le type de propriété en DateTime

  Vente({
    required this.id,
    required this.produitId,
    required this.vendeurId,
    required this.heureDeVente, // Mettre à jour le type de propriété en DateTime
  });

  factory Vente.fromJson(Map<String, dynamic> json) {
    return Vente(
      id: json['ID'],
      produitId: json['produit_id'],
      vendeurId: json['vendeur_id'],
      heureDeVente: DateTime.parse(json['heure_de_vente']), // Convertir la chaîne de caractères en DateTime
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'produit_id': produitId,
      'vendeur_id': vendeurId,
      'heure_de_vente': heureDeVente.toUtc().toIso8601String(),
    };
  }
}
