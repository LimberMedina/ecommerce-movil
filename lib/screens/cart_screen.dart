import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        actions: [
          if (cartService.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                cartService.clearCart();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Carrito vaciado')),
                );
              },
            ),
        ],
      ),
      body: cartService.items.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                Expanded(child: _buildCartList(cartService, context)),
                _buildSummarySection(cartService, context),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Tu carrito está vacío',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega productos para comenzar',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Explorar productos'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(CartService cartService, BuildContext context) {
    return ListView.builder(
      itemCount: cartService.items.length,
      itemBuilder: (context, index) {
        final item = cartService.items[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Imagen del producto
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: item.product.image != null
                          ? NetworkImage(item.product.image!)
                          : const AssetImage('assets/images/placeholder.png')
                              as ImageProvider,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Información del producto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${item.product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Botón para restar cantidad
                          InkWell(
                            onTap: () => cartService.updateQuantity(
                                item.product.id, item.quantity - 1),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.remove, size: 16),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          // Botón para sumar cantidad
                          InkWell(
                            onTap: () => cartService.updateQuantity(
                                item.product.id, item.quantity + 1),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.add, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Precio total y eliminar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${item.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => cartService.removeItem(item.product.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummarySection(CartService cartService, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${cartService.total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showCheckoutDialog(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text(
              'Proceder al pago',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar compra'),
        content: const Text('¿Deseas proceder con el pago de los productos en tu carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compra realizada con éxito')),
              );
              Provider.of<CartService>(context, listen: false).clearCart();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}