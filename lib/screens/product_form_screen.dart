import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product; // null = создание, не null = редактирование

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  late final TextEditingController _titleCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _categoryIdCtrl;
  late final TextEditingController _imagesCtrl;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _titleCtrl = TextEditingController(text: p?.title ?? '');
    _priceCtrl = TextEditingController(
        text: p != null ? p.price.toInt().toString() : '');
    _descriptionCtrl = TextEditingController(text: p?.description ?? '');
    _categoryIdCtrl = TextEditingController(
        text: (p?.category?.id ?? 1).toString());
    _imagesCtrl = TextEditingController(
      text: p?.images.join('\n') ?? 'https://placehold.co/600x400',
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _descriptionCtrl.dispose();
    _categoryIdCtrl.dispose();
    _imagesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final images = _imagesCtrl.text
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (isEditing) {
        // PUT /products/{id}
        await ApiService.updateProduct(widget.product!.id, {
          'title': _titleCtrl.text.trim(),
          'price': int.tryParse(_priceCtrl.text.trim()) ?? 0,
          'description': _descriptionCtrl.text.trim(),
          'images': images,
        });
      } else {
        // POST /products
        await ApiService.createProduct(
          title: _titleCtrl.text.trim(),
          price: int.tryParse(_priceCtrl.text.trim()) ?? 0,
          description: _descriptionCtrl.text.trim(),
          categoryId: int.tryParse(_categoryIdCtrl.text.trim()) ?? 1,
          images: images,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? '✅ Продукт обновлён'
                : '✅ Продукт создан'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(isEditing ? 'Редактировать продукт' : 'Новый продукт'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Название (title)',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: _required,
              ),
              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Цена (price)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Обязательное поле';
                  if (int.tryParse(v.trim()) == null) return 'Введите число';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Описание (description)',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: _required,
              ),
              const SizedBox(height: 16),

              // Category ID
              TextFormField(
                controller: _categoryIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'ID категории (categoryId)',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                  helperText: 'Должен существовать в /categories',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Обязательное поле';
                  if (int.tryParse(v.trim()) == null) return 'Введите число';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Images
              TextFormField(
                controller: _imagesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Изображения (по 1 URL на строку)',
                  prefixIcon: Icon(Icons.image),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  helperText: 'Каждый URL на новой строке',
                ),
                maxLines: 4,
                validator: _required,
              ),
              const SizedBox(height: 32),

              // Кнопка
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(isEditing ? Icons.save : Icons.add),
                label: Text(
                    isEditing ? 'Сохранить изменения' : 'Создать продукт'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),

              // Подсказка
              Text(
                isEditing
                    ? 'PUT /products/${widget.product!.id}'
                    : 'POST /products',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? v) {
    if (v == null || v.trim().isEmpty) return 'Обязательное поле';
    return null;
  }
}