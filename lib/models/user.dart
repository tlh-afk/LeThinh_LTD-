class User {
  final int id;
  final String email;
  final String role;

  User({required this.id, required this.email, required this.role});

  factory User.fromToken(Map<String, dynamic> decodedToken) {
    // This logic checks for both long and short claim names for better compatibility
    return User(
      id: int.parse(decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ?? decodedToken['nameid'] ?? '0'),
      email: decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] ?? decodedToken['email'] ?? '',
      role: decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/role'] ?? decodedToken['role'] ?? 'USER',
    );
  }
}
