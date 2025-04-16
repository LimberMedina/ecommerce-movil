import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/category.dart';
import '../config/api.dart';

class ApiService {
  // Obtener todas las categorías
Future<List<Category>> getCategories() async {
  final response = await http.get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.categories}'));

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);

    // ✅ Si el backend devuelve directamente una lista (como lo hace DRF sin paginación):
    if (decoded is List) {
      return decoded.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Respuesta inválida: se esperaba una lista');
    }
  } else {
    throw Exception('Error al cargar categorías');
  }
}

  // Obtener todos los productos (sin paginación)
  Future<List<Product>> getProducts({int? categoryId, String? search}) async {
    String url = '${ApiConfig.baseUrl}${ApiConfig.products}';
    
    // Agregar parámetros si existen
    List<String> params = [];
    if (categoryId != null) {
      params.add('category=$categoryId');
    }
    if (search != null && search.isNotEmpty) {
      params.add('search=$search');
    }
    
    if (params.isNotEmpty) {
      url += '?' + params.join('&');
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // ✅ No usar ['results'] si no tienes paginación
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar productos');
    }
  }

  // Obtener detalles de un producto
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
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.relatedProducts}$productId/related/'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar productos relacionados');
    }
  }
}
