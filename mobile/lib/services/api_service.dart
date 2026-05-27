import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/estacion.dart';
import 'auth_service.dart';

class ApiService {

  final String baseUrl = "http://localhost:8000";

  // ==============================
  // GET ESTACIONES
  // ==============================
  Future<List<Estacion>> fetchEstaciones() async {

    final token = await AuthService().getToken();

    final url = '$baseUrl/estaciones/';

    print("URL: $url");

    try {

      final response = await http.get(

        Uri.parse(url),

        headers: {

          'Content-Type': 'application/json',

          if (token != null)
            'Authorization': 'Bearer $token',
        },

      ).timeout(const Duration(seconds: 5));

      print("STATUS: ${response.statusCode}");

      print("BODY: ${response.body}");

      // ==========================
      // MANEJO 401
      // ==========================

      if (response.statusCode == 401) {

        await AuthService().logout();

        throw Exception("Sesión expirada");
      }

      // ==========================
      // OK
      // ==========================

      if (response.statusCode == 200) {

        List<dynamic> jsonResponse =
            json.decode(response.body);

        return jsonResponse
            .map((data) =>
                Estacion.fromJson(data))
            .toList();

      } else {

        throw Exception(
          'Error servidor: ${response.statusCode}',
        );
      }

    } catch (e) {

      print("ERROR FETCH: $e");

      throw Exception(
        'No se pudo conectar con SMAT',
      );
    }
  }

  // ==============================
  // GET HISTORIAL IoT
  // ==============================
  Future<Map<String, dynamic>>
      fetchHistorial(
    int estacionId,
  ) async {

    final token =
        await AuthService().getToken();

    final url =
        '$baseUrl/estaciones/$estacionId/historial';

    print("URL HISTORIAL: $url");

    try {

      final response = await http.get(

        Uri.parse(url),

        headers: {

          'Content-Type': 'application/json',

          if (token != null)
            'Authorization': 'Bearer $token',
        },

      ).timeout(const Duration(seconds: 5));

      print(
        "STATUS HISTORIAL: ${response.statusCode}",
      );

      print(
        "BODY HISTORIAL: ${response.body}",
      );

      // ==========================
      // 401
      // ==========================

      if (response.statusCode == 401) {

        await AuthService().logout();

        throw Exception("Sesión expirada");
      }

      // ==========================
      // OK
      // ==========================

      if (response.statusCode == 200) {

        return jsonDecode(response.body);

      } else {

        throw Exception(
          "Error historial: ${response.statusCode}",
        );
      }

    } catch (e) {

      print("ERROR HISTORIAL: $e");

      throw Exception(
        "No se pudo cargar historial",
      );
    }
  }

  // ==============================
  // POST ESTACION
  // ==============================
  Future<bool> crearEstacion(

    String nombre,

    String ubicacion,

  ) async {

    final token =
        await AuthService().getToken();

    final url = '$baseUrl/estaciones/';

    try {

      final response = await http.post(

        Uri.parse(url),

        headers: {

          'Content-Type': 'application/json',

          if (token != null)
            'Authorization': 'Bearer $token',
        },

        body: jsonEncode({

          'nombre': nombre,

          'ubicacion': ubicacion,
        }),

      ).timeout(const Duration(seconds: 5));

      print(
        "STATUS POST: ${response.statusCode}",
      );

      // ==========================
      // 401
      // ==========================

      if (response.statusCode == 401) {

        await AuthService().logout();

        return false;
      }

      // ==========================
      // CREATED / OK
      // ==========================

      return response.statusCode == 200 ||
          response.statusCode == 201;

    } catch (e) {

      print("ERROR POST: $e");

      return false;
    }
  }
}