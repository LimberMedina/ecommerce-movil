class ApiConfig {
  // Cambia esta URL según tu configuración
  static const String baseUrl = 'http://192.168.100.84:8000/api';

  // Endpoints
  static const String products = '/store/products/';
  static const String categories = '/store/categories/';
  static const String relatedProducts = '/store/products/';

  // Autenticación
  static const String login = '/auth/token/';
  static const String register = '/auth/register/';
}
