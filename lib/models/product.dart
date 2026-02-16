class Product {
  final int id;
  final String title;
  final String body; // описание (в JSONPlaceholder это "body")
  final int userId; // вместо category используем userId
  
  Product({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      userId: json['userId'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'userId': userId,
    };
  }

  String get shortBody {
    if (body.length <= 100) return body;
    return '${body.substring(0, 100)}...';
  }
}