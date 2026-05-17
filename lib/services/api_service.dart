import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_response_model.dart';
import '../models/material_model.dart';
import '../models/post_model.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.4.100:8080';

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Email o contraseña incorrectos');
    }

    final auth = AuthResponse.fromJson(jsonDecode(response.body));
    await _saveSession(auth);

    return auth;
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('No se pudo crear la cuenta');
    }

    final auth = AuthResponse.fromJson(jsonDecode(response.body));
    await _saveSession(auth);

    return auth;
  }

  Future<void> _saveSession(AuthResponse auth) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', auth.token);
    await prefs.setString('name', auth.name);
    await prefs.setString('email', auth.email);
    await prefs.setString('role', auth.role);
    await prefs.setInt('userId', auth.id);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<List<Post>> getPosts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/posts'),
    );

    if (response.statusCode != 200) {
      throw Exception('Error cargando publicaciones');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Post.fromJson(e)).toList();
  }

  Future<List<CompostMaterial>> getMaterials() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/materials'),
    );

    if (response.statusCode != 200) {
      throw Exception('Error cargando materiales');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => CompostMaterial.fromJson(e)).toList();
  }

  Future<void> createPost({
    required String title,
    required String description,
    required String type,
    required double quantity,
    required String unit,
    required int materialId,
    required double lat,
    required double lng,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Usuario no autenticado');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/posts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'type': type,
        'quantity': quantity,
        'unit': unit,
        'materialId': materialId,
        'lat': lat,
        'lng': lng,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error creando publicación: ${response.statusCode}');
    }
  }
}