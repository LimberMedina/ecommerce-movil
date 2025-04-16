import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../config/api.dart';
import '../services/cart_service.dart';
import '../services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Product> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = _apiService.getProductById(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.white70,
            child: Icon(
              Icons.arrow_back,
              color: Colors.black87,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.white70,
              child: Icon(
                Icons.share_outlined,
                color: Colors.black87,
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de compartir no implementada'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error al cargar el producto: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _productFuture = _apiService.getProductById(widget.productId);
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No se encontró el producto'));
          }

          final product = snapshot.data!;
          final isAvailable = product.stock > 0;
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del producto
                Hero(
                  tag: 'product-${product.id}',
                  child: SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: product.image != null
                        ? FadeInImage.assetNetwork(
                            placeholder: 'assets/images/placeholder.png',
                            image: product.image!.startsWith('http')
                                ? product.image!
                                : '${ApiConfig.baseUrl}${product.image}',
                            fit: BoxFit.cover,
                            imageErrorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              'assets/images/placeholder.png',
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'assets/images/placeholder.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),

                // Información del producto
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y precio
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre del producto
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Precio
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Categoría y disponibilidad
                      Row(
                        children: [
                          // Categoría
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  size: 16,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  product.category.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Disponibilidad
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? Colors.green[100]
                                  : Colors.red[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isAvailable ? Icons.check_circle : Icons.error,
                                  size: 16,
                                  color: isAvailable
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isAvailable
                                      ? 'En stock (${product.stock})'
                                      : 'Agotado',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isAvailable
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Descripción
                      const Text(
                        'Descripción',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description ?? 'No hay descripción disponible para este producto.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botón de añadir al carrito
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: isAvailable
                              ? () {
                                  final cartService = Provider.of<CartService>(context, listen: false);
                                  cartService.addItem(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${product.name} añadido al carrito'),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      action: SnackBarAction(
                                        label: 'Ver carrito',
                                        onPressed: () {
                                          Navigator.pushNamed(context, '/cart');
                                        },
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          icon: Icon(
                            Icons.shopping_cart,
                            size: 22,
                            color: isAvailable ? Colors.white : Colors.grey[400],
                          ),
                          label: Text(
                            isAvailable ? 'Añadir al carrito' : 'No disponible',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAvailable
                                ? colorScheme.primary
                                : Colors.grey[300],
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}