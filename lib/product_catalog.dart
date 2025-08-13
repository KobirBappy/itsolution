import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:itapp/shopping_cart.dart';

import 'unified_login.dart'; // Import the login popup

class ProductCatalogPage extends StatefulWidget {
  @override
  _ProductCatalogPageState createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends State<ProductCatalogPage>
    with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CartService _cartService = CartService();
  
  // ENHANCED ANIMATION CONTROLLERS - Similar to service page
  late AnimationController _controller;
  late AnimationController _heroController;
  late AnimationController _filterController;
  late AnimationController _marqueeController;
  late List<AnimationController> _cardControllers;
  
  // ENHANCED ANIMATIONS
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _heroSlideAnimation;
  late Animation<double> _marqueeAnimation;
  late Animation<Offset> _filterSlideAnimation;

  String _selectedCategory = 'All';
  String _sortBy = 'popular';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> categories = [
    'All',
    'Mobile Development',
    'Web Development',
    'E-commerce',
    'IoT Solutions',
    'Security',
    'Enterprise'
  ];

  final List<Map<String, dynamic>> sortOptions = [
    {'value': 'popular', 'label': 'Most Popular'},
    {'value': 'price_low', 'label': 'Price: Low to High'},
    {'value': 'price_high', 'label': 'Price: High to Low'},
    {'value': 'newest', 'label': 'Newest First'},
    {'value': 'discount', 'label': 'Biggest Discount'},
  ];

  @override
  void initState() {
    super.initState();
    
    // ENHANCED ANIMATION SETUP - Similar to service page
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _heroController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _filterController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _marqueeController = AnimationController(
      duration: Duration(seconds: 15),
      vsync: this,
    );
    
    // ENHANCED CARD CONTROLLERS - More like service page
    _cardControllers = List.generate(
      30, // Increased for more products
      (index) => AnimationController(
        duration: Duration(milliseconds: 800),
        vsync: this,
      ),
    );

    // ENHANCED ANIMATION DEFINITIONS
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _heroSlideAnimation = Tween<Offset>(
      begin: Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    ));
    
