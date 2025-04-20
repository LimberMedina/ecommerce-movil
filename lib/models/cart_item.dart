import '../models/product.dart';
import '../models/category.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  /// Este método es el que espera el backend Django
  Map<String, dynamic> toOrderJson() => {
        'product': product.id,
        'quantity': quantity,
        'price': product.price,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final productData = json['product'];
    final categoryData = productData['category'];

    return CartItem(
      product: Product(
        id: productData['id'],
        name: productData['name'],
        description: productData['description'] ?? '',
        price: double.parse(productData['price'].toString()),
        stock: productData['stock'],
        image: productData['image'],
        category: Category(
          id: categoryData['id'],
          name: categoryData['name'],
          description: categoryData['description'] ?? '',
          image: categoryData['image'],
        ),
        createdAt: DateTime.now(),
      ),
      quantity: json['quantity'] ?? 1,
    );
  }
}
