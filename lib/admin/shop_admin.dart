import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'home_admin.dart';
import 'bookings_admin.dart';
import 'shop_orders_admin.dart';
import 'messages_admin.dart';
import '../utils/notification_utils.dart';
import 'settings_admin.dart';


class ShopAdminPage extends StatefulWidget {
  const ShopAdminPage({super.key});

  @override
  State<ShopAdminPage> createState() => _ShopAdminPageState();
}

class _ShopAdminPageState extends State<ShopAdminPage> {
  int _selectedIndex = 2; // Set initial index to Shop
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  int _totalProducts = 0;
  int _totalOrders = 0;
  String _currentFilter = 'all'; // 'all' or 'out_of_stock'
  // int _unreadMessageCount = 0; // No longer needed

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDescriptionController =
      TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productStockController = TextEditingController();
  String? _imageUrl;
  XFile? _imageFile;
  String? _selectedProductType;

  final List<String> _productTypes = [
    'Food',
    'Toy',
    'Accessory',
    'Grooming',
    'Bedding',
    'Other'
  ];

  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchStatistics();
    // _fetchUnreadMessages(); // No longer needed
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productDescriptionController.dispose();
    _productPriceController.dispose();
    _productStockController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      dynamic response;
      if (_currentFilter == 'out_of_stock') {
        response = await Supabase.instance.client
            .from('shop_products')
            .select('*')
            .eq('stock', 0) // Filter for stock = 0
            .order('created_at', ascending: true);
      } else {
        response = await Supabase.instance.client
            .from('shop_products')
            .select('*')
            .order('created_at', ascending: true);
      }

