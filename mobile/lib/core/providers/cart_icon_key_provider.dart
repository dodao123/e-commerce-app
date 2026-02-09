import 'package:flutter/material.dart';

/// Provides the GlobalKey for the cart icon so product cards
/// can calculate the fly-to-cart animation target position.
class CartIconKeyProvider extends ChangeNotifier {
  /// GlobalKey attached to the cart icon in HomeAppBar.
  final GlobalKey cartIconKey = GlobalKey();
}
