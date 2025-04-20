import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Product> _productFuture;
  late Future<List<Product>> _relatedProductsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _productFuture = _apiService.getProductById(widget.productId);
      _relatedProductsFuture = _apiService.getRelatedProducts(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: Colors.black87),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          } else if (!snapshot.hasData) {
            return Center(child: Text('No se encontró el producto'));
          }

          final product = snapshot.data!;
          final isAvailable = product.stock > 0;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProductImage(product),
                _buildProductDetails(product, isAvailable, context),
                _buildRecommendedProducts(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text('Error al cargar el producto', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
            SizedBox(height: 16),
            FilledButton(
              onPressed: _loadData,
              child: Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    return Hero(
      tag: 'product-${product.id}',
      child: SizedBox(
        height: 350,
        width: double.infinity,
        child: product.image != null
            ? Image.network(
                product.image!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/placeholder.png',
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildProductDetails(
      Product product, bool isAvailable, BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Chip(
                label: Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: theme.colorScheme.primary,
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(product.category.name),
                avatar: Icon(Icons.category_outlined, size: 18),
              ),
              Chip(
                label: Text(
                    isAvailable ? 'En stock (${product.stock})' : 'Agotado'),
                avatar: Icon(
                  isAvailable ? Icons.check_circle : Icons.error,
                  size: 18,
                  color: isAvailable ? Colors.green : Colors.red,
                ),
                backgroundColor:
                    isAvailable ? Colors.green.shade100 : Colors.red.shade100,
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            'Descripción',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            product.description,
            style: theme.textTheme.bodyLarge,
          ),
          SizedBox(height: 32),
          FilledButton.icon(
            onPressed: isAvailable
                ? () {
                    Provider.of<CartService>(context, listen: false)
                        .addItem(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} añadido al carrito'),
                        action: SnackBarAction(
                          label: 'Ver carrito',
                          onPressed: () =>
                              Navigator.pushNamed(context, '/cart'),
                        ),
                      ),
                    );
                  }
                : null,
            icon: Icon(Icons.shopping_cart),
            label: Text(isAvailable ? 'Añadir al carrito' : 'No disponible'),
            style: FilledButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
              backgroundColor: isAvailable ? null : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedProducts() {
    return FutureBuilder<List<Product>>(
      future: _relatedProductsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return SizedBox.shrink();

        final recommended = snapshot.data!;
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'También te podría interesar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommended.length,
                  itemBuilder: (context, index) {
                    final product = recommended[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(productId: product.id),
                          ),
                        );
                      },
                      child: Container(
                        width: 160,
                        margin: EdgeInsets.only(right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: product.image != null
                                    ? Image.network(
                                        product.image!,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/images/placeholder.png',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
