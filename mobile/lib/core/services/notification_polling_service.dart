import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/notifications/data/notification_datasource.dart';

/// Callback when notification is tapped.
typedef OnNotificationTap = void Function();

/// Polls backend for new notifications and shows
/// local system notifications when new ones arrive.
class NotificationPollingService {
  static final NotificationPollingService _instance =
      NotificationPollingService._();

  /// Singleton accessor.
  factory NotificationPollingService() => _instance;
  NotificationPollingService._();

  final _ds = NotificationDatasource();
  final _plugin = FlutterLocalNotificationsPlugin();
  Timer? _timer;
  int _lastCount = 0;
  OnNotificationTap? _onTap;

  /// The current unread count (updated by polling).
  final ValueNotifier<int> unreadCount =
      ValueNotifier<int>(0);

  /// Signals MainShell to switch to a specific tab.
  final ValueNotifier<int> navigateToTab =
      ValueNotifier<int>(-1);

  /// Initialize the local notifications plugin.
  Future<void> init({OnNotificationTap? onTap}) async {
    _onTap = onTap;
    const android = AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    const settings = InitializationSettings(
        android: android);
    await _plugin.initialize(settings,
        onDidReceiveNotificationResponse: (_) {
      // Switch to notifications tab
      navigateToTab.value = 1;
      _onTap?.call();
    });
  }

  /// Start polling every [seconds] interval.
  void startPolling({int seconds = 30}) {
    stopPolling();
    _poll(); // immediate first check
    _timer = Timer.periodic(
        Duration(seconds: seconds), (_) => _poll());
  }

  /// Stop polling.
  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _poll() async {
    final count = await _ds.fetchUnreadCount();
    unreadCount.value = count;
    if (count > _lastCount && _lastCount >= 0) {
      _showLocalNotification(count);
    }
    _lastCount = count;
  }

  Future<void> _showLocalNotification(int count) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'order_channel', 'Đơn hàng mới',
        channelDescription: 'Thông báo đơn hàng mới',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher'));
    await _plugin.show(0, 'Đơn hàng mới!',
        'Bạn có $count thông báo chưa đọc', details);
  }

  /// Force refresh the unread count.
  Future<void> refresh() async {
    final count = await _ds.fetchUnreadCount();
    unreadCount.value = count;
    _lastCount = count;
  }

  /// Reset state on logout
  void reset() {
    unreadCount.value = 0;
    _lastCount = -1;
  }
}
