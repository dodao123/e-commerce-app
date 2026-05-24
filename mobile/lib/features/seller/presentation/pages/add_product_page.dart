import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/storage/token_manager.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../data/product_remote_datasource.dart';
import '../widgets/image_processing_overlay.dart';
import '../widgets/product_image_picker.dart';
import '../widgets/product_category_picker.dart';
import '../widgets/product_condition_picker.dart';
import 'add_product_form_fields.dart';
import 'add_product_helpers.dart';
import '../../../../features/home/data/models/product_option_group.dart';
import '../widgets/product_options_editor.dart';

/// Page for adding a new product to the seller's shop.
/// Contains image picker, text fields, category, price,
/// stock, shipping, and condition sections.
class AddProductPage extends StatefulWidget {
  /// Creates the AddProductPage widget.
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _shippingCtrl = TextEditingController();
  final _conditionNoteCtrl = TextEditingController();

  final List<String> _images = [];
  String _videoUrl = '';
  String _category = '';
  bool _isNew = true;
  bool _saving = false;
  List<ProductOptionGroup> _options = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _shippingCtrl.dispose();
    _conditionNoteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>()
        .locale.languageCode == 'vi';

    return Scaffold(
      backgroundColor: IndieFolkTheme.neutral(isDark),
      appBar: _appBar(isDark, isVi),
      body: SingleChildScrollView(child: Column(children: [
        _tipBanner(isDark, isVi),
        const SizedBox(height: 8),
        ProductImagePicker(
          imagePaths: _images, videoUrl: _videoUrl,
          onAddImage: _pickImages, onAddVideo: _addVideoUrl,
          onRemoveImage: (i) => setState(() => _images.removeAt(i)),
          onRemoveVideo: () => setState(() => _videoUrl = ''),
          isDark: isDark, isVi: isVi),
        const SizedBox(height: 8),
        AddProductFormFields(
          nameCtrl: _nameCtrl, descCtrl: _descCtrl,
          priceCtrl: _priceCtrl, stockCtrl: _stockCtrl,
          shippingCtrl: _shippingCtrl,
          category: _category,
          onPickCategory: () => _pickCategory(isVi, isDark),
          isDark: isDark, isVi: isVi),
        const SizedBox(height: 8),
        ProductConditionPicker(
          isNew: _isNew,
          onChanged: (v) => setState(() => _isNew = v),
          noteController: _conditionNoteCtrl,
          isDark: isDark, isVi: isVi),
        const SizedBox(height: 8),
        ProductOptionsEditor(
          options: _options,
          onChanged: (opts) => setState(() => _options = opts),
          isDark: isDark, isVi: isVi),
        const SizedBox(height: 24),
      ])),
      bottomNavigationBar: _saveButton(isDark, isVi),
    );
  }

  PreferredSizeWidget _appBar(bool isDark, bool isVi) {
    return AppBar(
      backgroundColor: IndieFolkTheme.neutral(isDark),
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios_rounded, size: 20, color: IndieFolkTheme.primary(isDark))),
      title: Text(isVi ? 'Thêm sản phẩm' : 'Add Product',
        style: IndieFolkTheme.h1(isDark).copyWith(fontSize: 20)));
  }

  Widget _tipBanner(bool isDark, bool isVi) =>
      buildProductTipBanner(isDark, isVi);

  Future<void> _pickImages() async {
    final remaining = 10 - _images.length;
    if (remaining <= 0) return;

    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(
      imageQuality: 80, limit: remaining);

    if (picked.isNotEmpty) {
      setState(() {
        for (final file in picked) {
          if (_images.length < 10) {
            _images.add(file.path);
          }
        }
      });
    }
  }

  Future<void> _addVideoUrl() async {
    final isVi = context.read<AppProvider>()
        .locale.languageCode == 'vi';
    final url = await showVideoUrlDialog(context, isVi);
    if (url != null && url.isNotEmpty) {
      setState(() => _videoUrl = url);
    }
  }

  Future<void> _pickCategory(bool isVi, bool isDark) async {
    final result = await showCategoryPicker(context, isVi, isDark);
    if (result != null) setState(() => _category = result);
  }

  Widget _saveButton(bool isDark, bool isVi) =>
      buildSaveButton(isDark, isVi, _saving ? null : _submitProduct);

  Future<void> _submitProduct() async {
    final isVi = context.read<AppProvider>()
        .locale.languageCode == 'vi';
    if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isVi
            ? 'Vui lòng nhập tên và giá'
            : 'Please enter name and price')));
      return;
    }

    setState(() => _saving = true);
    try {
      final token = await TokenManager().getToken();
      if (token == null) throw Exception('No token');

      // Step 1: Create product (no images yet)
      final datasource = ProductRemoteDatasource();
      final result = await datasource.createProduct(
        token: token,
        productData: {
          'name': _nameCtrl.text,
          'description': _descCtrl.text.isNotEmpty
              ? _descCtrl.text : 'No description',
          'category': _category.isNotEmpty
              ? _category : 'other',
          'price': double.tryParse(_priceCtrl.text) ?? 0,
          'stock': int.tryParse(_stockCtrl.text) ?? 0,
          'base_shipping_fee':
              double.tryParse(_shippingCtrl.text) ?? 0,
          'condition': _isNew ? 'new' : 'used',
          'condition_note': _conditionNoteCtrl.text,
          'options': _options
              .where((o) => o.name.isNotEmpty && o.values.isNotEmpty)
              .map((o) => o.toJson())
              .toList(),
          'images': <String>[],
          'video_url': _videoUrl,
        });

      // Step 2: Upload + bg removal (with loading overlay)
      final productId = result['id'] as String?;
      if (productId != null && _images.isNotEmpty) {
        if (!mounted) return;
        ImageProcessingOverlay.show(context,
          isVi: isVi,
          message: isVi
              ? 'Đang xử lý xóa phông ảnh...'
              : 'Removing background...');
        try {
          await datasource.uploadImages(
            token: token,
            productId: productId,
            localPaths: _images);
        } finally {
          if (mounted) ImageProcessingOverlay.hide(context);
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isVi
            ? 'Tạo sản phẩm thành công!'
            : 'Product created successfully!'),
        backgroundColor: Colors.green));
      Navigator.pop(context, true);
    } catch (error) {
      debugPrint('❌ Submit error: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $error'),
        backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
