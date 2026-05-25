import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/role_guard.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../chat/data/datasources/chat_remote_datasource.dart';
import '../../../chat/presentation/pages/chat_detail_page.dart';
import '../../../home/data/models/product_model.dart';
import 'shop_detail_header.dart';
import 'shop_detail_products.dart';
import 'shop_detail_about.dart';

/// Collapsible NestedScrollView scaffold for the Shop Detail page.
class ShopDetailScaffold extends StatelessWidget {
  final Map<String, dynamic> shop;
  final List<ProductModel> products;
  final bool isDark;

  const ShopDetailScaffold({
    super.key,
    required this.shop,
    required this.products,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isVi = Localizations.localeOf(context).languageCode == 'vi';
    final themeBg = isDark ? DarkColors.background : AppColors.background;
    final screenWidth = MediaQuery.of(context).size.width;
    final bannerHeight = screenWidth * 9 / 16;
    final expandedHeight = bannerHeight + 130;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: themeBg,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: expandedHeight,
              pinned: true,
              backgroundColor: themeBg,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : Colors.black87,
                  shadows: [
                    Shadow(color: Colors.white.withOpacity(0.9), blurRadius: 12),
                    Shadow(color: Colors.white.withOpacity(0.6), blurRadius: 4),
                  ],
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: isDark ? Colors.white : Colors.black87,
                    shadows: [
                      Shadow(color: Colors.white.withOpacity(0.9), blurRadius: 12),
                      Shadow(color: Colors.white.withOpacity(0.6), blurRadius: 4),
                    ],
                  ),
                  onPressed: () async {
                    final auth = context.read<AuthProvider>();
                    if (!auth.isLoggedIn || auth.accessToken == null) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                      return;
                    }
                    if (!RoleGuard.checkBuyerRole(context)) return;

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      final shopId = shop['id']?.toString() ?? '';
                      final shopName = shop['shop_name']?.toString() ?? '';
                      final token = auth.accessToken!;

                      final room = await ChatRemoteDatasource().getOrCreateRoom(
                        token: token,
                        roomType: 'customer_shop',
                        shopId: shopId,
                      );

                      if (context.mounted) {
                        Navigator.pop(context); // Close progress dialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailPage(
                              roomId: room.id,
                              partnerName: shopName,
                              partnerAvatar: room.partnerAvatar.isNotEmpty
                                  ? room.partnerAvatar
                                  : 'https://api.dicebear.com/7.x/adventurer/svg?seed=$shopId',
                            ),
                          ),
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        Navigator.pop(context); // Close progress dialog
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Không thể kết nối trò chuyện lúc này'),
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                    }
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.share_outlined,
                    color: isDark ? Colors.white : Colors.black87,
                    shadows: [
                      Shadow(color: Colors.white.withOpacity(0.9), blurRadius: 12),
                      Shadow(color: Colors.white.withOpacity(0.6), blurRadius: 4),
                    ],
                  ),
                  onPressed: () {},
                )
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: ShopDetailHeader(shop: shop, productsCount: products.length, isDark: isDark, isVi: isVi),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: themeBg,
                  child: TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
                    indicatorColor: AppColors.primary,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(text: isVi ? 'Sản phẩm' : 'Products'),
                      Tab(text: isVi ? 'Thông tin' : 'About Shop'),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              ShopDetailProducts(products: products, isDark: isDark, isVi: isVi),
              ShopDetailAbout(shop: shop, isDark: isDark, isVi: isVi),
            ],
          ),
        ),
      ),
    );
  }
}
