import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';
import 'product_list_screen.dart';

class SearchSlugScreen extends StatefulWidget {
  const SearchSlugScreen({super.key});

  @override
  State<SearchSlugScreen> createState() => _SearchSlugScreenState();
}

class _SearchSlugScreenState extends State<SearchSlugScreen> {
  final TextEditingController _slugCtrl = TextEditingController();

  Product? _result;
  bool _isLoading = false;
  String? _error;
  bool _searched = false;

  @override
  void dispose() {
    _slugCtrl.dispose();
    super.dispose();
  }

  // GET /products/slug/{slug}
  Future<void> _search() async {
    final slug = _slugCtrl.text.trim();
    if (slug.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
      _searched = true;
    });

    try {
      final product = await ApiService.fetchProductBySlug(slug);
      setState(() {
        _result = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Поиск по slug')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Поле ввода
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _slugCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Slug продукта',
                      hintText: 'handmade-fresh-table',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _search,
                  child: const Text('Найти'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'GET /products/slug/{slug}',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),

            // Результат
            if (_isLoading)
              const CircularProgressIndicator(),

            if (_error != null && !_isLoading)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 8),
                      const Text('Продукт не найден',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),

            if (_result != null && !_isLoading)
              _buildResultCard(_result!),

            if (!_searched && !_isLoading)
              const Expanded(
                child: Center(
                  child: Text('Введите slug для поиска',
                      style: TextStyle(color: Colors.grey)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(Product product) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение
          if (product.image.startsWith('http'))
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Image.network(
                product.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, size: 64),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('slug: ${product.slug}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                if (product.category != null) ...[
                  const SizedBox(height: 8),
                  Text('Категория: ${product.category!.name}'),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(productId: product.id),
                          ),
                        ),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Подробнее'),
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
}