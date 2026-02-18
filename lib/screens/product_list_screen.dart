import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';
import 'search_user_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Product> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _offset = 0;
  static const int _limit = 10;

  @override
  void initState() {
    super.initState();
    _loadPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadPage();
    }
  }

  Future<void> _loadPage() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final newProducts = await ApiService.fetchProductsPaginated(
        offset: _offset,
        limit: _limit,
      );
      setState(() {
        _products.addAll(newProducts);
        _offset += _limit;
        _hasMore = newProducts.length == _limit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _products.clear();
      _offset = 0;
      _hasMore = true;
    });
    await _loadPage();
  }

  Future<void> _deleteProduct(Product product) async {
    try {
      final deleted = await ApiService.deleteProduct(product.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(
            content: Text(
                deleted ? '✅ "${product.title}" удалён' : '⚠️ Не удалось удалить'),
            backgroundColor: deleted ? Colors.green : Colors.orange,
          ),

        );
        if (deleted) {
          setState(() => _products.remove(product));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSONPlaceholder Posts'),
        actions: [

          IconButton(
            icon: const Icon(Icons.person_search),
            tooltip: 'Поиск по User ID',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchUserScreen()),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),

        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          );
          if (created == true) _refresh();
        },
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_products.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_products.isEmpty && _error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),

            const SizedBox(height: 16),

            Text(_error!, textAlign: TextAlign.center),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),

          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: Column(
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade100,
            child: Text(
              'Загружено: ${_products.length} '
              '${_hasMore ? "• Прокрутите для загрузки ещё" : "• Всё загружено"}',

              style: const TextStyle(fontSize: 12, color: Colors.grey),

            ),
          ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: _products.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _products.length) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _buildProductCard(_products[index]);
              },
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => _openDetail(product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  'U${product.userId}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      product.shortBody,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [

                        Icon(Icons.tag, size: 14, color: Colors.grey.shade600),

                        const SizedBox(width: 4),

                        Text(
                          'ID: ${product.id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Icon(Icons.person,
                            size: 14, color: Colors.grey.shade600),

                        const SizedBox(width: 4),

                        Text(
                          'User ${product.userId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),

                      ],
                    ),

                  ],
                ),
              ),

              PopupMenuButton<String>(
                onSelected: (action) => _onAction(action, product),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'view', child: Text('👁 Просмотр')),
                  PopupMenuItem(value: 'edit', child: Text('✏️ Редактировать')),
                  PopupMenuItem(value: 'related', child: Text('🔗 Похожие')),
                  PopupMenuItem(value: 'delete', child: Text('🗑 Удалить')),
                ],
              ),

            ],
          ),

        ),
      ),
    );
  }

  void _onAction(String action, Product product) async {
    switch (action) {
      case 'view':
        _openDetail(product);
        break;
      case 'edit':
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductFormScreen(product: product),
          ),
        );
        if (result == true) _refresh();
        break;
      case 'related':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RelatedProductsScreen(
              productId: product.id,
              productTitle: product.title,
            ),
          ),
        );

        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Удалить?'),
            content: Text('Удалить пост "${product.title}"?'),
            actions: [

              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Отмена')),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _deleteProduct(product);
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Удалить',
                    style: TextStyle(color: Colors.white)),
              ),

            ],
          ),
        );
        break;
    }
  }

  void _openDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: product.id),
      ),
    );
  }
}

class RelatedProductsScreen extends StatefulWidget {
  final int productId;
  final String productTitle;

  const RelatedProductsScreen({
    super.key,
    required this.productId,
    required this.productTitle,
  });

  @override
  State<RelatedProductsScreen> createState() => _RelatedProductsScreenState();
}

class _RelatedProductsScreenState extends State<RelatedProductsScreen> {
  late Future<List<Product>> _related;

  @override
  void initState() {
    super.initState();
    _related = ApiService.fetchRelatedProducts(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Похожие: ${widget.productTitle}')),
      body: FutureBuilder<List<Product>>(
        future: _related,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          final products = snapshot.data!;
          if (products.isEmpty) {
            return const Center(
              child: Text('Нет других постов от этого пользователя'),
            );
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(

                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      '${p.id}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),

                  title: Text(p.title,
                      maxLines: 2, overflow: TextOverflow.ellipsis),

                  subtitle: Text(
                    p.shortBody,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailScreen(productId: p.id),
                    ),
                  ),
                ),
                
              );
            },
          );
        },
      ),
    );
  }
}