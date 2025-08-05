// Fixed user_dashboard.dart with improved error handling and permissions

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'floating_chat_widget.dart'; // Import the chat widget

class EnhancedUserDashboard extends StatefulWidget {
  @override
  _EnhancedUserDashboardState createState() => _EnhancedUserDashboardState();
}

class _EnhancedUserDashboardState extends State<EnhancedUserDashboard> 
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // User stats
  int totalOrders = 0;
  int activeOrders = 0;
  int completedOrders = 0;
  double totalSpent = 0;
  int wishlistItems = 0;
  int supportTickets = 0;
  double totalSavings = 0;
  String membershipLevel = 'Bronze';
  
  // Chart data
  List<FlSpot> spendingData = [];
  
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _animationController.forward();
    _loadUserStats();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 768;

  Future<void> _loadUserStats() async {
    if (_auth.currentUser == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User not authenticated';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Create user document if it doesn't exist
      await _ensureUserDocumentExists();
      
      // Load data with error handling for each section
      await Future.wait([
        _loadOrdersData().catchError((e) {
          print('Error loading orders: $e');
          return null;
        }),
        _loadWishlistData().catchError((e) {
          print('Error loading wishlist: $e');
          return null;
        }),
        _loadSupportData().catchError((e) {
          print('Error loading support: $e');
          return null;
        }),
      ]);
      
      _generateSpendingChart();
      
    } catch (e) {
      print('Error loading user stats: $e');
      setState(() {
        _errorMessage = 'Failed to load dashboard data';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _ensureUserDocumentExists() async {
    final userId = _auth.currentUser!.uid;
    final userDoc = await _firestore.collection('users').doc(userId).get();
    
    if (!userDoc.exists) {
      // Create user document with basic info
      await _firestore.collection('users').doc(userId).set({
        'email': _auth.currentUser!.email,
        'displayName': _auth.currentUser!.displayName,
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
        'membershipLevel': 'Bronze',
      });
    }
  }

  Future<void> _loadOrdersData() async {
    try {
      // First, check if user has any orders
      final ordersQuery = _firestore
          .collection('orders')
          .where('userId', isEqualTo: _auth.currentUser!.uid);
      
      // Try to get without ordering first to check if field exists
      QuerySnapshot ordersSnapshot;
      try {
        ordersSnapshot = await ordersQuery
            .orderBy('createdAt', descending: true)
            .limit(100)
            .get(GetOptions(source: Source.serverAndCache))
            .timeout(Duration(seconds: 10));
      } catch (e) {
        print('OrderBy failed, trying without ordering: $e');
        // If orderBy fails, try without it
        ordersSnapshot = await ordersQuery
            .limit(100)
            .get(GetOptions(source: Source.serverAndCache))
            .timeout(Duration(seconds: 10));
      }
      
      int active = 0;
      int completed = 0;
      double spent = 0;
      double savings = 0;
      
      for (var doc in ordersSnapshot.docs) {
        try {
          final data = doc.data();
          final mapData = data as Map<String, dynamic>?;
          final status = (mapData?['orderStatus'] ?? 'processing').toString().toLowerCase();
          final amount = double.tryParse(mapData?['amount']?.toString() ?? '0') ?? 0;
          final originalAmount = double.tryParse(mapData?['originalAmount']?.toString() ?? amount.toString()) ?? amount;
          
          spent += amount;
          savings += (originalAmount - amount);
          
          if (status == 'active' || status == 'processing') {
            active++;
          } else if (status == 'completed') {
            completed++;
          }
        } catch (e) {
          print('Error processing order document: $e');
        }
      }
      
      // Determine membership level based on spending
      String level = 'Bronze';
      if (spent >= 10000) {
        level = 'Platinum';
      } else if (spent >= 5000) {
        level = 'Gold';
      } else if (spent >= 1000) {
        level = 'Silver';
      }
      
      if (mounted) {
        setState(() {
          totalOrders = ordersSnapshot.docs.length;
          activeOrders = active;
          completedOrders = completed;
          totalSpent = spent;
          totalSavings = savings;
          membershipLevel = level;
        });
      }
    } catch (e) {
      print('Error in _loadOrdersData: $e');
      if (mounted) {
        setState(() {
          totalOrders = 0;
          activeOrders = 0;
          completedOrders = 0;
          totalSpent = 0;
          totalSavings = 0;
        });
      }
    }
  }

  Future<void> _loadWishlistData() async {
    try {
      final wishlistSnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('wishlist')
          .limit(50)
          .get(GetOptions(source: Source.serverAndCache))
          .timeout(Duration(seconds: 10));
      
      if (mounted) {
        setState(() {
          wishlistItems = wishlistSnapshot.docs.length;
        });
      }
    } catch (e) {
      print('Error loading wishlist: $e');
      if (mounted) {
        setState(() {
          wishlistItems = 0;
        });
      }
    }
  }

  Future<void> _loadSupportData() async {
    try {
      final supportSnapshot = await _firestore
          .collection('support_chats')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .limit(50)
          .get(GetOptions(source: Source.serverAndCache))
          .timeout(Duration(seconds: 10));
      
      if (mounted) {
        setState(() {
          supportTickets = supportSnapshot.docs.length;
        });
      }
    } catch (e) {
      print('Error loading support tickets: $e');
      if (mounted) {
        setState(() {
          supportTickets = 0;
        });
      }
    }
  }
  
  void _generateSpendingChart() {
    // Generate spending chart data (last 6 months)
    spendingData = List.generate(6, (index) {
      final baseValue = totalSpent > 0 ? totalSpent : 100.0;
      return FlSpot(
        index.toDouble(),
        (baseValue * (0.1 + (index * 0.15))).roundToDouble(),
      );
    });
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getMembershipColor() {
    switch (membershipLevel) {
      case 'Platinum':
        return Colors.grey.shade700;
      case 'Gold':
        return Colors.amber;
      case 'Silver':
        return Colors.grey;
      default:
        return Colors.brown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    
    if (user == null) {
      // Redirect to login if not authenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/unified-login');
      });
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    final bool showDrawer = isMobile(context);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: showDrawer,
        title: Row(
          children: [
            if (!showDrawer) ...[
              Icon(FontAwesomeIcons.code, color: Colors.blue.shade700, size: 24),
              SizedBox(width: 10),
            ],
            Text(
              'My Dashboard',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.bold,
                fontSize: isMobile(context) ? 18 : 22,
              ),
            ),
          ],
        ),
        actions: [
          // Refresh Button
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey.shade700),
            onPressed: _loadUserStats,
            tooltip: 'Refresh Data',
          ),
          // Notifications
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade700),
                onPressed: () => setState(() => _selectedIndex = 6),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          // Shopping Cart
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: Colors.grey.shade700),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
          // Shop Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/products'),
              icon: Icon(Icons.shopping_bag, size: 18),
              label: Text('Shop'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: BorderSide(color: Colors.orange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          // User Profile Menu
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: PopupMenuButton(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: _getMembershipColor(),
                      child: Text(
                        user.displayName?.substring(0, 1).toUpperCase() ?? 
                        user.email?.substring(0, 1).toUpperCase() ?? 'U',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 8),
                    if (!isMobile(context))
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.displayName ?? user.email?.split('@')[0] ?? 'User',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            membershipLevel,
                            style: TextStyle(color: _getMembershipColor(), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                  ],
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
                      Icon(Icons.receipt_long, size: 20),
                      SizedBox(width: 12),
                      Text('My Orders'),
                    ],
                  ),
                  value: 'orders',
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.settings, size: 20),
                      SizedBox(width: 12),
                      Text('Settings'),
                    ],
                  ),
                  value: 'settings',
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.help, size: 20),
                      SizedBox(width: 12),
                      Text('Help & Support'),
                    ],
                  ),
                  value: 'support',
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
                    setState(() => _selectedIndex = 1);
                    break;
                  case 'settings':
                    setState(() => _selectedIndex = 7);
                    break;
                  case 'support':
                    setState(() => _selectedIndex = 4);
                    break;
                  case 'logout':
                    _signOut();
                    break;
                }
              },
            ),
          ),
        ],
      ),
      drawer: showDrawer ? _buildMobileDrawer() : null,
      body: Stack( // Use Stack to overlay chat widget
        children: [
          Row(
            children: [
              if (!showDrawer) _buildSideNavigation(),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Loading dashboard...'),
                          ],
                        ),
                      )
                    : _errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 60, color: Colors.red),
                                SizedBox(height: 16),
                                Text(
                                  'Error loading dashboard',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _loadUserStats,
                                  icon: Icon(Icons.refresh),
                                  label: Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildContent(),
                          ),
              ),
            ],
          ),
          // Add Floating Chat Widget
          FloatingChatWidget(),
        ],
      ),
    );
  }
  
  Widget _buildMobileDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _getMembershipColor(),
                  child: Text(
                    _auth.currentUser?.displayName?.substring(0, 1).toUpperCase() ?? 
                    _auth.currentUser?.email?.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  _auth.currentUser?.displayName ?? 'User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _auth.currentUser?.email ?? '',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getMembershipColor(),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        membershipLevel,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ..._buildNavigationItems(),
        ],
      ),
    );
  }

  Widget _buildSideNavigation() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: _getMembershipColor(),
                  child: Text(
                    _auth.currentUser?.displayName?.substring(0, 1).toUpperCase() ?? 
                    _auth.currentUser?.email?.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  _auth.currentUser?.displayName ?? 'User',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  _auth.currentUser?.email ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getMembershipColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: _getMembershipColor(),
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '$membershipLevel Member',
                        style: TextStyle(
                          color: _getMembershipColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 10),
              children: _buildNavigationItems(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavigationItems() {
    final items = [
      {'icon': Icons.dashboard, 'title': 'Overview', 'index': 0, 'badge': null},
      {'icon': Icons.shopping_bag, 'title': 'My Orders', 'index': 1, 'badge': activeOrders > 0 ? activeOrders : null},
      {'icon': Icons.person, 'title': 'Profile', 'index': 2, 'badge': null},
      {'icon': Icons.favorite, 'title': 'Wishlist', 'index': 3, 'badge': wishlistItems > 0 ? wishlistItems : null},
      {'icon': Icons.support_agent, 'title': 'Support', 'index': 4, 'badge': supportTickets > 0 ? supportTickets : null},
      {'icon': Icons.account_balance_wallet, 'title': 'Wallet', 'index': 5, 'badge': null},
      {'icon': Icons.notifications, 'title': 'Notifications', 'index': 6, 'badge': null},
      {'icon': Icons.settings, 'title': 'Settings', 'index': 7, 'badge': null},
    ];

    return items.map((item) {
      final isSelected = _selectedIndex == item['index'];
      final badge = item['badge'] as int?;
      
      return ListTile(
        leading: Stack(
          children: [
            Icon(
              item['icon'] as IconData,
              color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
            ),
            if (badge != null)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    badge > 99 ? '99+' : badge.toString(),
                    style: TextStyle(
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
        title: Text(
          item['title'] as String,
          style: TextStyle(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.blue.shade50,
        onTap: () {
          setState(() {
            _selectedIndex = item['index'] as int;
          });
          if (isMobile(context)) {
            Navigator.pop(context);
          }
        },
      );
    }).toList();
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverviewContent();
      case 1:
        return _buildOrdersContent();
      case 2:
        return _buildProfileContent();
      case 3:
        return _buildWishlistContent();
      case 4:
        return _buildSupportContent();
      case 5:
        return _buildWalletContent();
      case 6:
        return _buildNotificationsContent();
      case 7:
        return _buildSettingsContent();
      default:
        return _buildOverviewContent();
    }
  }

  // Add the orders content method
  Widget _buildOrdersContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Orders',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 20),
          
          // Orders List
          FutureBuilder<QuerySnapshot>(
            future: _firestore
                .collection('orders')
                .where('userId', isEqualTo: _auth.currentUser?.uid)
                .limit(50)
                .get(GetOptions(source: Source.serverAndCache)),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Container(
                  padding: EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
                        SizedBox(height: 16),
                        Text('Error loading orders', style: TextStyle(color: Colors.red.shade600)),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              
              final orders = snapshot.data?.docs ?? [];
              
              // Sort orders by createdAt manually if orderBy failed
              try {
                orders.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aTime = aData['createdAt'] as Timestamp?;
                  final bTime = bData['createdAt'] as Timestamp?;
                  
                  if (aTime == null || bTime == null) return 0;
                  return bTime.compareTo(aTime);
                });
              } catch (e) {
                print('Error sorting orders: $e');
              }
              
              if (orders.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 60,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No orders yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/products'),
                          child: Text('Start Shopping'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final data = order.data() as Map<String, dynamic>;
                  return _buildOrderCard(order.id, data);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(String orderId, Map<String, dynamic> data) {
    final orderDateTs = data['createdAt'] as Timestamp?;
    final orderDate = orderDateTs?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('MMM dd, yyyy').format(orderDate);
    final status = data['orderStatus'] ?? 'processing';
    
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'processing':
        statusColor = Colors.orange;
        break;
      case 'active':
        statusColor = Colors.blue;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data['orderId'] ?? 'Order #$orderId',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            data['service'] ?? 'Service',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                '\$${data['amount']?.toString() ?? '0'}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/order-tracking',
                  arguments: orderId,
                );
              },
              child: Text('Track Order'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOverviewContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile(context) ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section with Membership Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${_auth.currentUser?.displayName ?? 'User'}!',
                    style: TextStyle(
                      fontSize: isMobile(context) ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: _getMembershipColor(), size: 20),
                      SizedBox(width: 4),
                      Text(
                        '$membershipLevel Member',
                        style: TextStyle(
                          fontSize: isMobile(context) ? 14 : 16,
                          color: _getMembershipColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (totalSavings > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.savings, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Saved \$${totalSavings.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 30),
          
          // Enhanced Stats Cards
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile(context) ? 2 : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isMobile(context) ? 1.2 : 1.3,
            children: [
              _buildEnhancedStatCard(
                icon: Icons.shopping_cart,
                title: 'Total Orders',
                value: totalOrders.toString(),
                color: Colors.blue,
                subtitle: '${activeOrders} active',
                onTap: () => setState(() => _selectedIndex = 1),
              ),
              _buildEnhancedStatCard(
                icon: Icons.attach_money,
                title: 'Total Spent',
                value: '\$${totalSpent.toStringAsFixed(0)}',
                color: Colors.green,
                subtitle: 'this year',
                onTap: () => setState(() => _selectedIndex = 5),
              ),
              _buildEnhancedStatCard(
                icon: Icons.favorite,
                title: 'Wishlist Items',
                value: wishlistItems.toString(),
                color: Colors.red,
                subtitle: 'saved items',
                onTap: () => setState(() => _selectedIndex = 3),
              ),
              _buildEnhancedStatCard(
                icon: Icons.savings,
                title: 'Total Savings',
                value: '\$${totalSavings.toStringAsFixed(0)}',
                color: Colors.orange,
                subtitle: 'from deals',
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 30),
          
          // Quick Actions
          _buildQuickActions(),
          
          SizedBox(height: 30),
          
          // Recent Orders
          _buildRecentOrders(),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: EdgeInsets.all(isMobile(context) ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: isMobile(context) ? 20 : 24),
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: isMobile(context) ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile(context) ? 12 : 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.shopping_bag,
        'title': 'Shop Now',
        'subtitle': 'Browse products',
        'color': Colors.orange,
        'onTap': () => Navigator.pushNamed(context, '/products'),
      },
      {
        'icon': Icons.design_services,
        'title': 'Services',
        'subtitle': 'View our services',
        'color': Colors.blue,
        'onTap': () => Navigator.pushNamed(context, '/services'),
      },
      {
        'icon': Icons.favorite,
        'title': 'Wishlist',
        'subtitle': '$wishlistItems items',
        'color': Colors.red,
        'onTap': () => setState(() => _selectedIndex = 3),
      },
      {
        'icon': Icons.support_agent,
        'title': 'Support',
        'subtitle': 'Get help',
        'color': Colors.green,
        'onTap': () => setState(() => _selectedIndex = 4),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile(context) ? 2 : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isMobile(context) ? 1.5 : 1.8,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return InkWell(
              onTap: action['onTap'] as VoidCallback,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 32,
                    ),
                    SizedBox(height: 12),
                    Text(
                      action['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      action['subtitle'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentOrders() {
    return FutureBuilder<QuerySnapshot>(
      future: _firestore
          .collection('orders')
          .where('userId', isEqualTo: _auth.currentUser?.uid)
          .limit(5)
          .get(GetOptions(source: Source.serverAndCache)),
      builder: (context, snapshot) {
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        final orders = snapshot.data?.docs ?? [];
        
        // Sort orders manually if needed
        try {
          orders.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = aData['createdAt'] as Timestamp?;
            final bTime = bData['createdAt'] as Timestamp?;
            
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });
        } catch (e) {
          print('Error sorting recent orders: $e');
        }
        
        if (orders.isEmpty) {
          return Container(
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 60,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/products'),
                    child: Text('Start Shopping'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Orders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                      child: Text('View All'),
                    ),
                  ],
                ),
              ),
              ...orders.take(3).map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final orderDateTs = data['createdAt'] as Timestamp?;
                final orderDate = orderDateTs?.toDate() ?? DateTime.now();
                final formattedDate = DateFormat('MMM dd, yyyy').format(orderDate);
                
                return _buildOrderItem(data, formattedDate);
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> data, String date) {
    final status = data['orderStatus'] ?? 'processing';
    Color statusColor;
    
    switch (status.toLowerCase()) {
      case 'active':
      case 'processing':
        statusColor = Colors.orange;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.shopping_bag, color: statusColor, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['orderId'] ?? 'Order',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  data['service'] ?? 'Service',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                '\$${data['amount']?.toString() ?? '0'}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Placeholder methods for other sections
  Widget _buildProfileContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 60, color: Colors.grey.shade400),
          SizedBox(height: 20),
          Text(
            'Profile Settings',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            child: Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline, size: 60, color: Colors.grey.shade400),
          SizedBox(height: 20),
          Text(
            'Wishlist - Coming Soon',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/products'),
            child: Text('Browse Products'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.support_agent, size: 60, color: Colors.grey.shade400),
          SizedBox(height: 20),
          Text(
            'Need Help?',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/contact'),
            icon: Icon(Icons.contact_support),
            label: Text('Contact Support'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Wallet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 20),
          
          // Wallet Balance Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallet Balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '\$0.00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.star, color: _getMembershipColor(), size: 20),
                    SizedBox(width: 8),
                    Text(
                      '$membershipLevel Member',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _buildWalletAction(
                  'Add Money',
                  Icons.add,
                  Colors.green,
                  () {},
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildWalletAction(
                  'Transaction History',
                  Icons.history,
                  Colors.blue,
                  () {},
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Recent Transactions
          Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, 
                      size: 60, color: Colors.grey.shade300),
                  SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
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

  Widget _buildWalletAction(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsContent() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications, color: Colors.blue.shade700),
                  SizedBox(width: 12),
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.done_all, size: 18),
                label: Text('Mark all read'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildNotificationItem(
                'Order Update',
                'Your order #ORD123 has been shipped',
                Icons.local_shipping,
                Colors.blue,
                '2 hours ago',
                true,
              ),
              _buildNotificationItem(
                'New Deal Available',
                '50% off on App Development services',
                Icons.local_offer,
                Colors.orange,
                '1 day ago',
                true,
              ),
              _buildNotificationItem(
                'Payment Confirmation',
                'Payment of \$500 has been processed',
                Icons.payment,
                Colors.green,
                '3 days ago',
                false,
              ),
              _buildNotificationItem(
                'Welcome!',
                'Welcome to AppTech Vibe! Explore our services',
                Icons.celebration,
                Colors.purple,
                '1 week ago',
                false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(
    String title,
    String description,
    IconData icon,
    Color color,
    String time,
    bool isUnread,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread ? Colors.blue.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 20),
        
        _buildSettingsSection('Account', [
          _buildSettingsItem(
            'Edit Profile',
            'Update your personal information',
            Icons.person,
            () => Navigator.pushNamed(context, '/profile'),
          ),
          _buildSettingsItem(
            'Change Password',
            'Update your password',
            Icons.lock,
            () => Navigator.pushNamed(context, '/profile'),
          ),
          _buildSettingsItem(
            'Privacy Settings',
            'Control your privacy preferences',
            Icons.privacy_tip,
            () {},
          ),
        ]),
        
        SizedBox(height: 20),
        
        _buildSettingsSection('Preferences', [
          _buildSettingsItem(
            'Notifications',
            'Manage notification preferences',
            Icons.notifications,
            () {},
          ),
          _buildSettingsItem(
            'Language',
            'English',
            Icons.language,
            () {},
          ),
          _buildSettingsItem(
            'Theme',
            'Light mode',
            Icons.palette,
            () {},
          ),
        ]),
        
        SizedBox(height: 20),
        
        _buildSettingsSection('Support', [
          _buildSettingsItem(
            'Help Center',
            'Get help and support',
            Icons.help,
            () => Navigator.pushNamed(context, '/contact'),
          ),
          _buildSettingsItem(
            'Contact Us',
            'Reach out to our team',
            Icons.contact_support,
            () => Navigator.pushNamed(context, '/contact'),
          ),
          _buildSettingsItem(
            'Terms & Conditions',
            'Read our terms of service',
            Icons.description,
            () {},
          ),
        ]),
        
        SizedBox(height: 20),
        
        _buildSettingsSection('Account Actions', [
          _buildSettingsItem(
            'Sign Out',
            'Sign out of your account',
            Icons.logout,
            _signOut,
            isDestructive: true,
          ),
        ]),
      ],
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.grey.shade600,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : Colors.grey.shade800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }
}