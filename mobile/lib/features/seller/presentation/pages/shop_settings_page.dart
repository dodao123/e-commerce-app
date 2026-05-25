import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/storage/token_manager.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../data/shop_remote_datasource.dart';

/// Page for managing shop-specific settings like the AI assistant toggle.
class ShopSettingsPage extends StatefulWidget {
  /// Map containing the shop information.
  final Map<String, dynamic> shopData;

  /// Creates a ShopSettingsPage widget.
  const ShopSettingsPage({super.key, required this.shopData});

  @override
  State<ShopSettingsPage> createState() => _ShopSettingsPageState();
}

class _ShopSettingsPageState extends State<ShopSettingsPage> {
  final _datasource = ShopRemoteDatasource();
  late bool _aiEnabled;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _aiEnabled = widget.shopData['ai_assistant_enabled'] ?? false;
  }

  Future<void> _toggleAIAssistant(bool value) async {
    setState(() {
      _aiEnabled = value;
      _isSaving = true;
    });

    try {
      final token = await TokenManager().getToken();
      if (token == null) throw Exception('Not authenticated');

      final shopId = widget.shopData['id'].toString();
      final updatedData = {
        'ai_assistant_enabled': value,
      };

      await _datasource.updateShop(
        token: token,
        shopId: shopId,
        shopData: updatedData,
      );

      if (!mounted) return;
      final isVi = context.read<AppProvider>().locale.languageCode == 'vi';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isVi
            ? 'Đã lưu cấu hình AI Assistant'
            : 'AI Assistant setting saved'),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      // Revert state on error
      setState(() => _aiEnabled = !value);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>().locale.languageCode == 'vi';

    return Scaffold(
      backgroundColor: IndieFolkTheme.neutral(isDark),
      appBar: AppBar(
        backgroundColor: IndieFolkTheme.neutral(isDark),
        elevation: 0,
        title: Text(
          isVi ? 'Cài đặt Cửa hàng' : 'Shop Settings',
          style: IndieFolkTheme.h1(isDark).copyWith(fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAISection(isVi, isDark),
        ],
      ),
    );
  }

  Widget _buildAISection(bool isVi, bool isDark) {
    return Card(
      elevation: 0,
      color: IndieFolkTheme.surface(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isVi ? 'Trí tuệ nhân tạo (AI)' : 'Artificial Intelligence (AI)',
              style: IndieFolkTheme.h1(isDark).copyWith(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _aiEnabled,
              onChanged: _isSaving ? null : _toggleAIAssistant,
              title: Text(
                isVi ? 'AI Seller Assistant' : 'AI Seller Assistant',
                style: IndieFolkTheme.body(isDark).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                isVi
                    ? 'Tự động phản hồi khách hàng bằng AI khi shop Ngoại tuyến (Offline).'
                    : 'Auto-reply to customers using AI only when the shop is Offline.',
                style: IndieFolkTheme.label(isDark).copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              activeColor: IndieFolkTheme.primary(isDark),
            ),
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
