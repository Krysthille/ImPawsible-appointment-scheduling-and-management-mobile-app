import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;

  final _supabase = Supabase.instance.client;
  final List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> get items => _items;

  String? _currentUserId;

  CartService._internal() {
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _currentUserId = data.session?.user.id;
        _loadCart();
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUserId = null;
        _items.clear();
        notifyListeners();
      }
    });

    // Initial load if user is already signed in
    _currentUserId = _supabase.auth.currentUser?.id;
    if (_currentUserId != null) {
      await _loadCart();
    }
  }

  Future<void> _loadCart() async {
    try {
      if (_currentUserId == null) {
        debugPrint('No user ID available for loading cart');
        _items.clear();
        notifyListeners();
        return;
      }

      debugPrint('Loading cart for user: $_currentUserId');
      _items.clear();

      final response = await _supabase
          .from('shop_cart')
          .select('*, shop_products(*)')
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false);

      if (response != null) {
        debugPrint(
            'Found ${response.length} items in cart for user $_currentUserId');

        for (var item in response) {
          final product = item['shop_products'];
          if (product != null) {
            _items.add({
              'id': product['id'],
              'name': product['name'],
              'price': product['price'],
              'stock': product['stock'],
              'picture': product['picture'],
              'local_picture_path': product['local_picture_path'],
              'quantity': item['quantity'],
              'isSelected': item['is_selected'],
              'total_price': product['price'] * item['quantity'],
            });
          }
        }
        notifyListeners();
      }

      // Only load from local storage if user is not logged in
      if (_currentUserId == null && _items.isEmpty) {
        await _loadFromLocalStorage();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
      // Only load from local storage if user is not logged in
      if (_currentUserId == null) {
        await _loadFromLocalStorage();
      }
    }
  }

  Future<void> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart');
      if (cartJson != null) {
        final List<dynamic> decoded = jsonDecode(cartJson);
        _items.clear();
        _items.addAll(decoded.map((item) => Map<String, dynamic>.from(item)));
        debugPrint('Loaded ${_items.length} items from local storage');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading from local storage: $e');
    }
  }

  Future<void> _saveCart() async {
    try {
      if (_currentUserId == null) {
        debugPrint('No user ID available for saving cart');
        return;
      }

      debugPrint('Saving cart for user: $_currentUserId');

      // Get existing cart items
      final existingItems = await _supabase
          .from('shop_cart')
          .select('product_id')
          .eq('user_id', _currentUserId!);

      debugPrint('Existing cart items: ${existingItems.length}');

      // Create a map of existing product IDs
      final existingProductIds =
          existingItems.map((item) => item['product_id'].toString()).toSet();

      // Prepare items to insert and update
      final itemsToInsert = <Map<String, dynamic>>[];
      final itemsToUpdate = <Map<String, dynamic>>[];

      for (var item in _items) {
        final cartItem = {
          'user_id': _currentUserId!,
          'product_id': item['id'],
          'quantity': item['quantity'],
          'is_selected': item['isSelected'] ?? false,
          'price': item['price'],
        };

        if (existingProductIds.contains(item['id'].toString())) {
          itemsToUpdate.add(cartItem);
        } else {
          itemsToInsert.add(cartItem);
        }
      }

      debugPrint('Items to insert: ${itemsToInsert.length}');
      debugPrint('Items to update: ${itemsToUpdate.length}');

      // Delete items that are no longer in the cart
      final currentProductIds =
          _items.map((item) => item['id'].toString()).toSet();
      final itemsToDelete = existingProductIds.difference(currentProductIds);

      if (itemsToDelete.isNotEmpty) {
        debugPrint('Deleting items: ${itemsToDelete.length}');
        await _supabase
            .from('shop_cart')
            .delete()
            .eq('user_id', _currentUserId!)
            .inFilter('product_id', itemsToDelete.toList());
      }

      // Insert new items
      if (itemsToInsert.isNotEmpty) {
        debugPrint('Inserting new items');
        await _supabase.from('shop_cart').insert(itemsToInsert);
      }

      // Update existing items
      for (var item in itemsToUpdate) {
        debugPrint('Updating item: ${item['product_id']}');
        await _supabase
            .from('shop_cart')
            .update({
              'quantity': item['quantity'],
              'is_selected': item['is_selected'],
              'price': item['price'],
            })
            .eq('user_id', _currentUserId!)
            .eq('product_id', item['product_id']);
      }

      // Also save to local storage as backup
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(_items);
      await prefs.setString('cart', cartJson);
      debugPrint('Cart saved to local storage');
    } catch (e) {
      debugPrint('Error saving cart: $e');
      rethrow;
    }
  }

  Future<void> addItem(Map<String, dynamic> item) async {
    try {
      debugPrint('Adding item to cart: ${item['id']}');

      // Check if item already exists in cart
      final existingItemIndex =
          _items.indexWhere((cartItem) => cartItem['id'] == item['id']);

      if (existingItemIndex != -1) {
        // Item exists, update quantity if within stock limit
        final newQuantity =
            _items[existingItemIndex]['quantity'] + item['quantity'];
        if (newQuantity <= item['stock']) {
          _items[existingItemIndex]['quantity'] = newQuantity;
          _items[existingItemIndex]['total_price'] =
              _items[existingItemIndex]['price'] * newQuantity;
          debugPrint('Updated existing item quantity to: $newQuantity');
        } else {
          debugPrint('Cannot update quantity: exceeds stock limit');
          throw Exception('Quantity exceeds available stock');
        }
      } else {
        // Item doesn't exist, add it to the beginning
        _items.insert(0, item);
        debugPrint('Added new item to cart');
      }

      await _saveCart();
      notifyListeners();
      debugPrint('Cart updated successfully');
    } catch (e) {
      debugPrint('Error adding item to cart: $e');
      rethrow;
    }
  }

  Future<void> removeItem(int index) async {
    _items.removeAt(index);
    await _saveCart();
    notifyListeners();
  }

  Future<void> updateQuantity(int index, int newQuantity) async {
    if (newQuantity > 0 && newQuantity <= _items[index]['stock']) {
      _items[index]['quantity'] = newQuantity;
      _items[index]['total_price'] = _items[index]['price'] * newQuantity;
      await _saveCart();
      notifyListeners();
    }
  }

  Future<void> toggleItemSelection(int index) async {
    if (index >= 0 && index < _items.length) {
      _items[index]['isSelected'] = !(_items[index]['isSelected'] ?? false);
      await _saveCart();
      notifyListeners();
    }
  }

  Future<void> selectAllItems() async {
    for (var item in _items) {
      item['isSelected'] = true;
    }
    await _saveCart();
    notifyListeners();
  }

  Future<void> deselectAllItems() async {
    for (var item in _items) {
      item['isSelected'] = false;
    }
    await _saveCart();
    notifyListeners();
  }

  Future<void> clearCart() async {
    _items.clear();
    await _saveCart();
    notifyListeners();
  }

  List<Map<String, dynamic>> get selectedItems =>
      _items.where((item) => item['isSelected'] ?? false).toList();

  double get selectedItemsTotal {
    return selectedItems.fold(
        0, (sum, item) => sum + (item['total_price'] ?? 0));
  }

  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + (item['total_price'] ?? 0));
  }

  bool get isEmpty => _items.isEmpty;
  int get length => _items.length;
}
