class GratitudeEntry {
  int? id;
  int userId; // pour lier chaque entrée à un utilisateur
  String content; // la phrase de gratitude
  String date; // date de l'entrée YYYY-MM-DD

  GratitudeEntry({
    this.id,
    required this.userId,
    required this.content,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'date': date,
    };
  }

  factory GratitudeEntry.fromMap(Map<String, dynamic> map) {
    return GratitudeEntry(
      id: map['id'],
      userId: map['userId'],
      content: map['content'],
      date: map['date'],
    );
  }
}
