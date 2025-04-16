// screens/home_screen.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';
import '../widgets/category_item.dart';
import 'product_detail_screen.dart';
import 'package:mi_tienda/services/cart_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  int? _selectedCategoryId;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await _apiService.getCategories();
      final products = await _apiService.getProducts(
        categoryId: _selectedCategoryId,
        search: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
      );

      setState(() {
        _categories = categories;
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error al cargar los datos'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _selectCategory(int? categoryId) {
    setState(() {
      // Si ya está seleccionada, la deseleccionamos
      _selectedCategoryId = (_selectedCategoryId == categoryId) ? null : categoryId;
    });
    _loadData();
  }

  void _search() {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartService = Provider.of<CartService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Tienda',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, size: 26),
                onPressed: () {
                  // Navegar al carrito
                  Navigator.pushNamed(context, '/cart');
                },
              ),
              if (cartService.itemCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartService.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Barra de búsqueda
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverToBoxAdapter(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _search();
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
            ),

            // Categorías horizontales
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 8),
                    child: Text(
                      'Categorías',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 56,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index == _categories.length - 1 ? 16 : 8,
                                ),
                                child: CategoryItem(
                                  category: _categories[index],
                                  isSelected: _selectedCategoryId == _categories[index].id,
                                  onTap: () => _selectCategory(_categories[index].id),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),

            // Título de productos
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategoryId != null
                          ? _categories
                              .firstWhere((cat) => cat.id == _selectedCategoryId)
                              .name
                          : 'Todos los productos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    if (_selectedCategoryId != null || _searchController.text.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedCategoryId = null;
                            _searchController.clear();
                          });
                          _loadData();
                        },
                        icon: const Icon(Icons.filter_list_off, size: 18),
                        label: const Text('Limpiar'),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Lista de productos
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: _isLoading
                  ? const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _products.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No se encontraron productos',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                                if (_selectedCategoryId != null || _searchController.text.isNotEmpty)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedCategoryId = null;
                                        _searchController.clear();
                                      });
                                      _loadData();
                                    },
                                    child: const Text('Limpiar filtros'),
                                  ),
                              ],
                            ),
                          ),
                        )
                      : SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = _products[index];
                              return ProductCard(
                                product: product,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailScreen(productId: product.id),
                                    ),
                                  );
                                },
                                onAddToCart: () {
                                  final cart = Provider.of<CartService>(context, listen: false);
                                  cart.addItem(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${product.name} añadido al carrito'),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            childCount: _products.length,
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}