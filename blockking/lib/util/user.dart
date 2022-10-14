
class User {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String address;
  final String birth;
  final String role;
  final String id;

  User({required this.email, required this.password, required this.name, required this.phone, required this.address, required this.birth, required this.role, required this.id});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      birth: json['birth'] as String,
      role: json['role'] as String,
      id: json['id'] as String,
    );
  }
}