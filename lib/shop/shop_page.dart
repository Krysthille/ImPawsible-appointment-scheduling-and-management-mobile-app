import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'cart_service.dart';
import '../utils/notification_utils.dart';
import '../profile/profile_page.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _selectedIndex = 2; // Shop is at index 2

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  final CartService _cartService = CartService();

  final List<String> _productTypes = [
    'All',
    'Food',
    'Toy',
    'Accessory',
    'Grooming',
    'Bedding',
    'Other'
  ];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh products when returning from checkout
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      _fetchProducts();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await Supabase.instance.client
          .from('shop_products')
          .select('*')
          .order('created_at', ascending: true);

      if (response != null && response is List) {
        setState(() {
          _products = response.cast<Map<String, dynamic>>();
          _filterProducts(_searchController.text, _selectedCategory);
        });
      } else {
        debugPrint('Supabase response is not a list or is null: \$response');
      }
    } catch (e) {
      debugPrint('Error fetching products: \$e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    _filterProducts(_searchController.text, _selectedCategory);
  }

  void _filterProducts(String query, String category) {
    setState(() {
      Iterable<Map<String, dynamic>> tempProducts = _products;

      if (query.isNotEmpty) {
        tempProducts = tempProducts.where((product) {
          return product['name'].toLowerCase().contains(query.toLowerCase());
        });
      }

      if (category != 'All') {
        tempProducts = tempProducts.where((product) {
          return product['product_type'] == category;
        });
      }
      _filteredProducts = tempProducts.toList();
    });
  }

  void _showProductDetails(Map<String, dynamic> product) {
    final orange = const Color(0xFFF5A623);
    final blue = const Color(0xFF5094FF);
    int quantity = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Overview',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: (product['local_picture_path'] != null &&
                                product['local_picture_path']!.isNotEmpty)
                            ? Image.file(
                                File(product['local_picture_path']!),
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : (product['picture'] != null &&
                                    product['picture']!.isNotEmpty)
                                ? Image.network(
                                    product['picture']!,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 200,
                                    width: double.infinity,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image,
                                        size: 80, color: Colors.grey),
                                  ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        product['name'] ?? 'N/A',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product['description'] ?? 'No description available',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₱${product['price']?.toStringAsFixed(2) ?? 'N/A'}',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: orange,
                            ),
                          ),
                          Text(
                            'Stock: ${product['stock'] ?? 0}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: (product['stock'] ?? 0) > 0
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: quantity > 1
                                ? () {
                                    setState(() {
                                      quantity--;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                            color: orange,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: orange),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              quantity.toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: quantity < (product['stock'] ?? 0)
                                ? () {
                                    setState(() {
                                      quantity++;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                            color: orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: orange),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                  color: orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: (product['stock'] ?? 0) > 0
                                  ? () {
                                      // Add to cart
                                      final cartItem = {
                                        ...product,
                                        'quantity': quantity,
                                        'total_price':
                                            (product['price'] ?? 0) * quantity,
                                      };
                                      _cartService.addItem(cartItem);
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Added ${product['name']} to cart',
                                            style: GoogleFonts.poppins(),
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Add to Cart',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFF5A623);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6E7),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    hintText: 'Search products...',
                    hintStyle:
                        GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.grey),
              onPressed: () {
                // Filter action
              },
            ),
            IconButton(
              icon:
                  const Icon(Icons.shopping_bag_outlined, color: Colors.orange),
              onPressed: () {
                Navigator.pushNamed(context, '/shop_myorders');
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.orange),
              onPressed: () {
                Navigator.pushNamed(context, '/shop_cart');
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF6E7), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCategoryFilters(),
                    _buildProductGrid(),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _bottomNavBar(orange),
    );
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/grooming');
        break;
      case 2:
        // Stay on Shop page
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/messages');
        break;
      case 4:   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
        break;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _bottomNavBar(Color orange) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: orange,
      unselectedItemColor: Colors.grey[400],
      showSelectedLabels: true,
      showUnselectedLabels: true,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: 'Grooming',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          label: 'Shop',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message_outlined),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    final orange = const Color(0xFFF5A623);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _productTypes.map((type) {
            return _buildCategoryButton(
              type,
              _getIconForCategory(type),
              orange,
              _selectedCategory == type,
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'All':
        return Icons.all_inclusive;
      case 'Food':
        return Icons.restaurant;
      case 'Toy':
        return Icons.toys;
      case 'Accessory':
        return Icons.accessibility;
      case 'Grooming':
        return Icons.medical_services;
      case 'Bedding':
        return Icons.bed;
      default:
        return Icons.category;
    }
  }

  Widget _buildCategoryButton(
      String label, IconData icon, Color color, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: isSelected ? color : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedCategory = label;
              _filterProducts(_searchController.text, _selectedCategory);
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 80,
            height: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isSelected ? Colors.white : color, size: 28),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_filteredProducts.isEmpty && !_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _searchController.text.isEmpty && _selectedCategory == 'All'
                ? 'No products added yet.'
                : 'No matching products found.',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final orange = const Color(0xFFF5A623);
    return GestureDetector(
      onTap: () => _showProductDetails(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: (product['local_picture_path'] != null &&
                        product['local_picture_path']!.isNotEmpty)
                    ? Image.file(
                        File(product['local_picture_path']!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint(
                              'Error loading local image in shop page: \$error');
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.error_outline,
                                color: Colors.grey),
                          );
                        },
                      )
                    : (product['picture'] != null &&
                            product['picture']!.isNotEmpty)
                        ? Image.network(
                            product['picture']!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint(
                                  'Error loading network image in shop page: \$error');
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.error_outline,
                                    color: Colors.grey),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image,
                                size: 80,
                                color: Color.fromARGB(255, 188, 187, 187)),
                          ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'N/A',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₱${product['price']?.toStringAsFixed(2) ?? 'N/A'}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: orange,
                    ),
                  ),
                  Text(
                    'Stock: ${product['stock'] ?? 0}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: (product['stock'] ?? 0) > 0
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
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
