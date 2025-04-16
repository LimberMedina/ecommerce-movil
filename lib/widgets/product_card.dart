import 'package:flutter/material.dart';
import '../models/product.dart';
import '../config/api.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final isAvailable = product.stock > 0;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shadowColor: colorScheme.primary.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto con badge de disponibilidad
            Stack(
              children: [
                // Imagen
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: 150,
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
                
                // Badge de disponibilidad
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? Colors.green.withOpacity(0.9)
                          : Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      isAvailable ? 'Disponible' : 'Agotado',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Información del producto
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del producto
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  
                  // Categoría
                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.category.name,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Precio y botón de añadir
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Precio
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      
                      // Botón de añadir al carrito
                      ElevatedButton(
                        onPressed: isAvailable ? onAddToCart : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAvailable ? primaryColor : Colors.grey[300],
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          minimumSize: const Size(40, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Icon(
                          Icons.add_shopping_cart,
                          size: 20,
                          color: isAvailable ? Colors.white : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}