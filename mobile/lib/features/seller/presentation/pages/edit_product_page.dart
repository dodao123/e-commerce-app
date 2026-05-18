import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../widgets/product_category_picker.dart';
import 'edit_product_actions.dart';
import 'edit_product_handler.dart';
import 'edit_product_submit.dart';

/// Page for editing an existing product.
class EditProductPage extends StatefulWidget {
  final Map<String, dynamic> product;
  const EditProductPage({super.key, required this.product});
  @override
  State<EditProductPage> createState() => EditProductPageState();
}

/// State for EditProductPage, public for helper access.
class EditProductPageState extends State<EditProductPage> {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final stockCtrl = TextEditingController();
  final shippingCtrl = TextEditingController();
  final conditionNoteCtrl = TextEditingController();
  final List<String> existingImages = [];
  final List<String> imagesToDelete = [];
  final List<String> newImages = [];
  String videoUrl = '';
  String category = '';
  bool isNew = true;
  bool saving = false;

  @override
  void initState() { super.initState(); _prefillForm(); }

  void _prefillForm() {
    final p = widget.product;
    nameCtrl.text = p['name'] ?? '';
    descCtrl.text = p['description'] ?? '';
    priceCtrl.text = _fmt(p['price']);
    stockCtrl.text = '${p['stock'] ?? 0}';
    shippingCtrl.text = _fmt(p['base_shipping_fee']);
    conditionNoteCtrl.text = p['condition_note'] ?? '';
    category = p['category'] ?? '';
    isNew = (p['condition'] ?? 'new') == 'new';
    videoUrl = p['video_url'] ?? '';
    final imgs = p['images'] as List? ?? [];
    existingImages.addAll(imgs.cast<String>());
  }

  String _fmt(dynamic v) {
    if (v == null) return '0';
    final d = (v is int) ? v.toDouble() : v as double;
    return d == d.truncateToDouble() ? '${d.toInt()}' : d.toStringAsFixed(0);
  }

  @override
  void dispose() {
    for (final c in [nameCtrl, descCtrl, priceCtrl,
        stockCtrl, shippingCtrl, conditionNoteCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>()
        .locale.languageCode == 'vi';
    return Scaffold(
      backgroundColor: IndieFolkTheme.neutral(isDark),
      appBar: buildEditAppBar(context, isDark, isVi),
      body: buildEditBody(
        context: context, isDark: isDark, isVi: isVi,
        allImages: [...existingImages, ...newImages],
        videoUrl: videoUrl,
        onAddImage: () => pickEditImages(this),
        onAddVideo: () => addEditVideoUrl(context, this),
        onRemoveImage: (i) => removeEditImage(this, i),
        onRemoveVideo: () => setState(() => videoUrl = ''),
        nameCtrl: nameCtrl, descCtrl: descCtrl,
        priceCtrl: priceCtrl, stockCtrl: stockCtrl,
        shippingCtrl: shippingCtrl, category: category,
        onPickCategory: () async {
          final r = await showCategoryPicker(context, isVi, isDark);
          if (r != null) setState(() => category = r);
        },
        isNew: isNew,
        onConditionChanged: (v) => setState(() => isNew = v),
        conditionNoteCtrl: conditionNoteCtrl),
      bottomNavigationBar: buildEditBottomBar(
        isDark: isDark, isVi: isVi, saving: saving,
        onSave: () => submitEditProduct(context, this),
        onDelete: () => confirmDeleteProduct(context, this)),
    );
  }
}
