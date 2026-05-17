class AuthResponse {
  final String token;
  final String type;
  final int id;
  final String name;
  final String email;
  final String role;

  AuthResponse({
    required this.token,
    required this.type,
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      type: json['type'] ?? 'Bearer',
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }
}