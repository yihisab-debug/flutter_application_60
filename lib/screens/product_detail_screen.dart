import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/comment.dart';
import '../models/album.dart';
import '../models/photo.dart';

import '../services/api_service.dart';
import 'product_form_screen.dart';
import 'product_list_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Product> _product;
  late Future<List<Comment>> _comments;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _product = ApiService.fetchProductById(widget.productId);
    _comments = ApiService.fetchCommentsByPost(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Пост #${widget.productId}'),
      ),
      body: FutureBuilder<Product>(
        future: _product,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          final product = snapshot.data!;
          return _buildContent(product);
        },
      ),
    );
  }

  Widget _buildContent(Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            product.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'User ${product.userId} • Post ID ${product.id}',
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 16),

          Text(
            product.body,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),

          const SizedBox(height: 24),

          FutureBuilder<List<Album>>(
            future: ApiService.fetchAlbumsByUser(product.userId),
            builder: (context, albumSnap) {
              if (!albumSnap.hasData) return const SizedBox();

              final albums = albumSnap.data!;
              if (albums.isEmpty) return const SizedBox();

              return FutureBuilder<List<Photo>>(
                future: ApiService.fetchPhotosByAlbum(albums.first.id),
                builder: (context, photoSnap) {
                  if (!photoSnap.hasData) return const SizedBox();

                  final photos = photoSnap.data!.take(6).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        'Фото пользователя',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),

                        itemCount: photos.length,
                        itemBuilder: (_, i) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              photos[i].thumbnailUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey.shade100,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                );
                              },

                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                    ],
                  );
                },
              );
            },
          ),

          const Text(
            'Комментарии',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          FutureBuilder<List<Comment>>(
            future: _comments,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text('Ошибка: ${snapshot.error}');
              }

              final comments = snapshot.data!;
              return Column(
                children: comments.map((c) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            c.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            c.email,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(c.body),

                        ],
                      ),
                    ),
                  );
                  
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          Row(
            children: [

              Expanded(
                child: ElevatedButton.icon(

                  icon: const Icon(Icons.edit),

                  label: const Text('Редактировать'),

                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductFormScreen(product: product),
                      ),
                    );
                    if (result == true) setState(() => _load());
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: OutlinedButton.icon(

                  icon: const Icon(Icons.link),

                  label: const Text('Похожие'),

                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RelatedProductsScreen(
                        productId: product.id,
                        productTitle: product.title,
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }
}