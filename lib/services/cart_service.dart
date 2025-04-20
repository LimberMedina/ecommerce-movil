import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart'; // ✅ Usa solo esta clase CartItem

class CartService extends ChangeNotifier {
  static const String _cartKey = 'user_cart';
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get total => _items.fold(0, (sum, item) => sum + item.total);

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);

    if (cartJson != null) {
      try {
        final cartList = jsonDecode(cartJson) as List;
        _items = cartList.map((item) => CartItem.fromJson(item)).toList();
        notifyListeners();
      } catch (e) {
        if (kDebugMode) {
          print('[CartService] Error al cargar carrito: $e');
        }
        _items = [];
      }
    }
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(_items.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKey, cartJson);
    notifyListeners();
  }

  void addItem(product, {int quantity = 1}) {
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      final newQty = (_items[index].quantity + quantity)
          .clamp(1, product.stock)
          .toInt(); // 👈 FIX
      _items[index].quantity = newQty;
    } else {
      _items.add(
        CartItem(
          product: product,
          quantity: quantity.clamp(1, product.stock).toInt(), // 👈 FIX
        ),
      );
    }

    saveCart();
  }

  void updateQuantity(int productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity.clamp(1, _items[index].product.stock);
      }
      saveCart();
    }
  }

  void removeItem(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    saveCart();
  }

  void clearCart() {
    _items.clear();
    saveCart();
  }
}
