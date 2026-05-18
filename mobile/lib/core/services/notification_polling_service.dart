import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/notifications/data/notification_datasource.dart';

/// Callback when notification is tapped.
typedef OnNotificationTap = void Function();

/// Polls backend for new notifications and shows
/// local system notifications when new ones arrive.
/// Supports role-based polling intervals and content.
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
  String _currentRole = 'buyer';
  bool _initialized = false;

  /// The current unread count (updated by polling).
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  /// Signals MainShell to switch to a specific tab.
  final ValueNotifier<int> navigateToTab = ValueNotifier<int>(-1);

  /// Initialize the local notifications plugin (idempotent).
  Future<void> init({OnNotificationTap? onTap}) async {
    if (_initialized) return;
    _initialized = true;
    _onTap = onTap;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (_) {
        navigateToTab.value = 1;
        _onTap?.call();
      },
    );
    // Create high-priority channel explicitly for Android 8+
    const channel = AndroidNotificationChannel(
      'driver_order_channel',
      'Thông báo đơn hàng',
      description: 'Thông báo đơn hàng mới cho tài xế và người dùng',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
    // Request POST_NOTIFICATIONS permission on Android 13+
    await androidPlugin?.requestNotificationsPermission();
  }

  /// Start polling every [seconds] interval with the given [role].
  /// Restarts polling if already running with different params.
  void startPolling({int seconds = 30, String? role}) {
    if (role != null) _currentRole = role;
    stopPolling();
    _poll(); // immediate first check
    _timer = Timer.periodic(
      Duration(seconds: seconds),
      (_) => _poll(),
    );
  }

  /// Stop polling.
  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _poll() async {
    try {
      final count = await _ds.fetchUnreadCount(_currentRole);
      if (count > _lastCount && _lastCount >= 0) {
        final newItems = count - _lastCount;
        await _showLocalNotification(newItems);
      }
      unreadCount.value = count;
      _lastCount = count;
    } catch (_) {
      // Ignore network errors silently during background polling
    }
  }

  Future<void> _showLocalNotification(int newCount) async {
    final isDriver = _currentRole == 'driver';
    final title = isDriver ? '🚚 Có đơn hàng cần giao!' : '🛍️ Thông báo mới!';
    final body = isDriver
        ? 'Bạn có $newCount đơn hàng mới đang chờ xác nhận'
        : 'Bạn có $newCount thông báo chưa đọc';

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'driver_order_channel',
        'Thông báo đơn hàng',
        channelDescription: 'Thông báo đơn hàng mới',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      ),
    );
    await _plugin.show(0, title, body, details);
  }

  /// Force refresh the unread count without triggering a local notification.
  Future<void> refresh({String? role}) async {
    if (role != null) _currentRole = role;
    try {
      final count = await _ds.fetchUnreadCount(_currentRole);
      unreadCount.value = count;
      _lastCount = count;
    } catch (_) {}
  }

  /// Reset state on logout and stop polling.
  void reset() {
    stopPolling();
    unreadCount.value = 0;
    _lastCount = -1;
    _currentRole = 'buyer';
  }
}
