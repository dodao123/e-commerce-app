import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/storage/token_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/product_remote_datasource.dart';
import '../../data/shop_remote_datasource.dart';
import '../widgets/product_info_banner.dart';
import '../widgets/product_tab_content.dart';
import 'add_product_page.dart';
import 'shop_welcome_page.dart';

/// Seller product management page with status tabs.
/// Tabs: All, Active, Inactive.
class ProductManagementPage extends StatefulWidget {
  /// Creates the ProductManagementPage widget.
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() =>
      _ProductManagementPageState();
}

class _ProductManagementPageState
    extends State<ProductManagementPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _bannerVisible = true;
  bool _shopChecked = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkShopExists();
  }

  /// Verify seller has a shop before showing products.
  Future<void> _checkShopExists() async {
    try {
      final token = await TokenManager().getToken();
      if (token == null) throw Exception('No token');
      final shop = await ShopRemoteDatasource()
          .getMyShop(token: token);
      if (!mounted) return;

      if (shop == null) {
        _showRegisterAlert();
        return;
      }
      setState(() => _shopChecked = true);
    _loadTabCounts();
    } catch (_) {
      if (!mounted) return;
      _showRegisterAlert();
    }
  }

  /// Shows an alert dialog telling user to register shop first.
  void _showRegisterAlert() {
    final isVi = context.read<AppProvider>()
        .locale.languageCode == 'vi';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(isVi ? 'Chưa có shop' : 'No shop found'),
        content: Text(isVi
            ? 'Bạn cần đăng ký thông tin shop trước khi '
              'quản lý sản phẩm.'
            : 'You need to register your shop before '
              'managing products.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(context,
                MaterialPageRoute(
                    builder: (_) => const ShopWelcomePage()));
            },
            child: Text(isVi ? 'Đăng ký ngay' : 'Register now',
              style: TextStyle(color: AppColors.primary,
                fontWeight: FontWeight.w600))),
        ]));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>()
        .locale.languageCode == 'vi';

    if (!_shopChecked) {
      return Scaffold(
        backgroundColor: isDark
            ? DarkColors.background : const Color(0xFFF5F5F5),
        appBar: _buildAppBar(isDark, isVi),
        body: const Center(child: CircularProgressIndicator(
          color: AppColors.primary)));
    }

    return Scaffold(
      backgroundColor: isDark
          ? DarkColors.background : const Color(0xFFF5F5F5),
      appBar: _buildAppBar(isDark, isVi),
      body: Column(children: [
        if (_bannerVisible)
          ProductInfoBanner(isVi: isVi, isDark: isDark,
            onDismiss: () =>
                setState(() => _bannerVisible = false)),
        _buildTabBar(isDark, isVi),
        Expanded(child: TabBarView(
          controller: _tabController,
          children: _tabStatuses
              .map((s) => ProductTabContent(
                key: ValueKey('${s}_$_refreshKey'),
                isVi: isVi, isDark: isDark,
                status: s)).toList())),
      ]),
      bottomNavigationBar: _addProductButton(isDark, isVi),
    );
  }

  static const _tabStatuses = ['', 'active', 'inactive'];
  final _tabCounts = [0, 0, 0];

  Future<void> _loadTabCounts() async {
    try {
      final token = await TokenManager().getToken();
      if (token == null) return;
      final datasource = ProductRemoteDatasource();
      for (var i = 0; i < _tabStatuses.length; i++) {
        final list = await datasource.listProducts(
          token: token, status: _tabStatuses[i]);
        if (mounted) {
          setState(() => _tabCounts[i] = list.length);
        }
      }
    } catch (_) {}
  }

  PreferredSizeWidget _buildAppBar(bool isDark, bool isVi) {
    return AppBar(
      backgroundColor: isDark ? DarkColors.surface : Colors.white,
      elevation: 0.5,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios_rounded,
          color: isDark ? DarkColors.textPrimary : Colors.black87,
          size: 20)),
      title: Text(isVi ? 'Sản Phẩm của Tôi' : 'My Products',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
          color: isDark ? DarkColors.textPrimary : Colors.black87)),
      actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        _chatIcon(),
      ]);
  }

  Widget _chatIcon() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(children: [
        IconButton(icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {}),
        Positioned(right: 6, top: 6,
          child: Container(width: 16, height: 16,
            decoration: const BoxDecoration(
              color: AppColors.primary, shape: BoxShape.circle),
            child: const Center(child: Text('1',
              style: TextStyle(color: Colors.white,
                  fontSize: 9, fontWeight: FontWeight.bold))))),
      ]));
  }

  Widget _buildTabBar(bool isDark, bool isVi) {
    final labels = isVi
        ? ['Tất cả', 'Đang bán', 'Ngừng bán']
        : ['All', 'Active', 'Inactive'];
    return Container(
      color: isDark ? DarkColors.surface : Colors.white,
      child: TabBar(controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: isDark
            ? DarkColors.textSecondary : Colors.grey,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.w600),
        tabAlignment: TabAlignment.start,
        tabs: List.generate(labels.length, (i) =>
            Tab(text: '${labels[i]}\n(${_tabCounts[i]})'))));
  }

  int _refreshKey = 0;

  Widget _addProductButton(bool isDark, bool isVi) {
    return SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SizedBox(height: 48, width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            final result = await Navigator.push<bool>(context,
              MaterialPageRoute(
                  builder: (_) => const AddProductPage()));
            if (result == true && mounted) {
              setState(() => _refreshKey++);
              _loadTabCounts();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            elevation: 0),
          child: Text(
            isVi ? 'Thêm 1 sản phẩm mới' : 'Add new product',
            style: const TextStyle(fontSize: 15,
                fontWeight: FontWeight.w600))))));
  }
}
