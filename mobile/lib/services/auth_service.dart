import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  final String baseUrl = "http://localhost:8000";

  Future<bool> login(String u, String p) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': u,
          'password': p,
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['access_token']);

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}