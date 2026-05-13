import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/estacion.dart';
import 'auth_service.dart';

class ApiService {

  // Chrome/Linux
  final String baseUrl = "http://localhost:8000";

  // =========================================
  // GET ESTACIONES
  // =========================================
  Future<List<Estacion>> fetchEstaciones() async {

    final url = '$baseUrl/estaciones/';
    print("URL: $url");

    try {

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {

        List<dynamic> jsonResponse =
            json.decode(response.body);

        print("PARSED: $jsonResponse");

        return jsonResponse
            .map((data) => Estacion.fromJson(data))
            .toList();

      } else {

        throw Exception(
          'Error del servidor: ${response.statusCode}',
        );
      }

    } catch (e) {

      print("ERROR FETCH: $e");

      // Manejo de errores robusto
      throw Exception(
        'No se pudo conectar con SMAT. ¿Está el servidor activo?',
      );
    }
  }

  // =========================================
  // POST CREAR ESTACION
  // =========================================
  Future<bool> crearEstacion(
    String nombre,
    String ubicacion,
  ) async {

    final token = await AuthService().getToken();
    final url = '$baseUrl/estaciones/';

    print("TOKEN: $token");

    try {

      final response = await http.post(
        Uri.parse(url),

        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },

        body: jsonEncode({
          'nombre': nombre,
          'ubicacion': ubicacion,
        }),
      ).timeout(const Duration(seconds: 5));

      print("STATUS POST: ${response.statusCode}");
      print("BODY POST: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }

    } catch (e) {

      print("ERROR POST: $e");

      return false;
    }
  }
}