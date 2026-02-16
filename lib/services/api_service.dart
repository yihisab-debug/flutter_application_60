import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$_baseUrl/posts'));
    _checkResponse(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Product.fromJson(json)).toList();
  }

  static Future<List<Product>> fetchProductsPaginated({
    required int offset,
    required int limit,
  }) async {
    final uri = Uri.parse('$_baseUrl/posts').replace(
      queryParameters: {
        '_start': offset.toString(),
        '_limit': limit.toString(),
      },
    );
    final response = await http.get(uri);
    _checkResponse(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Product.fromJson(json)).toList();
  }

  static Future<Product> fetchProductById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/posts/$id'));
    _checkResponse(response);
    return Product.fromJson(json.decode(response.body));
  }

  static Future<List<Product>> fetchProductsByUserId(int userId) async {
    final uri = Uri.parse('$_baseUrl/posts').replace(
      queryParameters: {'userId': userId.toString()},
    );
    final response = await http.get(uri);
    _checkResponse(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Product.fromJson(json)).toList();
  }

  static Future<Product> createProduct({
    required String title,
    required String body,
    required int userId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': title,
        'body': body,
        'userId': userId,
      }),
    );
    _checkResponse(response);
    return Product.fromJson(json.decode(response.body));
  }

  static Future<Product> updateProduct(
      int id, Map<String, dynamic> fields) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/posts/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(fields),
    );
    _checkResponse(response);
    return Product.fromJson(json.decode(response.body));
  }

  static Future<Product> patchProduct(
      int id, Map<String, dynamic> fields) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/posts/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(fields),
    );
    _checkResponse(response);
    return Product.fromJson(json.decode(response.body));
  }

  static Future<bool> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/posts/$id'));
    _checkResponse(response);

    return response.statusCode == 200;
  }

  static Future<List<Product>> fetchRelatedProducts(int productId) async {

    final product = await fetchProductById(productId);
    
    final uri = Uri.parse('$_baseUrl/posts').replace(
      queryParameters: {'userId': product.userId.toString()},
    );
    final response = await http.get(uri);
    _checkResponse(response);
    final List<dynamic> data = json.decode(response.body);
    
    return data
        .map((json) => Product.fromJson(json))
        .where((p) => p.id != productId)
        .toList();
  }

  static Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response = await http.get(Uri.parse('$_baseUrl/users'));
    _checkResponse(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((user) => {
      'id': user['id'],
      'name': user['name'],
      'username': user['username'],
    }).toList();
  }

  static void _checkResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}