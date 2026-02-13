import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String _baseUrl = 'https://api.escuelajs.co/api/v1';

  // ─── GET /products ───
  // Получить все продукты
  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$_baseUrl/products'));
    _checkResponse(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Product.fromJson(json)).toList();
  }

  // ─── GET /products?offset=0&limit=10 ───
  // Пагинация
  static Future<List<Product>> fetchProductsPaginated({
    required int offset,
    required int limit,
  }) async {
    final uri = Uri.parse('$_baseUrl/products').replace(
      queryParameters: {
        'offset': offset.toString(),
        'limit': limit.toString(),
      },
    );
    final response = await http.get(uri);
    _checkResponse(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Product.fromJson(json)).toList();
  }

  // ─── GET /products/{id} ───
  // Получить продукт по ID
  static Future<Product> fetchProductById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/products/$id'));
    _checkResponse(response);
    return Product.fromJson(json.decode(response.body));
  }

  // ─── GET /products/slug/{slug} ───
  // Получить продукт по slug
  static Future<Product> fetchProductBySlug(String slug) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/products/slug/$slug'));
    _checkResponse(response);
    return Product.fromJson(json.decode(response.body));
  }

  // ─── POST /products ───
  // Создать новый продукт
  static Future<Product> createProduct({
    required String title,
    required int price,
    required String description,
    required int categoryId,
    required List<String> images,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': title,
        'price': price,
        'description': description,
        'categoryId': categoryId,
        'images': images,
      }),
    );
    _checkResponse(response);
    return Product.fromJson(json.decode(response.body));
  }

  // ─── PUT /products/{id} ───
  // Обновить продукт
  static Future<Product> updateProduct(
      int id, Map<String, dynamic> fields) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(fields),
    );
    _checkResponse(response);
    return Product.fromJson(json.decode(response.body));
  }

  // ─── DELETE /products/{id} ───
  // Удалить продукт
  static Future<bool> deleteProduct(int id) async {
    final response =
        await http.delete(Uri.parse('$_baseUrl/products/$id'));
    _checkResponse(response);
    return json.decode(response.body) == true;
  }

  // ─── GET /products/{id}/related ───
  // Похожие продукты по ID
  static Future<List<Product>> fetchRelatedProducts(int id) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/products/$id/related'));
    _checkResponse(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Product.fromJson(json)).toList();
  }

  // ─── GET /products/slug/{slug}/related ───
  // Похожие продукты по slug
  static Future<List<Product>> fetchRelatedBySlug(String slug) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/products/slug/$slug/related'));
    _checkResponse(response);
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Product.fromJson(json)).toList();
  }

  // ─── Проверка ответа ───
  static void _checkResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}