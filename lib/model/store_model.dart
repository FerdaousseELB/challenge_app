class Store {
  final int id;
  final String adresse;
  final String nom;

  Store({
    required this.id,
    required this.adresse,
    required this.nom,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['ID'],
      adresse: json['adresse'],
      nom: json['nom'],
    );
  }
}