class Activity {
  int? id;
  String type;
  int duration;
  int calories;
  DateTime date;

  Activity({
    this.id,
    required this.type,
    required this.duration,
    required this.calories,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'duration': duration,
      'calories': calories,
      'date': date.toIso8601String(),
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as int?,
      type: map['type'] as String,
      duration: map['duration'] as int,
      calories: map['calories'] as int,
      date: DateTime.parse(map['date'] as String),
    );
  }
}
