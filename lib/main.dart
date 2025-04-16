import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'services/cart_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final CartService _cartService = CartService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _cartService.loadCart(),
            builder: (context, snapshot) {
      return ChangeNotifierProvider<CartService>.value(
        value: _cartService,
        child: MaterialApp(
          title: 'Mi Tienda',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            fontFamily: 'Roboto',
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeScreen(),
            '/cart': (context) => const CartScreen(),
          },
        ),
      );

      },
    );
  }
}
