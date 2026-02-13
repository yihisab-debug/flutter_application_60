import 'package:flutter/material.dart';
import '../models/product.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _product = ApiService.fetchProductById(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Продукт #${widget.productId}'),
      ),
      body: FutureBuilder<Product>(
        future: _product,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Icon(Icons.error_outline,
                      size: 64, color: Colors.red),

                  const SizedBox(height: 16),

                  Text('Ошибка: ${snapshot.error}'),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () => setState(() => _load()),
                    child: const Text('Повторить'),
                  ),

                ],
              ),
            );
          }

          final product = snapshot.data!;
          return _buildContent(product);
        },
      ),
    );
  }

  Widget _buildContent(Product product) {

    final validImages =
        product.images.where((url) => url.startsWith('http')).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(
            height: 280,
            child: validImages.isNotEmpty
                ? PageView.builder(
                    itemCount: validImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [

                          Image.network(
                            validImages[index],
                            fit: BoxFit.cover,

                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade200,

                              child: const Icon(Icons.broken_image,
                                  size: 64, color: Colors.grey),

                            ),
                          ),

                          if (validImages.length > 1)

                            Positioned(
                              bottom: 8,
                              right: 8,

                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),

                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                ),

                                child: Text(
                                  '${index + 1}/${validImages.length}',

                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),

                                ),

                              ),
                            ),
                        ],
                      );
                    },
                  )

                : Container(
                    color: Colors.grey.shade200,

                    child: const Center(
                      child: Icon(Icons.image, size: 64, color: Colors.grey),
                    ),

                  ),

          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if (product.category != null)

                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),

                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Text(
                      product.category!.name,
                      style: TextStyle(color: Colors.teal.shade700),
                    ),

                  ),

                const SizedBox(height: 12),

                Text(
                  product.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text(
                  'slug: ${product.slug}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 12),

                Text(
                  '\$${product.price.toStringAsFixed(2)}',

                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),

                ),

                const SizedBox(height: 20),

                const Text(
                  'Описание',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(product.description, style: const TextStyle(fontSize: 15)),

                const SizedBox(height: 20),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text('Информация',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),

                        const Divider(),

                        _infoRow('ID', product.id.toString()),

                        _infoRow('Slug', product.slug),

                        _infoRow(
                            'Категория', product.category?.name ?? '—'),

                        _infoRow('ID категории',
                            product.category?.id.toString() ?? '—'),

                        _infoRow('Изображений',
                            product.images.length.toString()),

                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [

                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductFormScreen(product: product),
                            ),
                          );
                          if (result == true) setState(() => _load());
                        },

                        icon: const Icon(Icons.edit),

                        label: const Text('Редактировать'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RelatedProductsScreen(
                              productId: product.id,
                              productTitle: product.title,
                            ),
                          ),
                        ),

                        icon: const Icon(Icons.link),

                        label: const Text('Похожие'),

                      ),
                    ),

                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [

          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.grey)),
          ),

          Expanded(child: Text(value)),
          
        ],
      ),
    );
  }
}