      if (response != null && response is List) {
        setState(() {
          _products = response.cast<Map<String, dynamic>>();
        });
      } else {
        debugPrint('Supabase response is not a list or is null: $response');
        setState(() {
          _products = []; // Clear products if response is invalid
        });
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      setState(() {
        _products = []; // Clear products on error
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchStatistics() async {
    try {
      // Fetch total products
      final productsData = await Supabase.instance.client
          .from('shop_products')
          .select('id'); // Fetch minimal data to ensure GET request
      _totalProducts = (productsData as List).length;
      debugPrint('Fetched products count (via length): $_totalProducts');

      // Fetch total orders
      final ordersData = await Supabase.instance.client
          .from('shop_orders')
          .select('id'); // Fetch minimal data to ensure GET request
      _totalOrders = (ordersData as List).length;
      debugPrint('Fetched orders count (via length): $_totalOrders');

      setState(() {});
    } catch (e) {
      debugPrint('Error fetching statistics: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = image;
    });
  }

  Future<String?> _saveImageLocally(String productId) async {
    if (_imageFile == null) return null;

    try {
      // Get the application documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String productImagesDir = path.join(appDir.path, 'shop_products');

      // Create the directory if it doesn't exist
      final Directory dir = Directory(productImagesDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Create a unique filename
      final String extension = path.extension(_imageFile!.path);
      final String filename = '$productId$extension';
      final String localPath = path.join(productImagesDir, filename);

      // Copy the file to the new location
      await File(_imageFile!.path).copy(localPath);

      return localPath;
    } catch (e) {
      debugPrint('Error saving image locally: $e');
      return null;
    }
  }

  Future<String?> _uploadImage(String productId) async {
    if (_imageFile == null) return null;

    try {
      // Save image locally first
      final String? localPath = await _saveImageLocally(productId);
      if (localPath == null) return null;

      // Upload to Supabase
      final String path = 'product-images/$productId/${_imageFile!.name}';
      await Supabase.instance.client.storage.from('product-images').upload(
          path, File(_imageFile!.path),
          fileOptions: const FileOptions(upsert: true));

      final String publicUrl = Supabase.instance.client.storage
          .from('product-images')
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _addProduct() async {
    if (_productNameController.text.isEmpty ||
        _productDescriptionController.text.isEmpty ||
        _productPriceController.text.isEmpty ||
        _productStockController.text.isEmpty ||
        _selectedProductType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String productId = _uuid.v4();
      String? uploadedImageUrl = await _uploadImage(productId);
      String? localImagePath = await _saveImageLocally(productId);

      final response =
          await Supabase.instance.client.from('shop_products').insert({
        'id': productId,
        'name': _productNameController.text,
        'description': _productDescriptionController.text,
        'price': double.parse(_productPriceController.text),
        'stock': int.parse(_productStockController.text),
        'picture': uploadedImageUrl,
        'local_picture_path': localImagePath,
        'product_type': _selectedProductType,
      }).select();

      if (response != null && response is List && response.isNotEmpty) {
        debugPrint('Product added: ${response[0]}');
        if (_currentFilter == 'all') {
          setState(() {
            _products.add(response[0]); // Add new product to the list directly
          });
        }
        _fetchStatistics(); // Update statistics
      } else {
        debugPrint('Error adding product: $response');
      }
    } catch (e) {
      debugPrint('Error adding product: $e');
    } finally {
      _clearControllers();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProduct(Map<String, dynamic> product) async {
    if (_productNameController.text.isEmpty ||
        _productDescriptionController.text.isEmpty ||
        _productPriceController.text.isEmpty ||
        _productStockController.text.isEmpty ||
        _selectedProductType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? uploadedImageUrl;
      String? localImagePath;

      if (_imageFile != null) {
        uploadedImageUrl = await _uploadImage(product['id']);
        localImagePath = await _saveImageLocally(product['id']);
      }

      final Map<String, dynamic> updateData = {
        'name': _productNameController.text,
        'description': _productDescriptionController.text,
        'price': double.parse(_productPriceController.text),
        'stock': int.parse(_productStockController.text),
        'product_type': _selectedProductType,
      };

      if (uploadedImageUrl != null) {
        updateData['picture'] = uploadedImageUrl;
      }
      if (localImagePath != null) {
        updateData['local_picture_path'] = localImagePath;
      }

      final response = await Supabase.instance.client
          .from('shop_products')
          .update(updateData)
          .eq('id', product['id']);

      if (response != null && response is List && response.isNotEmpty) {
        debugPrint('Product updated: ${response[0]}');
        _fetchProducts();
      } else {
        debugPrint('Error updating product: $response');
      }
    } catch (e) {
      debugPrint('Error updating product: $e');
    } finally {
      _clearControllers();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProduct(String id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Delete from Supabase
      final response = await Supabase.instance.client
          .from('shop_products')
          .delete()
          .eq('id', id);

      if (response == null || response is List && response.isEmpty) {
        debugPrint('Product deleted');
        _fetchProducts();
      } else {
        debugPrint('Error deleting product: $response');
      }
    } catch (e) {
      debugPrint('Error deleting product: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearControllers() {
    _productNameController.clear();
    _productDescriptionController.clear();
    _productPriceController.clear();
    _productStockController.clear();
    _imageFile = null;
    _imageUrl = null;
    _selectedProductType = null;
  }

  // Helper to display product image from local or network
  Widget _buildProductImage(String? localPath, String? networkUrl, {double? height, double? width, BoxFit fit = BoxFit.cover}) {
    if (localPath != null && localPath.isNotEmpty && File(localPath).existsSync()) {
      return Image.file(
        File(localPath),
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: Icon(Icons.error_outline, color: Colors.grey, size: height ?? 80),
        ),
      );
    } else if (networkUrl != null && networkUrl.isNotEmpty) {
      return Image.network(
        networkUrl,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: Icon(Icons.error_outline, color: Colors.grey, size: height ?? 80),
        ),
      );
    } else {
      return Container(
        height: height,
        width: width,
        color: Colors.grey[200],
        child: Icon(Icons.image, size: height ?? 80, color: Colors.grey[400]),
      );
    }
  }

  void _showAddEditProductDialog({
    Map<String, dynamic>? product,
  }) {
    bool isEditing = product != null;

    if (isEditing) {
      _productNameController.text = product!['name'] ?? '';
      _productDescriptionController.text = product['description'] ?? '';
      _productPriceController.text = product['price']?.toString() ?? '';
      _productStockController.text = product['stock']?.toString() ?? '';
      // Set _imageUrl to local path if available, else to network URL
      if (product['local_picture_path'] != null && product['local_picture_path'].isNotEmpty) {
        _imageUrl = product['local_picture_path'];
      } else if (product['picture'] != null && product['picture'].isNotEmpty) {
        _imageUrl = product['picture'];
      } else {
        _imageUrl = null;
      }
      _imageFile = null;
      _selectedProductType = product['product_type'];
    } else {
      _clearControllers();
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          final orange = const Color(0xFFF5A623);
          final blue = const Color(0xFF5094FF);

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
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Edit Product' : 'Add New Product',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: blue,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _productNameController,
                          decoration: InputDecoration(
                            labelText: 'Product Name',
                            labelStyle:
                                GoogleFonts.poppins(color: Colors.grey[600]),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: blue,
                                width: 2,
                              ),
                            ),
                          ),
                          style: GoogleFonts.poppins(),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _productDescriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle:
                                GoogleFonts.poppins(color: Colors.grey[600]),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: blue,
                                width: 2,
                              ),
                            ),
                          ),
                          style: GoogleFonts.poppins(),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedProductType,
                              hint: Text(
                                'Select Product Type',
                                style: GoogleFonts.poppins(
                                    color: Colors.grey[600]),
                              ),
                              isExpanded: true,
                              items: _productTypes.map((String type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(
                                    type,
                                    style: GoogleFonts.poppins(),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedProductType = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _productPriceController,
                          decoration: InputDecoration(
                            labelText: 'Price',
                            labelStyle:
                                GoogleFonts.poppins(color: Colors.grey[600]),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: blue,
                                width: 2,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.poppins(),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _productStockController,
                          decoration: InputDecoration(
                            labelText: 'Stock Available',
                            labelStyle:
                                GoogleFonts.poppins(color: Colors.grey[600]),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: blue,
                                width: 2,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.poppins(),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Product Image',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: _imageFile != null
                              ? Image.file(File(_imageFile!.path),
                                  height: 250,
                                  width: double.infinity,
                                  fit: BoxFit.cover)
                              : _buildProductImage(
                                  (_imageUrl != null && File(_imageUrl!).existsSync()) ? _imageUrl : null,
                                  (_imageUrl != null && !File(_imageUrl!).existsSync()) ? _imageUrl : null,
                                  height: 250,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                  source: ImageSource.gallery);
                              setState(() {
                                _imageFile = image;
                              });
                            },
                            icon: const Icon(Icons.upload_file,
                                color: Colors.white),
                            label: Text(
                              'Upload Image',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: orange,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _clearControllers();
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: orange),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                    color: orange, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (isEditing) {
                                  _updateProduct(product!);
                                } else {
                                  _addProduct();
                                }
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blue,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                isEditing ? 'Save Changes' : 'Add Product',
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        });
  }

  // Future<void> _fetchUnreadMessages() async {
  //   final count = await NotificationUtils.getUnreadMessageCount();
  //   if (mounted) {
  //     setState(() {
  //       _unreadMessageCount = count;
  //     });
  //   }
  // }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeAdminPage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BookingsAdminPage()),
        );
        break;
      case 2:
        // Stay on shop page
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MessagesAdminPage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsAdminPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFF5A623);
    final blue = const Color(0xFF5094FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF6E7), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Shop Dashboard',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      'Total Products',
                      _totalProducts.toString(),
                      Icons.shopping_bag,
                      blue,
                    ),
                    _buildStatCard(
                      'Total Orders',
                      _totalOrders.toString(),
                      Icons.shopping_cart,
                      orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentFilter = 'all';
                          });
                          _fetchProducts();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentFilter == 'all'
                              ? const Color(0xFF5094FF)
                              : const Color(0xFF616161),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'All Products',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentFilter = 'out_of_stock';
                          });
                          _fetchProducts();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentFilter == 'out_of_stock'
                              ? const Color(0xFF5094FF)
                              : const Color.fromARGB(255, 133, 133, 133),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Out of Stock',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _isLoading
                    ? const SizedBox.shrink()
                    : _products.isEmpty
                        ? Text(
                            'No products added yet.',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              childAspectRatio: 0.50,
                            ),
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final product = _products[index];
                              return Card(
                                margin: EdgeInsets.zero,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: const Color.fromARGB(182, 255, 255, 255),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Expanded(
                                        flex: 2,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: _buildProductImage(
                                            product['local_picture_path'],
                                            product['picture'],
                                            height: double.infinity,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product['name'] ?? 'N/A',
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF5094FF),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              product['description'] ?? 'N/A',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
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
                                                color: const Color(0xFFF5A623),
                                              ),
                                            ),
                                            Text(
                                              'Stock: ${product['stock'] ?? 0}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color:
                                                    (product['stock'] ?? 0) > 0
                                                        ? Colors.green
                                                        : Colors.red,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit,
                                                      size: 18,
                                                      color: Colors.blueAccent),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  onPressed: () =>
                                                      _showAddEditProductDialog(
                                                          product: product),
                                                ),
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      size: 18,
                                                      color: Colors.redAccent),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  onPressed: () =>
                                                      _deleteProduct(
                                                          product['id']),
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
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditProductDialog(),
        backgroundColor: const Color(0xFF5094FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: orange,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: title == 'Total Orders' ? () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ShopOrdersAdmin()),
        );
      } : null,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 48),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAllOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('shop_orders')
          .select('''
            *,
            shop_order_items (
              id,
              product_id,
              product_name,
              price,
              quantity,
              shop_products (
                picture,
                local_picture_path
              )
            )
          ''')
          .order('created_at', ascending: false);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Orders',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5094FF),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400,
                    child: response == null || (response as List).isEmpty
                        ? Center(
                            child: Text(
                              'No orders found',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: (response as List).length,
                            itemBuilder: (context, index) {
                              final order = response[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Order #${order['id'].toString().substring(0, 8)}',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(order['status']).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              order['status'].toString().toUpperCase(),
                                              style: GoogleFonts.poppins(
                                                color: _getStatusColor(order['status']),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Customer: ${order['full_name']}',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      Text(
                                        'Contact: ${order['contact_number']}',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      Text(
                                        'Payment: ${order['payment_method'].toString().toUpperCase()}',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Items:',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      ...List<Widget>.from(
                                        (order['shop_order_items'] as List).map((item) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Text(
                                              '• ${item['product_name']} x${item['quantity']} - ₱${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                      const Divider(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Total:',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '₱${order['total_amount'].toStringAsFixed(2)}',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFF5A623),
                                            ),
                                          ),
                                        ],
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
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load orders'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'ready_for_pickup':
        return Colors.teal;
      case 'processing':
        return Colors.blue;
      case 'cancelled_by_user':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}
