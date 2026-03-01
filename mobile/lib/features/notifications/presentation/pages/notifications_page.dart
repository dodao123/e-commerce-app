import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/services/notification_polling_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../seller/presentation/pages/seller_order_detail_page.dart';
import '../../data/notification_datasource.dart';

/// Notifications page — fetches from backend API.
/// Listens to polling service unread count changes
/// to auto-refresh when new notifications arrive.
class NotificationsPage extends StatefulWidget {
  /// Creates the NotificationsPage widget.
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() =>
      _NotificationsPageState();
}

class _NotificationsPageState
    extends State<NotificationsPage> {
  final _ds = NotificationDatasource();
  final _polling = NotificationPollingService();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
    // Auto-refresh when unread count changes
    _polling.unreadCount.addListener(_onCountChanged);
  }

  @override
  void dispose() {
    _polling.unreadCount.removeListener(_onCountChanged);
    super.dispose();
  }

  void _onCountChanged() => _fetch();

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() => _loading = true);
    _items = await _ds.fetchAll();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isVi = context.watch<AppProvider>()
        .locale.languageCode == 'vi';
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(child: _buildContent(isVi, isDark)));
  }

  Widget _buildContent(bool isVi, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Text(
              isVi ? 'Thông Báo' : 'Notifications',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold))),
        const SizedBox(height: 16),
        Expanded(child: _body(isVi, isDark)),
      ]);
  }

  Widget _body(bool isVi, bool isDark) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator());
    }
    if (_items.isEmpty) return _emptyState(isVi, isDark);
    return RefreshIndicator(
      onRefresh: _fetch,
      child: ListView.builder(
          padding: const EdgeInsets.symmetric(
              horizontal: 16),
          itemCount: _items.length,
          itemBuilder: (_, i) =>
              _notifCard(_items[i], isVi, isDark)));
  }

  Widget _notifCard(Map<String, dynamic> n,
      bool isVi, bool isDark) {
    final isRead = n['is_read'] == true;
    final title = n['title'] ?? '';
    final body = n['body'] ?? '';
    final time = _fmtTime(n['created_at'] ?? '', isVi);
    return GestureDetector(
      onTap: () => _onTap(n),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead
              ? (isDark ? DarkColors.surface : Colors.white)
              : AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: isRead ? null : Border.all(
              color: AppColors.primary
                  .withValues(alpha: 0.2))),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12)),
            child: const Icon(
                Icons.shopping_bag_outlined,
                size: 22, color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: isRead
                          ? FontWeight.w400
                          : FontWeight.w600)),
              const SizedBox(height: 4),
              Text(body, maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12,
                      color: Colors.grey.shade600)),
              const SizedBox(height: 4),
              Text(time, style: TextStyle(fontSize: 11,
                  color: Colors.grey.shade400)),
            ])),
          if (!isRead)
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle)),
        ])));
  }

  void _onTap(Map<String, dynamic> n) async {
    final id = n['id']?.toString() ?? '';
    if (id.isNotEmpty && n['is_read'] != true) {
      await _ds.markRead(id);
      _polling.refresh();
    }
    final refId = n['ref_id']?.toString() ?? '';
    if (mounted && refId.isNotEmpty) {
      await Navigator.push(context, MaterialPageRoute(
          builder: (_) => SellerOrderDetailPage(
              orderId: refId)));
      _fetch();
    }
  }

  String _fmtTime(String iso, bool isVi) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) {
        return isVi ? 'Vừa xong' : 'Just now';
      }
      if (diff.inMinutes < 60) {
        return isVi ? '${diff.inMinutes} phút trước'
            : '${diff.inMinutes}m ago';
      }
      if (diff.inHours < 24) {
        return isVi ? '${diff.inHours} giờ trước'
            : '${diff.inHours}h ago';
      }
      return isVi ? '${diff.inDays} ngày trước'
          : '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }

  Widget _emptyState(bool isVi, bool isDark) {
    return Center(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.notifications_none_rounded, size: 80,
            color: isDark ? DarkColors.textSecondary
                : AppColors.textSecondary),
        const SizedBox(height: 16),
        Text(isVi ? 'Chưa có thông báo'
            : 'No notifications yet',
            style: TextStyle(fontSize: 16,
                color: isDark ? DarkColors.textSecondary
                    : AppColors.textSecondary)),
      ]));
  }
}
