
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cart_service.dart';
import 'shop_myorders.dart';

class ShopCheckoutPage extends StatefulWidget {
  const ShopCheckoutPage({super.key});

  @override
  State<ShopCheckoutPage> createState() => _ShopCheckoutPageState();
}

class _ShopCheckoutPageState extends State<ShopCheckoutPage> {
  final orange = const Color(0xFFF5A623);
  final blue = const Color(0xFF5094FF);
  final CartService _cartService = CartService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedPaymentMethod = 'cash';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('users')
            .select('full_name, contact_number')
            .eq('id', user.id)
            .single();

        if (response != null) {
          setState(() {
            _nameController.text = response['full_name'] ?? '';
            _phoneController.text = response['contact_number'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to place an order')),
        );
        return;
      }

      // Calculate total amount
      final totalAmount = _cartService.selectedItemsTotal;

      // Create the order
      final orderResponse = await Supabase.instance.client
          .from('shop_orders')
          .insert({
            'user_id': user.id,
            'full_name': _nameController.text,
            'contact_number': _phoneController.text,
            'message_to_admin': _messageController.text,
            'payment_method': _selectedPaymentMethod,
            'total_amount': totalAmount,
            'status': 'pending'
          })
          .select()
          .single();

      if (orderResponse == null) {
        throw Exception('Failed to create order');
      }

      final orderId = orderResponse['id'];

      // Create order items and update stock
      for (final item in _cartService.selectedItems) {
        // First, get the current stock
        final productResponse = await Supabase.instance.client
            .from('shop_products')
            .select('stock')
            .eq('id', item['id'])
            .single();

        final currentStock = productResponse['stock'] as int;
        final orderedQuantity = item['quantity'] as int;

        // Check if there's enough stock
        if (currentStock < orderedQuantity) {
          // Delete the order if stock check fails
          await Supabase.instance.client
              .from('shop_orders')
              .delete()
              .eq('id', orderId);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Sorry, only $currentStock ${item['name']} available in stock.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Update the stock
        await Supabase.instance.client.from('shop_products').update(
            {'stock': currentStock - orderedQuantity}).eq('id', item['id']);

        // Create order item
        await Supabase.instance.client.from('shop_order_items').insert({
          'order_id': orderId,
          'product_id': item['id'],
          'product_name': item['name'],
          'price': item['price'],
          'quantity': item['quantity'],
        });
      }

      // Clear selected items from cart
      for (final item in _cartService.selectedItems) {
        final index =
            _cartService.items.indexWhere((i) => i['id'] == item['id']);
        if (index != -1) {
          await _cartService.removeItem(index);
        }
      }

      // Show success message and navigate to ShopMyOrders page
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ShopMyOrders()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error placing order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to place order. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFF6E7),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Information',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: blue,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Contact Number',
                    labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your contact number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Order Summary',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: blue,
                  ),
                ),
                const SizedBox(height: 16),
                ..._cartService.selectedItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item['name']} x${item['quantity']}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            '₱${item['total_price']?.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount:',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '₱${_cartService.selectedItemsTotal.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Payment Method',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: blue,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: Text('Cash on Pickup',
                            style: GoogleFonts.poppins()),
                        value: 'cash',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() => _selectedPaymentMethod = value!);
                        },
                        activeColor: blue,
                      ),
                      RadioListTile<String>(
                        title: Text('GCash', style: GoogleFonts.poppins()),
                        value: 'gcash',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() => _selectedPaymentMethod = value!);
                        },
                        activeColor: blue,
                      ),
                      if (_selectedPaymentMethod == 'gcash') ...[
                        const SizedBox(height: 16),
                        Text('GCash Number: 09123456789',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Image.asset(
                          'assets/gcash_qr.png',
                          height: 200,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: const Icon(Icons.qr_code,
                                size: 80, color: Colors.grey),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Message to Admin (Optional)',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: blue,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _messageController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add any special instructions or requests...',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: orange),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Note: All orders are for pickup only. Please wait for confirmation from the admin.',
                          style: GoogleFonts.poppins(color: Colors.grey[800]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Place Order',
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
        ),
      ),
    );
  }
}

