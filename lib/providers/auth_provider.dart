import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  User? _user;
  String? _token;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Future<void> login(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
    _token = token;
    _user = _decodeUserFromToken(token);
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    _token = null;
    _user = null;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null && !Jwt.isExpired(token)) {
      _token = token;
      _user = _decodeUserFromToken(token);
      notifyListeners();
    } else {
      await logout(); // Clean up expired or invalid token
    }
  }

  User _decodeUserFromToken(String token) {
    final Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
    return User.fromToken(decodedToken);
  }
}
