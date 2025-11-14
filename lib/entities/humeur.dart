class Humeur {
  String id;
  DateTime date;
  int niveau; // 1 à 5
  String commentaire;

  Humeur({
    required this.id,
    required this.date,
    required this.niveau,
    required this.commentaire,
  });

  // Convertit un objet Humeur en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'niveau': niveau,
      'commentaire': commentaire,
      'date': date.toIso8601String(),
    };
  }

  // Convertit un Map SQLite en objet Humeur
  factory Humeur.fromMap(Map<String, dynamic> map) {
    return Humeur(
      id: map['id'].toString(), // SQLite id est int, converti en String
      date: DateTime.parse(map['date']),
      niveau: map['niveau'],
      commentaire: map['commentaire'] ?? '',
    );
  }
}
