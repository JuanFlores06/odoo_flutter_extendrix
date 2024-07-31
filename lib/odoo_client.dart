import 'dart:convert';
import 'package:http/http.dart' as http;

class OdooClient {
  final String url;
  final String db;
  final String username;
  final String password;
  int? uid;

  OdooClient({
    required this.url,
    required this.db,
    required this.username,
    required this.password,
  });

  Future<void> authenticate() async {
    final response = await http.post(
      Uri.parse('$url/jsonrpc'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'service': 'common',
          'method': 'login',
          'args': [db, username, password],
        },
        'id': 1,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.body);
      uid = result['result'];
      if (uid == null) {
        throw Exception('Autenticación fallida');
      }
    } else {
      throw Exception('Error de conexión: ${response.statusCode}');
    }
  }

  //Leer contactos de odoo
  Future<List<dynamic>> searchRead(
      String model, List<dynamic> domain, List<String> fields,
      {int limit = 800}) async {
    if (uid == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await http.post(
      Uri.parse('$url/jsonrpc'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'service': 'object',
          'method': 'execute_kw',
          'args': [
            db,
            uid,
            password,
            model,
            'search_read',
            [domain],
            {'fields': fields, 'limit': limit}
          ],
        },
        'id': 2,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.body);
      if (result['result'] != null) {
        return result['result'];
      } else {
        throw Exception('Error en la respuesta: ${result['error']['message']}');
      }
    } else {
      throw Exception('Error de conexión: ${response.statusCode}');
    }
  }

  //Crear un contacto en odoo
  Future<int?> createContact(Map<String, dynamic> values) async {
    if (uid == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await http.post(
      Uri.parse('$url/jsonrpc'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'service': 'object',
          'method': 'execute_kw',
          'args': [
            db,
            uid,
            password,
            'res.partner',
            'create',
            [values],
          ],
        },
        'id': 3,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.body);
      return result['result'];
    } else {
      throw Exception('Error de conexión: ${response.statusCode}');
    }
  }
}
