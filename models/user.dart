class User {
  final String id;
  final String username;
  final bool isAdmin;
  final String? fullName;
  final String? email;

  User({
    required this.id,
    required this.username,
    required this.isAdmin,
    this.fullName,
    this.email,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'].toString(),
      username: map['username'],
      isAdmin: map['isAdmin'] == 1,
      fullName: map['fullName'],
      email: map['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'isAdmin': isAdmin ? 1 : 0,
      'fullName': fullName,
      'email': email,
    };
  }
}
