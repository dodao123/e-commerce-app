import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/animation/fly_to_cart_animator.dart';
import 'core/providers/app_provider.dart';
import 'core/providers/cart_icon_key_provider.dart';
import 'core/providers/cart_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/shell/main_shell.dart';

/// Entry point of the Delivery App.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
