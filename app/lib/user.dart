class User {
  final String username;
  final String email;
  final String password;
  final String? sleeper_id;

  User({
    required this.username,
    required this.email,
    required this.password,
    this.sleeper_id,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      email: json['email'],
      password: json['password'],
      sleeper_id: json['sleeper_id'],
    );
  }
}
