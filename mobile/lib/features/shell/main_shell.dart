import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/services/notification_polling_service.dart';
import '../../core/theme/app_colors.dart';
import '../home/presentation/pages/home_page.dart';
import '../home/presentation/widgets/home_app_bar.dart';
import '../notifications/presentation/pages/notifications_page.dart';
import '../menu/presentation/pages/menu_page.dart';

/// Main shell layout with fixed top bar and bottom navigation.
/// Both bars stay persistent during page scrolling and tab switches.
class MainShell extends StatefulWidget {
  /// Creates the MainShell widget.
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final _polling = NotificationPollingService();

  /// Pages corresponding to each bottom nav tab.
  final List<Widget> _pages = const [
    HomePage(),
    NotificationsPage(),
    MenuPage(),
  ];

  @override
  void initState() {
    super.initState();
    _polling.navigateToTab.addListener(_onNavigate);
  }

  @override
  void dispose() {
    _polling.navigateToTab.removeListener(_onNavigate);
    super.dispose();
  }

  void _onNavigate() {
    final tab = _polling.navigateToTab.value;
    if (tab >= 0 && tab < _pages.length) {
      setState(() => _currentIndex = tab);
      _polling.navigateToTab.value = -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVi = context.watch<AppProvider>().locale.languageCode == 'vi';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? DarkColors.backgroundGradient
              : AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(children: [
            // Fixed top bar
            const HomeAppBar(),
            // Expandable page content
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
            ),
          ]),
        ),
      ),
      bottomNavigationBar: _buildNavBar(isVi, isDark),
    );
  }

  Widget _buildNavBar(bool isVi, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08),
            blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded,
                  isVi ? 'Trang chủ' : 'Home', 0, isDark),
              _navItemWithBadge(
                  Icons.notifications_outlined,
                  isVi ? 'Thông báo' : 'Notifications',
                  1, isDark),
              _navItem(Icons.menu_rounded,
                  isVi ? 'Menu' : 'Menu', 2, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int idx, bool isDark) {
    final active = _currentIndex == idx;
    final color = active ? AppColors.primary
        : (isDark ? DarkColors.textSecondary : AppColors.textSecondary);

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = idx),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(width: 80,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 26, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
        ])),
    );
  }

  Widget _navItemWithBadge(
      IconData icon, String label, int idx,
      bool isDark) {
    return ValueListenableBuilder<int>(
      valueListenable:
          NotificationPollingService().unreadCount,
      builder: (_, count, __) {
        return GestureDetector(
          onTap: () => setState(() => _currentIndex = idx),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(width: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(clipBehavior: Clip.none,
                  children: [
                    Icon(icon, size: 26,
                        color: _currentIndex == idx
                            ? AppColors.primary
                            : (isDark
                                ? DarkColors.textSecondary
                                : AppColors.textSecondary)),
                    if (count > 0)
                      Positioned(right: -6, top: -4,
                        child: Container(
                          padding:
                              const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle),
                          constraints:
                              const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16),
                          child: Text('$count',
                              textAlign:
                                  TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight:
                                      FontWeight.bold)))),
                  ]),
                const SizedBox(height: 4),
                Text(label, style: TextStyle(
                    fontSize: 11,
                    color: _currentIndex == idx
                        ? AppColors.primary
                        : (isDark
                            ? DarkColors.textSecondary
                            : AppColors.textSecondary),
                    fontWeight: _currentIndex == idx
                        ? FontWeight.w600
                        : FontWeight.w400)),
              ])));
      });
  }
}
