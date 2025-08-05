import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Cart Item Model
class CartItem {
  final String productId;
  final String name;
  final String image;
  final double price;
  final double originalPrice;
  int quantity;
  final String category;
  final String? duration;
  final String? description;

  CartItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.originalPrice,
    required this.quantity,
    required this.category,
    this.duration,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'image': image,
      'price': price,
      'originalPrice': originalPrice,
      'quantity': quantity,
      'category': category,
      'duration': duration,
      'description': description,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      originalPrice: (map['originalPrice'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      category: map['category'] ?? '',
      duration: map['duration'],
      description: map['description'],
    );
  }
}

// Cart Service
class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;
  
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get totalSavings => _cartItems.fold(0, (sum, item) => sum + ((item.originalPrice - item.price) * item.quantity));

  // Load cart from Firestore
  Future<void> loadCart() async {
    if (_auth.currentUser == null) {
      _cartItems.clear();
      return;
    }
    
    try {
      final doc = await _firestore
          .collection('carts')
          .doc(_auth.currentUser!.uid)
          .get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _cartItems = (data['items'] as List<dynamic>? ?? [])
            .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
            .toList();
      } else {
        _cartItems.clear();
      }
    } catch (e) {
      print('Error loading cart: $e');
      _cartItems.clear();
    }
  }

  // Save cart to Firestore
  Future<void> saveCart() async {
    if (_auth.currentUser == null) return;
    
    try {
      await _firestore
          .collection('carts')
          .doc(_auth.currentUser!.uid)
          .set({
        'userId': _auth.currentUser!.uid,
        'items': _cartItems.map((item) => item.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  // Add item to cart
  Future<bool> addToCart(CartItem item) async {
    try {
      final existingIndex = _cartItems.indexWhere((i) => i.productId == item.productId);
      
      if (existingIndex != -1) {
        _cartItems[existingIndex].quantity += item.quantity;
      } else {
        _cartItems.add(item);
      }
      
      await saveCart();
      return true;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  // Update quantity
  Future<void> updateQuantity(String productId, int quantity) async {
    final index = _cartItems.indexWhere((item) => item.productId == productId);
    
    if (index != -1) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = quantity;
      }
      await saveCart();
    }
  }

  // Remove item
  Future<void> removeFromCart(String productId) async {
    _cartItems.removeWhere((item) => item.productId == productId);
    await saveCart();
  }

  // Clear cart
  Future<void> clearCart() async {
    _cartItems.clear();
    await saveCart();
  }

  // Get cart item count stream
  Stream<int> getCartItemCountStream() {
    if (_auth.currentUser == null) {
      return Stream.value(0);
    }
    
    return _firestore
        .collection('carts')
        .doc(_auth.currentUser!.uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return 0;
      }
      
      final items = snapshot.data()!['items'] as List<dynamic>? ?? [];
      return items.fold(0, (sum, item) => sum + (item['quantity'] as int? ?? 0));
    });
  }
}

// Shopping Cart Page
class ShoppingCartPage extends StatefulWidget {
  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  final CartService _cartService = CartService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    await _cartService.loadCart();
    setState(() {
      _isLoading = false;
    });
  }

  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 768;

  void _proceedToCheckout() {
    if (_auth.currentUser == null) {
      // Show login prompt
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Required'),
          content: Text('Please login to proceed with checkout.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/unified-login');
              },
              child: Text('Login'),
            ),
          ],
        ),
      );
      return;
    }

    if (_cartService.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Calculate totals
    final subtotal = _cartService.totalAmount;
    final tax = subtotal * 0.1; // 10% tax
    final total = subtotal + tax;

    // Create a service description from cart items
    final serviceDescriptions = _cartService.cartItems
        .map((item) => '${item.name} (x${item.quantity})')
        .join(', ');

    // Navigate to payment page with cart details
    Navigator.pushNamed(
      context,
      '/payment',
      arguments: {
        'items': _cartService.cartItems.map((item) => item.toMap()).toList(),
        'subtotal': subtotal.toStringAsFixed(2),
        'tax': tax.toStringAsFixed(2),
        'amount': total.toStringAsFixed(2),
        'customerName': _auth.currentUser!.displayName ?? 'Customer',
        'customerEmail': _auth.currentUser!.email,
        'customerPhone': '', // Add phone if available
        'service': serviceDescriptions,
        'quantity': _cartService.itemCount,
        'duration': _cartService.cartItems.first.duration ?? 'Variable',
        'isFromCart': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Shopping Cart (${_cartService.itemCount})',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_cartService.cartItems.isNotEmpty)
            TextButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Clear Cart'),
                    content: Text('Are you sure you want to remove all items from your cart?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text('Clear'),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true) {
                  await _cartService.clearCart();
                  setState(() {});
                }
              },
              icon: Icon(Icons.delete_outline, color: Colors.red),
              label: Text('Clear', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _cartService.cartItems.isEmpty
              ? _buildEmptyCart()
              : _buildCartContent(),
      bottomNavigationBar: _cartService.cartItems.isNotEmpty
          ? _buildCheckoutBar()
          : null,
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Add some products to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/products'),
            icon: Icon(Icons.shopping_bag),
            label: Text('Browse Products'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cart Summary
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_cartService.itemCount} items in cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                      if (_cartService.totalSavings > 0)
                        Text(
                          'You\'re saving \$${_cartService.totalSavings.toStringAsFixed(2)}!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          
          // Cart Items
          ...List.generate(_cartService.cartItems.length, (index) {
            final item = _cartService.cartItems[index];
            return _buildCartItem(item);
          }),
          
          SizedBox(height: 20),
          
          // Price Details
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 16),
                _buildPriceRow('Subtotal', '\$${_cartService.totalAmount.toStringAsFixed(2)}'),
                if (_cartService.totalSavings > 0)
                  _buildPriceRow(
                    'Discount',
                    '-\$${_cartService.totalSavings.toStringAsFixed(2)}',
                    color: Colors.green,
                  ),
                _buildPriceRow('Tax (10%)', '\$${(_cartService.totalAmount * 0.1).toStringAsFixed(2)}'),
                Divider(height: 24),
                _buildPriceRow(
                  'Total',
                  '\$${(_cartService.totalAmount * 1.1).toStringAsFixed(2)}',
                  isTotal: true,
                ),
              ],
            ),
          ),
          
          SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(item.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16),
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  item.category,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${item.price}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(width: 8),
                    if (item.originalPrice > item.price)
                      Text(
                        '\$${item.originalPrice}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Quantity Controls
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () async {
                  await _cartService.removeFromCart(item.productId);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Item removed from cart'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () async {
                          await _cartService.addToCart(item);
                          setState(() {});
                        },
                      ),
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, size: 18),
                      onPressed: () async {
                        if (item.quantity > 1) {
                          await _cartService.updateQuantity(item.productId, item.quantity - 1);
                          setState(() {});
                        }
                      },
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        item.quantity.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, size: 18),
                      onPressed: () async {
                        await _cartService.updateQuantity(item.productId, item.quantity + 1);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {Color? color, bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color ?? (isTotal ? Colors.grey.shade800 : Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  '\$${(_cartService.totalAmount * 1.1).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: isMobile(context) ? 1 : 0,
            child: ElevatedButton(
              onPressed: _proceedToCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile(context) ? 20 : 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock),
                  SizedBox(width: 8),
                  Text(
                    'Checkout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}