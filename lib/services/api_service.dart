import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/comment.dart';
import '../models/album.dart';
import '../models/photo.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
  };

  // ===================== POSTS =====================

  static Future<List<Product>> fetchProducts() async {
    final response =
        await http.get(Uri.parse('$_baseUrl/posts'), headers: _headers);
    _checkResponse(response);
    final List data = json.decode(response.body);
    return data.map((e) => Product.fromJson(e)).toList();
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
    final response = await http.get(uri, headers: _headers);
    _checkResponse(response);
    final List data = json.decode(response.body);
    return data.map((e) => Product.fromJson(e)).toList();
  }

  static Future<Product> fetchProductById(int id) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/posts/$id'), headers: _headers);
    _checkResponse(response);
    return Product.fromJson(json.decode(response.body));
  }

  static Future<List<Product>> fetchProductsByUserId(int userId) async {
    final uri = Uri.parse('$_baseUrl/posts')
        .replace(queryParameters: {'userId': userId.toString()});
    final response = await http.get(uri, headers: _headers);
    _checkResponse(response);
    final List data = json.decode(response.body);
    return data.map((e) => Product.fromJson(e)).toList();
  }

  static Future<Product> createProduct({
    required String title,
    required String body,
    required int userId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/posts'),
      headers: _headers,
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
      headers: _headers,
      body: json.encode(fields),
    );
    _checkResponse(response);
    return Product.fromJson(json.decode(response.body));
  }

  static Future<Product> patchProduct(
      int id, Map<String, dynamic> fields) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/posts/$id'),
      headers: _headers,
      body: json.encode(fields),
    );
    _checkResponse(response);
    return Product.fromJson(json.decode(response.body));
  }

  static Future<bool> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/posts/$id'),
      headers: _headers,
    );
    _checkResponse(response);
    return response.statusCode == 200;
  }

  static Future<List<Product>> fetchRelatedProducts(int productId) async {
    final product = await fetchProductById(productId);
    final uri = Uri.parse('$_baseUrl/posts')
        .replace(queryParameters: {'userId': product.userId.toString()});
    final response = await http.get(uri, headers: _headers);
    _checkResponse(response);
    final List data = json.decode(response.body);
    return data
        .map((e) => Product.fromJson(e))
        .where((p) => p.id != productId)
        .toList();
  }

  static Future<List<Comment>> fetchCommentsByPost(int postId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/posts/$postId/comments'),
      headers: _headers,
    );
    _checkResponse(response);
    final List data = json.decode(response.body);
    return data.map((e) => Comment.fromJson(e)).toList();
  }

  static Future<List<Album>> fetchAlbumsByUser(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/$userId/albums'),
      headers: _headers,
    );
    _checkResponse(response);
    final List data = json.decode(response.body);
    return data.map((e) => Album.fromJson(e)).toList();
  }

  static Future<List<Photo>> fetchPhotosByAlbum(int albumId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/albums/$albumId/photos'),
      headers: _headers,
    );
    _checkResponse(response);
    final List data = json.decode(response.body);
    return data.map((e) {
      final id = e['id'] ?? 0;
      e['url'] = 'https://picsum.photos/id/$id/600/600';
      e['thumbnailUrl'] = 'https://picsum.photos/id/$id/150/150';
      return Photo.fromJson(e);
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response =
        await http.get(Uri.parse('$_baseUrl/users'), headers: _headers);
    _checkResponse(response);
    final List data = json.decode(response.body);
    return data
        .map((user) => {
              'id': user['id'],
              'name': user['name'],
              'username': user['username'],
            })
        .toList();
  }

  static void _checkResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}