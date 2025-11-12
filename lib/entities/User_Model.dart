class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  final int age;
  final double weight;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.age,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'age': age,
      'weight': weight,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      age: map['age'],
      weight: map['weight'],
    );
  }
}