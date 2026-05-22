import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'cart_service.dart';
import 'shop_checkout.dart';

class ShopCartPage extends StatefulWidget {
  const ShopCartPage({super.key});

  @override
  State<ShopCartPage> createState() => _ShopCartPageState();
}

class _ShopCartPageState extends State<ShopCartPage> {
  final orange = const Color(0xFFF5A623);
  final blue = const Color(0xFF5094FF);
  final CartService _cartService = CartService();

  void _removeFromCart(int index) {
    setState(() {
      _cartService.removeItem(index);
    });
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity > 0 && newQuantity <= _cartService.items[index]['stock']) {
      setState(() {
        _cartService.updateQuantity(index, newQuantity);
      });
    }
  }

  void _showProductDetails(Map<String, dynamic> product) {
    final orange = const Color(0xFFF5A623);
    final blue = const Color(0xFF5094FF);

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                    'Product Details',
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
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantity:',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: product['quantity'] > 1
                                ? () => _updateQuantity(
                                    _cartService.items.indexOf(product),
                                    product['quantity'] - 1)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                            color: orange,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: orange),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product['quantity'].toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: product['quantity'] < product['stock']
                                ? () => _updateQuantity(
                                    _cartService.items.indexOf(product),
                                    product['quantity'] + 1)
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                            color: orange,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double get _totalAmount => _cartService.selectedItemsTotal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Cart',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFF6E7),
        elevation: 0,
      ),
      body: _cartService.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Your shopping cart is empty',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _cartService.items
                            .every((item) => item['isSelected'] ?? false),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value ?? false) {
                              _cartService.selectAllItems();
                            } else {
                              _cartService.deselectAllItems();
                            }
                          });
                        },
                        activeColor: blue,
                      ),
                      Text(
                        'Select All',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cartService.length,
                    itemBuilder: (context, index) {
                      final item = _cartService.items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => _showProductDetails(item),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: item['isSelected'] ?? false,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _cartService.toggleItemSelection(index);
                                    });
                                  },
                                  activeColor: blue,
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: (item['local_picture_path'] != null &&
                                          item['local_picture_path']!
                                              .isNotEmpty)
                                      ? Image.file(
                                          File(item['local_picture_path']!),
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        )
                                      : (item['picture'] != null &&
                                              item['picture']!.isNotEmpty)
                                          ? Image.network(
                                              item['picture']!,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey[200],
                                              child: const Icon(Icons.image,
                                                  color: Colors.grey),
                                            ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] ?? 'N/A',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₱${item['price']?.toStringAsFixed(2) ?? 'N/A'}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: orange,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: item['quantity'] > 1
                                                ? () => _updateQuantity(
                                                    index, item['quantity'] - 1)
                                                : null,
                                            icon: const Icon(
                                                Icons.remove_circle_outline),
                                            color: orange,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: orange),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              item['quantity'].toString(),
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: item['quantity'] <
                                                    item['stock']
                                                ? () => _updateQuantity(
                                                    index, item['quantity'] + 1)
                                                : null,
                                            icon: const Icon(
                                                Icons.add_circle_outline),
                                            color: orange,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Subtotal: ₱${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () => _removeFromCart(index),
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount:',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '₱${_totalAmount.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _cartService.selectedItems.isNotEmpty
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ShopCheckoutPage(),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Proceed to Checkout',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
  }
}
