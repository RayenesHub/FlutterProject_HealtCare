class Objective {
  int? id;
  String title;
  String date;
  bool completed;

  Objective({
    this.id,
    required this.title,
    required this.date,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'completed': completed ? 1 : 0,
    };
  }

  factory Objective.fromMap(Map<String, dynamic> map) {
    return Objective(
      id: map['id'],
      title: map['title'],
      date: map['date'],
      completed: map['completed'] == 1,
    );
  }
}
