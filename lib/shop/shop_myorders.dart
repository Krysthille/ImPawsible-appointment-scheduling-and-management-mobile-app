import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class ShopMyOrders extends StatefulWidget {
  const ShopMyOrders({super.key});

  @override
  State<ShopMyOrders> createState() => _ShopMyOrdersState();
}

class _ShopMyOrdersState extends State<ShopMyOrders>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> _orders = [];
  late TabController _tabController;

  final List<String> _orderStatuses = [
    'All',
    'pending',
    'Cancelled',
    'ready_for_pickup',
    'completed',
  ];

  final Color blue = const Color(0xFF5094FF);
  final Color orange = const Color(0xFFF5A623);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _orderStatuses.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _fetchOrders();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _fetchOrders();
    }
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final currentStatus = _orderStatuses[_tabController.index];
      debugPrint('Fetching orders for status: $currentStatus');
      
      var query = Supabase.instance.client.from('shop_orders');

      var selectQuery = query.select('''
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
      ''');

      selectQuery = selectQuery.eq('user_id', user.id);
      if (currentStatus != 'All') {
        selectQuery = selectQuery.eq('status', currentStatus);
      }

      final response = await selectQuery.order('created_at', ascending: false);
      debugPrint('Fetched orders response: $response');
      
      if (response != null) {
        setState(() {
          _orders = List<Map<String, dynamic>>.from(response);
          debugPrint('Updated orders list length: ${_orders.length}');
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load orders. Please try again.';
      });
      debugPrint('Error fetching orders: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelOrder(String orderId) async {
    try {
      setState(() => _isLoading = true);
      debugPrint('Attempting to cancel order: $orderId');
      
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // First verify we can read the order
      final orderCheck = await Supabase.instance.client
          .from('shop_orders')
          .select()
          .eq('id', orderId)
          .eq('user_id', user.id)
          .single();
      
      debugPrint('Order check response: $orderCheck');

      if (orderCheck == null) {
        throw Exception('Order not found or you do not have permission to access it');
      }

      // Now try to update the order
      final response = await Supabase.instance.client
          .from('shop_orders')
          .update({
            'status': 'Cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId)
          .eq('user_id', user.id)
          .select();
      
      debugPrint('Database update response: $response');

      if (response == null || response.isEmpty) {
        throw Exception('Failed to update order status. Please check your permissions.');
      }

      // Verify the update was successful
      final updatedOrder = await Supabase.instance.client
          .from('shop_orders')
          .select()
          .eq('id', orderId)
          .single();
      
      debugPrint('Verification of updated order: $updatedOrder');

      if (updatedOrder['status'] != 'Cancelled') {
        throw Exception('Order status was not updated correctly');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cancelled successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      debugPrint('Refreshing orders after cancellation');
      await _fetchOrders();
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel order: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatOrderNumber(String id, String createdAt) {
    final date = DateTime.parse(createdAt);
    final dateStr =
        '${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}${date.year}';
    final randomNum = id.substring(0, 4);
    return '$dateStr-$randomNum';
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'ready_for_pickup':
        return Colors.teal;
      case 'processing':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  Widget _buildImageWidget(String? imagePath) {
    if (imagePath == null) {
      return const Icon(Icons.image, size: 30);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imagePath.startsWith('http')
          ? Image.network(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error_outline, size: 30);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            )
          : Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error_outline, size: 30);
              },
            ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order Details',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: blue,
                          )),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                      'Order #${_formatOrderNumber(order['id'], order['created_at'])}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Date: ${_formatDate(order['created_at'])}',
                      style: GoogleFonts.poppins(color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(
                    'Payment Method: ${order['payment_method'].toString().toUpperCase()}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  const Divider(height: 24),
                  Text('Items:',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...List<Widget>.from(
                    (order['shop_order_items'] as List).map((item) {
                      final product = item['shop_products'];
                      final image =
                          product?['local_picture_path'] ?? product?['picture'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _buildImageWidget(image),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['product_name'],
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500)),
                                  Text(
                                    '${item['quantity']} x ₱${item['price'].toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                        color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₱${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                  color: orange, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Amount:',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      Text('₱${order['total_amount'].toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                              color: orange, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (order['status'] == 'pending' ||
                          order['status'] == 'processing')
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _cancelOrder(order['id']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text('Cancel Order',
                              style: GoogleFonts.poppins(color: Colors.white)),
                        ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    String? firstProductImage;
    if (order['shop_order_items'] != null &&
        (order['shop_order_items'] as List).isNotEmpty) {
      final product = order['shop_order_items'][0]['shop_products'];
      firstProductImage = product?['local_picture_path'] ?? product?['picture'];
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      'Order #${_formatOrderNumber(order['id'], order['created_at'])}',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_formatStatus(order['status']),
                        style: GoogleFonts.poppins(
                          color: _getStatusColor(order['status']),
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildImageWidget(firstProductImage),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((order['shop_order_items'] as List).isNotEmpty) ...[
                          Text(order['shop_order_items'][0]['product_name'],
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500)),
                          Text(
                              'x${order['shop_order_items'][0]['quantity']} • ₱${(order['shop_order_items'][0]['price'] * order['shop_order_items'][0]['quantity']).toStringAsFixed(2)}',
                              style:
                                  GoogleFonts.poppins(color: Colors.grey[700])),
                        ] else ...[
                          Text('No items in this order',
                              style: GoogleFonts.poppins(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey)),
                        ],
                        if ((order['shop_order_items'] as List).length > 1)
                          Text(
                            '+${(order['shop_order_items'] as List).length - 1} more items',
                            style: GoogleFonts.poppins(color: Colors.grey[600]),
                          ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'Total: ₱${order['total_amount']?.toStringAsFixed(2) ?? '0.00'}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: blue,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchOrders,
            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
            ),
            child:
                Text('Retry', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6E7),
        elevation: 0,
        title: Text('My Orders',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: blue,
          labelColor: blue,
          unselectedLabelColor: Colors.grey,
          tabs: _orderStatuses.map((status) {
            return Tab(
              text: _formatStatus(status),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _orderStatuses.map((status) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_hasError) {
            return _buildErrorWidget();
          }

          if (_orders.isEmpty) {
            return Center(
              child: Text(
                'No orders yet',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _orders.length,
            itemBuilder: (context, index) {
              final order = _orders[index];
              return _buildOrderCard(order);
            },
          );
        }).toList(),
      ),
    );
  }
}
