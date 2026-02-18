import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late final TextEditingController _userIdCtrl;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _titleCtrl = TextEditingController(text: p?.title ?? '');
    _bodyCtrl = TextEditingController(text: p?.body ?? '');
    _userIdCtrl = TextEditingController(
      text: (p?.userId ?? 1).toString(),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _userIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      if (isEditing) {
        await ApiService.updateProduct(widget.product!.id, {
          'id': widget.product!.id,
          'title': _titleCtrl.text.trim(),
          'body': _bodyCtrl.text.trim(),
          'userId': int.tryParse(_userIdCtrl.text.trim()) ?? 1,
        });
      } else {
        await ApiService.createProduct(
          title: _titleCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
          userId: int.tryParse(_userIdCtrl.text.trim()) ?? 1,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? '✅ Пост обновлён' : '✅ Пост создан'),
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
        title: Text(isEditing ? 'Редактировать пост' : 'Новый пост'),
        elevation: 2,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),

                child: Row(
                  children: [

                    Icon(Icons.info_outline, color: Colors.blue.shade700),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        isEditing
                            ? 'PUT /posts/${widget.product!.id}'
                            : 'POST /posts',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(

                  labelText: 'Заголовок поста',

                  hintText: 'Введите заголовок',

                  prefixIcon: const Icon(Icons.title),

                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLines: 2,
                validator: _required,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _bodyCtrl,
                decoration: InputDecoration(

                  labelText: 'Содержимое поста',

                  hintText: 'Введите текст поста',

                  prefixIcon: const Icon(Icons.article),

                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLines: 8,
                validator: _required,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _userIdCtrl,
                decoration: InputDecoration(

                  labelText: 'ID пользователя',

                  hintText: 'От 1 до 10',

                  prefixIcon: const Icon(Icons.person),

                  border: const OutlineInputBorder(),

                  helperText: 'ID пользователя (обычно от 1 до 10)',

                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),

                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Обязательное поле';
                  }
                  final num = int.tryParse(v.trim());
                  if (num == null) {
                    return 'Введите число';
                  }
                  if (num < 1 || num > 10) {
                    return 'Обычно используются ID от 1 до 10';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

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
                  isEditing ? 'Сохранить изменения' : 'Создать пост',
                  style: const TextStyle(fontSize: 16),
                ),

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  elevation: 2,
                ),
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