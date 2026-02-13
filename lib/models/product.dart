class Category {
  final int id;
  final String name;
  final String image;
  final String slug;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.slug,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}

class Product {
  final int id;
  final String title;
  final String slug;
  final double price;
  final String description;
  final Category? category;
  final String image; // первая картинка
  final List<String> images; // все картинки

  Product({
    required this.id,
    required this.title,
    required this.slug,
    required this.price,
    required this.description,
    this.category,
    required this.image,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Парсим массив images
    List<String> imageList = [];
    if (json['images'] != null && json['images'] is List) {
      imageList = (json['images'] as List)
          .map((e) => e.toString().replaceAll('"', '').replaceAll('[', '').replaceAll(']', ''))
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Первая картинка для превью
    String firstImage = '';
    if (imageList.isNotEmpty) {
      firstImage = imageList.first;
    }

    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      image: firstImage,
      images: imageList,
    );
  }
}