    _filterSlideAnimation = Tween<Offset>(
      begin: Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _filterController,
      curve: Curves.easeOutCubic,
    ));
    
    _marqueeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _marqueeController,
      curve: Curves.linear,
    ));

    // START ANIMATIONS - Similar to service page
    _heroController.forward();
    _controller.forward();
    _filterController.forward();
    _marqueeController.repeat();
    _animateCards();
    _cartService.loadCart();
  }

  // ENHANCED CARD ANIMATION - Similar to service page
  void _animateCards() async {
    for (int i = 0; i < _cardControllers.length; i++) {
      await Future.delayed(Duration(milliseconds: 150));
      if (mounted) {
        _cardControllers[i].forward();
      }
    }
  }

  void _resetCardAnimations() async {
    for (var controller in _cardControllers) {
      controller.reset();
    }
    await Future.delayed(Duration(milliseconds: 100));
    _animateCards();
  }

  @override
  void dispose() {
    _controller.dispose();
    _heroController.dispose();
    _filterController.dispose();
    _marqueeController.dispose();
    _searchController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Stream<QuerySnapshot> _getHeroOffersStream() {
    print('🚀 Starting hero offers stream...');
    
    try {
      return _firestore
          .collection('hero_offers')
          .where('isActive', isEqualTo: true)
          .orderBy('priority', descending: false)
          .snapshots();
    } catch (e) {
      print('❌ Error creating hero offers stream: $e');
      rethrow;
    }
  }

  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;
  bool isTablet(BuildContext context) => MediaQuery.of(context).size.width < 1200;

  Stream<QuerySnapshot> _getProductsStream() {
    Query query = _firestore.collection('products');

    // Apply category filter
    if (_selectedCategory != 'All') {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    // Apply sorting
    switch (_sortBy) {
      case 'price_low':
        query = query.orderBy('price');
        break;
      case 'price_high':
        query = query.orderBy('price', descending: true);
        break;
      case 'newest':
        query = query.orderBy('createdAt', descending: true);
        break;
      case 'discount':
        query = query.orderBy('discount', descending: true);
        break;
      case 'popular':
      default:
        query = query.orderBy('isPopular', descending: true);
        break;
    }

    return query.snapshots();
  }

  Future<void> _addToCart(
      String productId, Map<String, dynamic> productData) async {
    if (_auth.currentUser == null) {
      // Show beautiful login popup instead of dialog
      LoginPopupModal.show(context);
      return;
    }

    final cartItem = CartItem(
      productId: productId,
      name: productData['name'] ?? '',
      image: productData['image'] ?? '',
      price: (productData['price'] ?? 0).toDouble(),
      originalPrice: (productData['originalPrice'] ?? productData['price'] ?? 0)
          .toDouble(),
      quantity: 1,
      category: productData['category'] ?? '',
      duration: productData['duration'],
      description: productData['description'],
    );

    final success = await _cartService.addToCart(cartItem);

    if (success) {
      setState(() {}); // Refresh cart count

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Added to cart'),
              Spacer(),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  _showCartPopup();
                },
                child: Text('View Cart',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to cart'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showCartPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShoppingCartPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: _buildEnhancedAppBar(),
      body: Column(
        children: [
         // _buildEnhancedHeroSection(),
          _buildEnhancedSearchBar(),
          _buildEnhancedFilterBar(),
          Expanded(child: _buildProductsGrid()),
        ],
      ),
    );
  }

  // ENHANCED APP BAR - Similar to service page
  PreferredSizeWidget _buildEnhancedAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: Colors.grey.shade700, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ).createShader(bounds),
        child: Text(
          'Products',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      actions: [
        // Login/Register Buttons for unauthenticated users
        if (_auth.currentUser == null) ...[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton(
              onPressed: () => LoginPopupModal.show(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],

        // Enhanced Cart Icon
        Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.shopping_cart_outlined,
                      color: Colors.grey.shade700),
                  onPressed: _showCartPopup,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: StreamBuilder<int>(
                  stream: _cartService.getCartItemCountStream(),
                  builder: (context, snapshot) {
                    final itemCount = snapshot.data ?? 0;

                    return itemCount > 0
                        ? Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.red, Colors.red.shade700],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              itemCount > 99 ? '99+' : itemCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),

        // Enhanced User Avatar for authenticated users
        if (_auth.currentUser != null)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: PopupMenuButton(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _auth.currentUser!.email![0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 20),
                      SizedBox(width: 12),
                      Text('Profile'),
                    ],
                  ),
                  value: 'profile',
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.shopping_bag, size: 20),
                      SizedBox(width: 12),
                      Text('My Orders'),
                    ],
                  ),
                  value: 'orders',
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.shopping_cart, size: 20),
                      SizedBox(width: 12),
                      Text('Cart'),
                    ],
                  ),
                  value: 'cart',
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  value: 'logout',
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    Navigator.pushNamed(context, '/profile');
                    break;
                  case 'orders':
                    // Navigate to orders page
                    break;
                  case 'cart':
                    _showCartPopup();
                    break;
                  case 'logout':
                    _signOut();
                    break;
                }
              },
            ),
          ),
      ],
    );
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      setState(() {}); // Refresh the UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully logged out'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // ENHANCED HERO SECTION WITH MARQUEE - Similar to service page
  Widget _buildEnhancedHeroSection() {
    return SlideTransition(
      position: _heroSlideAnimation,
      child: FadeTransition(
        opacity: _heroController,
        child: Container(
          margin: EdgeInsets.all(20),
          height: isMobile(context) ? 120 : 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: _getHeroOffersStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _buildStaticHeroSection();
              }
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingHeroSection();
              }
              
              final heroOffers = snapshot.data!.docs;
              
              if (heroOffers.isEmpty) {
                return _buildStaticHeroSection();
              }
              
              // MARQUEE EFFECT
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AnimatedBuilder(
                  animation: _marqueeAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: _getGradientColors(
                          heroOffers.isNotEmpty 
                            ? (heroOffers[0].data() as Map<String, dynamic>)['gradientType'] ?? 'orange'
                            : 'orange'
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          // Scrolling content
                          Positioned(
                            left: _getMarqueePosition(heroOffers.length),
                            child: Row(
                              children: [
                                // First set of offers
                                ...heroOffers.map((doc) {
                                  final data = doc.data() as Map<String, dynamic>;
                                  return _buildMarqueeItem(data);
                                }).toList(),
                                // Duplicate for seamless loop
                                ...heroOffers.map((doc) {
                                  final data = doc.data() as Map<String, dynamic>;
                                  return _buildMarqueeItem(data);
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // MARQUEE ITEM - Simplified hero content
  Widget _buildMarqueeItem(Map<String, dynamic> heroData) {
    final iconData = _getIconData(heroData['iconType'] ?? 'fire');
    
    return Container(
      width: MediaQuery.of(context).size.width * 0.8, // Adjust width
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getIconGradientColors(heroData['iconGradient'] ?? 'orange_red'),
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          
          // Text content
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heroData['title'] ?? 'Special Offers',
                  style: TextStyle(
                    fontSize: isMobile(context) ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  heroData['subtitle'] ?? 'Amazing deals await you!',
                  style: TextStyle(
                    fontSize: isMobile(context) ? 12 : 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Action button (optional)
          if (heroData['hasAction'] == true && heroData['actionText'] != null)
            Container(
              margin: EdgeInsets.only(left: 12),
              child: ElevatedButton(
                onPressed: () => _handleHeroAction(heroData),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  heroData['actionText'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // MARQUEE POSITION CALCULATION
  double _getMarqueePosition(int itemCount) {
    if (itemCount == 0) return 0;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth * 0.8;
    final totalWidth = itemWidth * itemCount;
    
    // Move from right to left
    return -(_marqueeAnimation.value * totalWidth);
  }

  // SIMPLIFIED GRADIENT (using the first offer's gradient)
  LinearGradient _getGradientColors(String gradientType) {
    switch (gradientType) {
      case 'blue':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400.withOpacity(0.1),
            Colors.indigo.shade400.withOpacity(0.1),
          ],
        );
      case 'green':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade400.withOpacity(0.1),
            Colors.teal.shade400.withOpacity(0.1),
          ],
        );
      case 'purple':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade400.withOpacity(0.1),
            Colors.pink.shade400.withOpacity(0.1),
          ],
        );
      case 'orange':
      default:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade400.withOpacity(0.1),
            Colors.red.shade400.withOpacity(0.1),
          ],
        );
    }
  }

  IconData _getIconData(String iconType) {
    switch (iconType) {
      case 'star': return Icons.star;
      case 'flash': return Icons.flash_on;
      case 'gift': return Icons.card_giftcard;
      case 'sale': return Icons.local_offer;
      case 'percent': return Icons.percent;
      case 'fire':
      default: return Icons.local_fire_department;
    }
  }

  List<Color> _getIconGradientColors(String gradientType) {
    switch (gradientType) {
      case 'blue_purple': return [Colors.blue, Colors.purple];
      case 'green_teal': return [Colors.green, Colors.teal];
      case 'purple_pink': return [Colors.purple, Colors.pink];
      case 'orange_red':
      default: return [Colors.orange, Colors.red];
    }
  }

  void _handleHeroAction(Map<String, dynamic> heroData) {
    final actionType = heroData['actionType'] ?? 'none';
    
    switch (actionType) {
      case 'category':
        setState(() {
          _selectedCategory = heroData['actionValue'] ?? 'All';
        });
        break;
      case 'cart':
        _showCartPopup();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${heroData['title']} activated!'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
    }
  }

  // SIMPLIFIED LOADING/STATIC SECTIONS
  Widget _buildLoadingHeroSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade200, Colors.grey.shade100],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Loading offers...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticHeroSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400.withOpacity(0.1),
            Colors.red.shade400.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.orange, Colors.red]),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_fire_department, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Special Launch Offers',
                  style: TextStyle(
                    fontSize: isMobile(context) ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  'Up to 75% OFF - Limited time!',
                  style: TextStyle(
                    fontSize: isMobile(context) ? 12 : 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildStatCard(String number, String label, {required int fontSize}) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //     decoration: BoxDecoration(
  //       color: Colors.white.withOpacity(0.8),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: Colors.white.withOpacity(0.3)),
  //     ),
  //     child: Column(
  //       children: [
  //         Text(
  //           number,
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //             color: Color(0xFF667EEA),
  //           ),
  //         ),
  //         Text(
  //           label,
  //           style: TextStyle(
  //             fontSize: 12,
  //             color: Colors.grey.shade600,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ENHANCED SEARCH BAR - Similar to service page
  Widget _buildEnhancedSearchBar() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search amazing products...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Container(
                  padding: EdgeInsets.all(12),
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ).createShader(bounds),
                    child: Icon(Icons.search, color: Colors.white),
                  ),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade600),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  // ENHANCED FILTER BAR - Similar to service page
  Widget _buildEnhancedFilterBar() {
    return SlideTransition(
      position: _filterSlideAnimation,
      child: Container(
        height: 60,
        margin: EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            // Categories
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategory == category;
                  
                  return Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: FilterChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                          _resetCardAnimations();
                        },
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xFF667EEA),
                        checkmarkColor: Colors.white,
                        elevation: isSelected ? 4 : 1,
                        shadowColor: Color(0xFF667EEA).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? Color(0xFF667EEA) : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Enhanced Sort Dropdown
            Container(
              margin: EdgeInsets.only(right: 20),
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButton<String>(
                value: _sortBy,
                underline: SizedBox(),
                icon: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ).createShader(bounds),
                  child: Icon(Icons.sort, size: 20, color: Colors.white),
                ),
                items: sortOptions.map<DropdownMenuItem<String>>((option) {
                  return DropdownMenuItem<String>(
                    value: option['value'] as String,
                    child: Text(
                      option['label'],
                      style: TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                  _resetCardAnimations();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: StreamBuilder<QuerySnapshot>(
        stream: _getProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 80, color: Colors.red.shade300),
                  SizedBox(height: 16),
                  Text('Error loading products',
                      style:
                          TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                  ),
                  SizedBox(height: 16),
                  Text('Loading amazing products...',
                      style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          var products = snapshot.data!.docs;

          // Apply search filter
          if (_searchQuery.isNotEmpty) {
            products = products.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'].toString().toLowerCase();
              final description = data['description'].toString().toLowerCase();
              return name.contains(_searchQuery) ||
                  description.contains(_searchQuery);
            }).toList();
          }

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 100,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No products found',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Try adjusting your search or filters',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'All';
                        _searchQuery = '';
                        _searchController.clear();
                      });
                      _resetCardAnimations();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text('Clear filters'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile(context) ? 2 : isTablet(context) ? 3 : 4,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: isMobile(context) ? 0.85 : 0.95,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final data = product.data() as Map<String, dynamic>;
              return _buildEnhancedProductCard(product.id, data, index);
            },
          );
        },
      ),
    );
  }

  // ENHANCED PRODUCT CARD - Similar to service page animation
  Widget _buildEnhancedProductCard(
      String productId, Map<String, dynamic> data, int index) {
    final badgeColors = {
      'orange': Colors.orange,
      'blue': Colors.blue,
      'red': Colors.red,
      'green': Colors.green,
      'purple': Colors.purple,
      'indigo': Colors.indigo,
    };

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _cardControllers[index % _cardControllers.length],
        curve: Curves.easeOutCubic,
      )),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _cardControllers[index % _cardControllers.length],
          curve: Curves.easeOutBack,
        )),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _showProductDetails(productId, data),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF667EEA).withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Image with badges
                  Stack(
                    children: [
                      Container(
                        height: isMobile(context) ? 100 : 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          image: DecorationImage(
                            image: NetworkImage(data['image'] ?? ''),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        height: isMobile(context) ? 100 : 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                      // Discount badge
                      if (data['discount'] != null && data['discount'] > 0)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.red, Colors.red.shade700],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${data['discount']}% OFF',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      // Category badge
                      if (data['badge'] != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeColors[data['badgeColor']] ?? Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: (badgeColors[data['badgeColor']] ?? Colors.grey).withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              data['badge'],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Enhanced product details
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['name'] ?? '',
                                style: TextStyle(
                                  fontSize: isMobile(context) ? 13 : 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              // Rating
                              if (data['rating'] != null)
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.amber, size: 14),
                                    SizedBox(width: 2),
                                    Text(
                                      '${data['rating']} (${data['reviewCount'] ?? 0})',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          // Enhanced Price and Actions
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [Colors.green, Colors.green.shade700],
                                    ).createShader(bounds),
                                    child: Text(
                                      '\$${data['price']}',
                                      style: TextStyle(
                                        fontSize: isMobile(context) ? 16 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  if (data['originalPrice'] != null)
                                    Text(
                                      '\$${data['originalPrice']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.orange, Colors.orange.shade700],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.orange.withOpacity(0.3),
                                            blurRadius: 8,
                                            spreadRadius: 0,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () => _addToCart(productId, data),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          padding: EdgeInsets.symmetric(vertical: 6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.add_shopping_cart,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF667EEA).withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 0,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () => _showProductDetails(productId, data),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Text(
                                        'View',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showProductDetails(String productId, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          productId: productId,
          productData: data,
        ),
      ),
    );
  }
}

// Enhanced Product Detail Page (keeping the existing implementation)
class ProductDetailPage extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const ProductDetailPage({
    Key? key,
    required this.productId,
    required this.productData,
  }) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CartService _cartService = CartService();
  int quantity = 1;

  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  Future<void> _addToCart() async {
    if (_auth.currentUser == null) {
      LoginPopupModal.show(context);
      return;
    }

    final cartItem = CartItem(
      productId: widget.productId,
      name: widget.productData['name'] ?? '',
      image: widget.productData['image'] ?? '',
      price: (widget.productData['price'] ?? 0).toDouble(),
      originalPrice: (widget.productData['originalPrice'] ??
              widget.productData['price'] ??
              0)
          .toDouble(),
      quantity: quantity,
      category: widget.productData['category'] ?? '',
      duration: widget.productData['duration'],
      description: widget.productData['description'],
    );

    final success = await _cartService.addToCart(cartItem);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Added to cart'),
              Spacer(),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  _showCartPopup();
                },
                child: Text('View Cart',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showCartPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShoppingCartPopup(),
    );
  }

  void _proceedToCheckout() {
    if (_auth.currentUser == null) {
      LoginPopupModal.show(context);
      return;
    }

    // Calculate total
    final price = widget.productData['price'] ?? 0;
    final subtotal = price * quantity;
    final tax = subtotal * 0.1; // 10% tax
    final total = subtotal + tax;

    // Navigate to payment page
    Navigator.pushNamed(
      context,
      '/payment',
      arguments: {
        'productId': widget.productId,
        'productName': widget.productData['name'],
        'quantity': quantity,
        'subtotal': subtotal.toStringAsFixed(2),
        'tax': tax.toStringAsFixed(2),
        'amount': total.toStringAsFixed(2),
        'customerName': _auth.currentUser!.displayName ?? 'Customer',
        'customerEmail': _auth.currentUser!.email,
        'customerPhone': '', // Add phone if available
        'service': widget.productData['name'],
        'duration': widget.productData['duration'] ?? 'Variable',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final badgeColors = {
      'orange': Colors.orange,
      'blue': Colors.blue,
      'red': Colors.red,
      'green': Colors.green,
      'purple': Colors.purple,
      'indigo': Colors.indigo,
    };

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                color: Colors.grey.shade700, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          widget.productData['name'] ?? 'Product Details',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart_outlined,
                  color: Colors.grey.shade700),
              onPressed: _showCartPopup,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Product Image
            Container(
              height: 250,
              width: double.infinity,
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                              NetworkImage(widget.productData['image'] ?? ''),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                    // Badges
                    if (widget.productData['discount'] != null &&
                        widget.productData['discount'] > 0)
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Colors.red, Colors.red.shade700]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${widget.productData['discount']}% OFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    if (widget.productData['badge'] != null)
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                badgeColors[widget.productData['badgeColor']] ??
                                    Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.productData['badge'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Enhanced Product Info
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Category
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.productData['name'] ?? '',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF667EEA).withOpacity(0.1),
                                    Color(0xFF764BA2).withOpacity(0.1)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Color(0xFF667EEA).withOpacity(0.3)),
                              ),
                              child: Text(
                                widget.productData['category'] ?? '',
                                style: TextStyle(
                                  color: Color(0xFF667EEA),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [Colors.green, Colors.green.shade700],
                            ).createShader(bounds),
                            child: Text(
                              '\$${widget.productData['price']}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (widget.productData['originalPrice'] != null)
                            Text(
                              '\$${widget.productData['originalPrice']}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade500,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  // Rating and Reviews
                  if (widget.productData['rating'] != null)
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < widget.productData['rating'].floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 24,
                            );
                          }),
                          SizedBox(width: 8),
                          Text(
                            '${widget.productData['rating']} (${widget.productData['reviewCount'] ?? 0} reviews)',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  Divider(height: 32),

                  // Description with enhanced styling
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      widget.productData['description'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        height: 1.6,
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Enhanced Features
                  if (widget.productData['features'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Features',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 12),
                        ...List<String>.from(widget.productData['features'])
                            .map((feature) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),

                  SizedBox(height: 24),

                  // Enhanced Duration
                  if (widget.productData['duration'] != null)
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade50,
                            Colors.orange.shade100
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.timer,
                                color: Colors.white, size: 24),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estimated Duration',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                widget.productData['duration'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 24),

                  // Enhanced Quantity Selector
                  Row(
                    children: [
                      Text(
                        'Quantity:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove,
                                  color: Colors.grey.shade600),
                              onPressed: quantity > 1
                                  ? () => setState(() => quantity--)
                                  : null,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                quantity.toString(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon:
                                  Icon(Icons.add, color: Colors.grey.shade600),
                              onPressed: () => setState(() => quantity++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 15,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addToCart,
                icon: Icon(Icons.add_shopping_cart),
                label: Text('Add to Cart'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF667EEA), width: 2),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.orange.shade700],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: _proceedToCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Buy Now',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}