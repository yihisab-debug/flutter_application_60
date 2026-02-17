import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';
import 'product_list_screen.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final TextEditingController _userIdCtrl = TextEditingController();
  List<Product> _results = [];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _userIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final userIdStr = _userIdCtrl.text.trim();
    if (userIdStr.isEmpty) return;

    final userId = int.tryParse(userIdStr);
    if (userId == null) {
      setState(() {
        _error = 'Введите корректный ID пользователя (число)';
        _results = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _results = [];
    });

    try {
      final products = await ApiService.fetchProductsByUserId(userId);
      setState(() {
        _results = products;
        _isLoading = false;
        if (products.isEmpty) {
          _error = 'Постов от пользователя $userId не найдено';
        }
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
      appBar: AppBar(
        title: const Text('Поиск по User ID'),
        elevation: 2,
      ),
      body: Column(
        children: [

          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              children: [

                Row(
                  children: [

                    Expanded(
                      child: TextField(
                        controller: _userIdCtrl,
                        decoration: InputDecoration(
                          labelText: 'User ID',
                          hintText: 'От 1 до 10',
                          prefixIcon: const Icon(Icons.person_search),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        onSubmitted: (_) => _search(),
                      ),
                    ),

                    const SizedBox(width: 12),

                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _search,
                      icon: const Icon(Icons.search),
                      label: const Text('Найти'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  'GET /posts?userId={userId}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),

              ],
            ),
          ),

          Expanded(
            child: _buildResults(),
          ),

        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey.shade400,
              ),

              const SizedBox(height: 16),

              Text(
                _error!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

            ],
          ),
        ),
      );
    }

    if (_results.isNotEmpty) {
      return Column(
        children: [

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.blue.shade50,
            child: Text(
              'Найдено постов: ${_results.length}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                return _buildResultCard(_results[index]);
              },
            ),
          ),

        ],
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            Icons.person_search,
            size: 80,
            color: Colors.grey.shade300,
          ),

          const SizedBox(height: 16),

          Text(
            'Введите User ID для поиска постов',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 8),
          
          Text(
            'Обычно используются ID от 1 до 10',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildResultCard(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      child: InkWell(
        onTap: () => _openDetail(product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      '${product.id}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      product.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 8),

              Text(
                product.shortBody,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openDetail(product),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Подробнее'),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openRelated(product),
                      icon: const Icon(Icons.link, size: 18),
                      label: const Text('Похожие'),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: product.id),
      ),
    );
  }

  void _openRelated(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RelatedProductsScreen(
          productId: product.id,
          productTitle: product.title,
        ),
      ),
    );
  }
}
