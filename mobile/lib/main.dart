import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/animation/fly_to_cart_animator.dart';
import 'core/providers/app_provider.dart';
import 'core/providers/cart_icon_key_provider.dart';
import 'core/providers/cart_provider.dart';
import 'core/services/notification_polling_service.dart';
import 'core/services/fcm_token_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/search/providers/search_provider.dart';
import 'features/shell/main_shell.dart';
 
/// Background FCM message handler (must be top-level function).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  await Firebase.initializeApp();
  // Background messages are shown automatically by FCM on Android.
  // No additional action needed here.
}

/// Entry point of the Delivery App.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartIconKeyProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: const DeliveryApp(),
    ),
  );
}

/// Root widget for the Delivery application.
class DeliveryApp extends StatefulWidget {
  const DeliveryApp({super.key});

  @override
  State<DeliveryApp> createState() => _DeliveryAppState();
}

class _DeliveryAppState extends State<DeliveryApp> {
  @override
  void initState() {
    super.initState();
    // Restore auth session from secure storage on startup
    Future.microtask(() async {
      final auth = context.read<AuthProvider>();
      await auth.checkAuthStatus();
      if (!mounted) return;
      if (auth.isLoggedIn && auth.userRole == 'buyer') {
        context.read<CartProvider>().fetchCount();
      }
      // Start polling with correct role (drivers need faster updates)
      if (auth.isLoggedIn) {
        final notifSvc = NotificationPollingService();
        await notifSvc.init();
        final interval = auth.userRole == 'driver' ? 10 : 30;
        notifSvc.startPolling(
          seconds: interval,
          role: auth.userRole,
        );
        // Register FCM token every startup (token can rotate)
        unawaited(FcmTokenService().registerToken());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    return MaterialApp(
      title: 'Delivery Store',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appProvider.themeMode,
      builder: (ctx, child) => FlyToCartOverlay(child: child!),
      home: const MainShell(),
    );
  }
}
