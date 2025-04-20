import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/cart_item.dart';
import '../config/api.dart';

class ApiService {
  // Crear una orden en el backend
  Future<int?> createOrder(List<CartItem> cartItems, double totalPrice,
      String shippingAddress) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception("Usuario no autenticado");

    final orderData = {
      "shipping_address": shippingAddress,
      "total_price": totalPrice,
      "items": cartItems.map((item) => item.toOrderJson()).toList(),
    };

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/orders/create/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(orderData),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      print("❌ Error creando orden: ${response.body}");
      return null;
    }
  }

  // Crear un pago para una orden
  Future<bool> createPayment(int orderId, double amount, String method) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception("Usuario no autenticado");

    final paymentData = {
      "order_id": orderId,
      "amount": amount,
      "method": method,
    };

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/payments/create/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(paymentData),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print("❌ Error creando pago: ${response.body}");
      return false;
    }
  }

  // Obtener categorías
  Future<List<Category>> getCategories() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.categories}'),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is List) {
        return decoded.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Respuesta inválida: se esperaba una lista');
      }
    } else {
      throw Exception('Error al cargar categorías');
    }
  }

  // Obtener productos
  Future<List<Product>> getProducts({int? categoryId, String? search}) async {
    String url = '${ApiConfig.baseUrl}${ApiConfig.products}';
    List<String> params = [];

    if (categoryId != null) params.add('category=$categoryId');
    if (search != null && search.isNotEmpty) params.add('search=$search');

    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      if (decoded is List) {
        return decoded.map((json) => Product.fromJson(json)).toList();
      } else if (decoded is Map && decoded.containsKey('results')) {
        return (decoded['results'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
      } else {
        throw Exception('Formato de respuesta inválido');
      }
    } else {
      throw Exception('Error al cargar productos');
    }
  }

  // Obtener producto por ID
  Future<Product> getProductById(int productId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.products}$productId/'),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al cargar detalles del producto');
    }
  }

  // Obtener productos relacionados
  Future<List<Product>> getRelatedProducts(int productId) async {
    final response = await http.get(
      Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.relatedProducts}$productId/related/'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data.map<Product>((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar productos relacionados');
    }
  }
}
