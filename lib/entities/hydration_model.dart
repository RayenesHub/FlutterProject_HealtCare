class HydrationEntry {
  final int? id;
  final int userId;
  final double quantity; // ml
  final String date; // format "YYYY-MM-DD"

  HydrationEntry({
    this.id,
    required this.userId,
    required this.quantity,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'quantity': quantity,
    'date': date,
  };

  factory HydrationEntry.fromMap(Map<String, dynamic> map) => HydrationEntry(
    id: map['id'],
    userId: map['userId'],
    quantity: map['quantity'],
    date: map['date'],
  );
}
