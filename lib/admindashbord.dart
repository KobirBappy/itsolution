import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:itapp/common_appbar.dart';
import 'package:itapp/customer_management.dart';
import 'package:itapp/ordermanagementadmin.dart';
import 'package:itapp/servicemanad.dart';

class EnhancedAdminDashboard extends StatefulWidget {
  @override
  _EnhancedAdminDashboardState createState() => _EnhancedAdminDashboardState();
}

class _EnhancedAdminDashboardState extends State<EnhancedAdminDashboard> 
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Dashboard stats
  int totalOrders = 0;
  int activeProjects = 0;
  int completedProjects = 0;
  double totalRevenue = 0;
  int totalUsers = 0;
  int unreadMessages = 0;
  int pendingOrders = 0;
  double monthlyGrowth = 0;
  
  // Charts data
  List<FlSpot> revenueData = [];
  List<PieChartSectionData> orderStatusData = [];
  
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
    _loadDashboardData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 768;
  bool isTablet(BuildContext context) => MediaQuery.of(context).size.width < 1200 && MediaQuery.of(context).size.width >= 768;

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if user is admin first
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Verify admin status with timeout
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get()
          .timeout(Duration(seconds: 10));
          
      if (!userDoc.exists || userDoc.data()?['role'] != 'admin') {
        throw Exception('Insufficient permissions');
      }

      // Load data with error handling for each section
      await Future.wait([
        _loadOrdersData().catchError((e) {
          print('Error loading orders: $e');
          return null;
        }),
        _loadUsersData().catchError((e) {
          print('Error loading users: $e');
          return null;
        }),
        _loadChatData().catchError((e) {
          print('Error loading chats: $e');
          return null;
        }),
      ]);
      
      // Generate chart data
      _generateChartData();
      
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _errorMessage = 'Failed to load dashboard data: ${e.toString()}';
        // Set default values
        totalOrders = 0;
        activeProjects = 0;
        completedProjects = 0;
        pendingOrders = 0;
        totalRevenue = 0;
        totalUsers = 0;
        unreadMessages = 0;
        monthlyGrowth = 0;
      });
      _generateChartData(); // Generate empty chart data
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadOrdersData() async {
    try {
      // Use get() instead of snapshots() to avoid real-time listeners
      final ordersSnapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .limit(100) // Reduced limit
          .get(GetOptions(source: Source.serverAndCache)) // Use cache if available
          .timeout(Duration(seconds: 10));
      
      int active = 0, completed = 0, pending = 0;
      double revenue = 0;
      
      for (var doc in ordersSnapshot.docs) {
        try {
          final data = doc.data();
          final status = (data['orderStatus'] ?? '').toString().toLowerCase();
          final amount = double.tryParse(data['amount']?.toString() ?? '0') ?? 0;
          
          revenue += amount;
          
          switch (status) {
            case 'active':
              active++;
              break;
            case 'completed':
              completed++;
              break;
            case 'processing':
            case 'pending':
              pending++;
              break;
          }
        } catch (e) {
          print('Error processing order document: $e');
        }
      }
      
      // Calculate monthly growth (mock calculation)
      final lastMonthRevenue = revenue * 0.8; // Mock previous month
      final growth = lastMonthRevenue > 0 
          ? ((revenue - lastMonthRevenue) / lastMonthRevenue) * 100 
          : 0;
      
      if (mounted) {
        setState(() {
          totalOrders = ordersSnapshot.docs.length;
          activeProjects = active;
          completedProjects = completed;
          pendingOrders = pending;
          totalRevenue = revenue;
          monthlyGrowth = growth.toDouble();
        });
      }
    } catch (e) {
      print('Error in _loadOrdersData: $e');
      // Set defaults on error
      if (mounted) {
        setState(() {
          totalOrders = 0;
          activeProjects = 0;
          completedProjects = 0;
          pendingOrders = 0;
          totalRevenue = 0;
          monthlyGrowth = 0;
        });
      }
    }
  }

  Future<void> _loadUsersData() async {
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'customer')
          .limit(100) // Limit to prevent large queries
          .get(GetOptions(source: Source.serverAndCache))
          .timeout(Duration(seconds: 10));
      
      if (mounted) {
        setState(() {
          totalUsers = usersSnapshot.docs.length;
        });
      }
    } catch (e) {
      print('Error in _loadUsersData: $e');
      if (mounted) {
        setState(() {
          totalUsers = 0;
        });
      }
    }
  }

  Future<void> _loadChatData() async {
    try {
      final chatsSnapshot = await _firestore
          .collection('support_chats')
          .where('hasUnreadMessages', isEqualTo: true)
          .limit(50) // Limit to prevent large queries
          .get(GetOptions(source: Source.serverAndCache))
          .timeout(Duration(seconds: 10));
      
      if (mounted) {
        setState(() {
          unreadMessages = chatsSnapshot.docs.length;
        });
      }
    } catch (e) {
      print('Error in _loadChatData: $e');
      if (mounted) {
        setState(() {
          unreadMessages = 0;
        });
      }
    }
  }
  
  void _generateChartData() {
    // Generate revenue chart data (last 6 months) with safe values
    revenueData = List.generate(6, (index) {
      final baseValue = totalRevenue > 0 ? totalRevenue : 1000.0; // Fallback value
      return FlSpot(
        index.toDouble(),
        (baseValue * (0.6 + (index * 0.1))).roundToDouble(),
      );
    });
    
    // Generate pie chart data for order status with safe values
    final totalOrdersForChart = totalOrders > 0 ? totalOrders : 1; // Prevent division by zero
    
    orderStatusData = [
      PieChartSectionData(
        color: Colors.blue,
        value: activeProjects > 0 ? activeProjects.toDouble() : 0.1,
        title: activeProjects > 0 ? '${activeProjects}\nActive' : 'No\nActive',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: pendingOrders > 0 ? pendingOrders.toDouble() : 0.1,
        title: pendingOrders > 0 ? '${pendingOrders}\nPending' : 'No\nPending',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: completedProjects > 0 ? completedProjects.toDouble() : 0.1,
        title: completedProjects > 0 ? '${completedProjects}\nCompleted' : 'No\nCompleted',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool showDrawer = isMobile(context);
    
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 2,
      //   automaticallyImplyLeading: showDrawer,
      //   title: Row(
      //     children: [
      //       if (!showDrawer) ...[
      //         Icon(FontAwesomeIcons.code, color: Colors.blue.shade700, size: 24),
      //         SizedBox(width: 10),
      //       ],
      //       Text(
      //         'Admin Dashboard',
      //         style: TextStyle(
      //           color: Colors.grey.shade800,
      //           fontWeight: FontWeight.bold,
      //           fontSize: isMobile(context) ? 18 : 22,
      //         ),
      //       ),
      //     ],
      //   ),
      //   actions: [
      //     // Refresh Button
      //     IconButton(
      //       icon: Icon(Icons.refresh, color: Colors.grey.shade700),
      //       onPressed: _loadDashboardData,
      //       tooltip: 'Refresh Data',
      //     ),
      //     // Notifications
      //     Stack(
      //       children: [
      //         IconButton(
      //           icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade700),
      //           onPressed: () => _showNotifications(),
      //         ),
      //         if (unreadMessages > 0)
      //           Positioned(
      //             right: 8,
      //             top: 8,
      //             child: Container(
      //               padding: EdgeInsets.all(4),
      //               decoration: BoxDecoration(
      //                 color: Colors.red,
      //                 shape: BoxShape.circle,
      //               ),
      //               child: Text(
      //                 unreadMessages > 99 ? '99+' : unreadMessages.toString(),
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 10,
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //             ),
      //           ),
      //       ],
      //     ),
      //     // Messages
      //     Stack(
      //       children: [
      //         IconButton(
      //           icon: Icon(Icons.chat_outlined, color: Colors.grey.shade700),
      //           onPressed: () => _showSupportChats(),
      //         ),
      //         if (unreadMessages > 0)
      //           Positioned(
      //             right: 8,
      //             top: 8,
      //             child: Container(
      //               width: 8,
      //               height: 8,
      //               decoration: BoxDecoration(
      //                 color: Colors.red,
      //                 shape: BoxShape.circle,
      //               ),
      //             ),
      //           ),
      //       ],
      //     ),
      //     // User Profile
      //     Padding(
      //       padding: EdgeInsets.symmetric(horizontal: 8),
      //       child: Row(
      //         children: [
      //           Container(
      //             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      //             decoration: BoxDecoration(
      //               color: Colors.blue.shade50,
      //               borderRadius: BorderRadius.circular(20),
      //             ),
      //             child: Row(
      //               children: [
      //                 CircleAvatar(
      //                   radius: 15,
      //                   backgroundColor: Colors.blue.shade700,
      //                   child: Icon(Icons.person, color: Colors.white, size: 18),
      //                 ),
      //                 SizedBox(width: 8),
      //                 if (!isMobile(context))
      //                   Text(
      //                     _auth.currentUser?.email?.split('@')[0] ?? 'Admin',
      //                     style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
      //                   ),
      //               ],
      //             ),
      //           ),
      //           PopupMenuButton(
      //             icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
      //             itemBuilder: (context) => [
      //               PopupMenuItem(
      //                 child: Row(
      //                   children: [
      //                     Icon(Icons.person, size: 20),
      //                     SizedBox(width: 12),
      //                     Text('Profile'),
      //                   ],
      //                 ),
      //                 value: 'profile',
      //               ),
      //               PopupMenuItem(
      //                 child: Row(
      //                   children: [
      //                     Icon(Icons.settings, size: 20),
      //                     SizedBox(width: 12),
      //                     Text('Settings'),
      //                   ],
      //                 ),
      //                 value: 'settings',
      //               ),
      //               PopupMenuItem(
      //                 child: Row(
      //                   children: [
      //                     Icon(Icons.logout, size: 20, color: Colors.red),
      //                     SizedBox(width: 12),
      //                     Text('Logout', style: TextStyle(color: Colors.red)),
      //                   ],
      //                 ),
      //                 value: 'logout',
      //               ),
      //             ],
      //             onSelected: (value) {
      //               if (value == 'logout') {
      //                 _signOut();
      //               }
      //             },
      //           ),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),

       appBar: CommonAppBar(
        type: AppBarType.admin,
        additionalData: {
          // Pass your refresh function
          'onRefresh': _loadDashboardData,
          
          // Pass notification count for badge
          'notificationCount': unreadMessages,
          
          // Pass unread messages count
          'unreadMessages': unreadMessages,
          
          // Pass callback functions
          'onNotificationPressed': _showNotifications,
          'onMessagesPressed': _showSupportChats,
        },
      ),
      drawer: showDrawer ? _buildMobileDrawer() : null,
      body: Row(
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
                        Text('Loading dashboard data...'),
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
                              'Error loading data',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadDashboardData,
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
                Icon(FontAwesomeIcons.code, color: Colors.white, size: 40),
                SizedBox(height: 10),
                Text(
                  'AppTech Vibe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
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
            child: Row(
              children: [
                Icon(FontAwesomeIcons.code, color: Colors.blue.shade700, size: 30),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AppTech Vibe',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
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
      {'icon': Icons.dashboard, 'title': 'Dashboard', 'index': 0, 'badge': null},
      {'icon': Icons.shopping_cart, 'title': 'Orders', 'index': 1, 'badge': pendingOrders > 0 ? pendingOrders : null},
      {'icon': Icons.design_services, 'title': 'Services', 'index': 2, 'badge': null},
      {'icon': Icons.people, 'title': 'Customers', 'index': 3, 'badge': null},
      {'icon': Icons.chat, 'title': 'Support Chat', 'index': 4, 'badge': unreadMessages > 0 ? unreadMessages : null},
      {'icon': Icons.payment, 'title': 'Payments', 'index': 5, 'badge': null},
      {'icon': Icons.analytics, 'title': 'Analytics', 'index': 6, 'badge': null},
      {'icon': Icons.inventory, 'title': 'Products', 'index': 7, 'badge': null},
      {'icon': Icons.notifications, 'title': 'Notifications', 'index': 8, 'badge': null},
      {'icon': Icons.settings, 'title': 'Settings', 'index': 9, 'badge': null},
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
        return _buildDashboardContent();
      case 1:
        return _buildOrdersContent();
      case 2:
        return _buildServicesContent();
      case 3:
        return _buildCustomersContent();
      case 4:
        return _buildSupportChatContent();
      case 5:
        return _buildPaymentsContent();
      case 6:
        return _buildAnalyticsContent();
      case 7:
        return _buildProductsContent();
      case 8:
        return _buildNotificationsContent();
      case 9:
        return _buildSettingsContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile(context) ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, Admin!',
                    style: TextStyle(
                      fontSize: isMobile(context) ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Here\'s what\'s happening with your business today.',
                    style: TextStyle(
                      fontSize: isMobile(context) ? 14 : 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              if (!isMobile(context))
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: monthlyGrowth >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        monthlyGrowth >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: monthlyGrowth >= 0 ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${monthlyGrowth.toStringAsFixed(1)}% this month',
                        style: TextStyle(
                          color: monthlyGrowth >= 0 ? Colors.green.shade700 : Colors.red.shade700,
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
                change: '+12%',
                subtitle: 'vs last month',
              ),
              _buildEnhancedStatCard(
                icon: Icons.work,
                title: 'Active Projects',
                value: activeProjects.toString(),
                color: Colors.orange,
                change: '+5%',
                subtitle: '${pendingOrders} pending',
              ),
              _buildEnhancedStatCard(
                icon: Icons.people,
                title: 'Total Users',
                value: totalUsers.toString(),
                color: Colors.green,
                change: '+18%',
                subtitle: 'registered users',
              ),
              _buildEnhancedStatCard(
                icon: Icons.attach_money,
                title: 'Revenue',
                value: '\$${totalRevenue.toStringAsFixed(0)}',
                color: Colors.purple,
                change: '+25%',
                subtitle: 'this month',
              ),
            ],
          ),
          SizedBox(height: 30),
          
          // Charts Section
          if (!isMobile(context))
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildRevenueChart(),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: _buildProjectStatusChart(),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildRevenueChart(),
                SizedBox(height: 20),
                _buildProjectStatusChart(),
              ],
            ),
          
          SizedBox(height: 30),
          
          // Quick Actions
          _buildQuickActions(),
          
          SizedBox(height: 30),
          
          // Recent Activity - Using FutureBuilder instead of StreamBuilder
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String change,
    required String subtitle,
  }) {
    return Container(
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
          Row(
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.add_business,
        'title': 'New Order',
        'subtitle': 'Create order',
        'color': Colors.blue,
        'onTap': () => setState(() => _selectedIndex = 1),
      },
      {
        'icon': Icons.person_add,
        'title': 'Add Customer',
        'subtitle': 'Register user',
        'color': Colors.green,
        'onTap': () => setState(() => _selectedIndex = 3),
      },
      {
        'icon': Icons.add_shopping_cart,
        'title': 'New Product',
        'subtitle': 'Add product',
        'color': Colors.orange,
        'onTap': () => setState(() => _selectedIndex = 7),
      },
      {
        'icon': Icons.analytics,
        'title': 'View Analytics',
        'subtitle': 'Reports',
        'color': Colors.purple,
        'onTap': () => setState(() => _selectedIndex = 6),
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

  Widget _buildRecentActivity() {
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
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 8; // Notifications
                    });
                  },
                  child: Text('View All'),
                ),
              ],
            ),
          ),
          FutureBuilder<QuerySnapshot>(
            future: _firestore
                .collection('orders')
                .orderBy('createdAt', descending: true)
                .limit(5)
                .get(GetOptions(source: Source.serverAndCache)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              if (snapshot.hasError) {
                return Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, size: 40, color: Colors.red.shade300),
                        SizedBox(height: 8),
                        Text('Error loading activity', style: TextStyle(color: Colors.red.shade600)),
                      ],
                    ),
                  ),
                );
              }
              
              final orders = snapshot.data?.docs ?? [];
              
              if (orders.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined, size: 40, color: Colors.grey.shade300),
                        SizedBox(height: 8),
                        Text('No recent activity', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                );
              }
              
              return Column(
                children: orders.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final orderDate = (data['createdAt'] as Timestamp?)?.toDate();
                  final timeAgo = orderDate != null ? _getTimeAgo(orderDate) : 'Unknown';
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: Icon(Icons.shopping_cart, color: Colors.blue.shade700, size: 20),
                    ),
                    title: Text(
                      'New order from ${data['customerName'] ?? 'Customer'}',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('Order ID: ${data['orderId'] ?? 'N/A'} • $timeAgo'),
                    trailing: Text(
                      '\$${data['amount']?.toString() ?? '0'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildRevenueChart() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revenue Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Last 6 months',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            height: 250,
            child: revenueData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.show_chart, size: 40, color: Colors.grey.shade300),
                        SizedBox(height: 8),
                        Text('No data available', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: totalRevenue > 0 ? totalRevenue / 5 : 1000,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '\$${(value / 1000).toStringAsFixed(0)}K',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const months = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                              final index = value.toInt();
                              if (index >= 0 && index < months.length) {
                                return Text(
                                  months[index],
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                );
                              }
                              return Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: revenueData,
                          isCurved: true,
                          color: Colors.blue.shade700,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.blue.shade700,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.shade700.withOpacity(0.1),
                          ),
                        ),
                      ],
                      minX: 0,
                      maxX: 5,
                      minY: 0,
                      maxY: revenueData.isNotEmpty 
                          ? revenueData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.2
                          : 1000,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectStatusChart() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Text(
            'Project Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 250,
            child: totalOrders == 0
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pie_chart_outline, size: 40, color: Colors.grey.shade300),
                        SizedBox(height: 8),
                        Text('No orders yet', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 50,
                          sections: orderStatusData,
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              totalOrders.toString(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            Text(
                              'Total Orders',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Active', Colors.blue, activeProjects),
              _buildLegendItem('Pending', Colors.orange, pendingOrders),
              _buildLegendItem('Completed', Colors.green, completedProjects),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  void _showNotifications() {
    setState(() {
      _selectedIndex = 8;
    });
  }

  void _showSupportChats() {
    setState(() {
      _selectedIndex = 4;
    });
  }

  // Placeholder methods for other sections
  Widget _buildOrdersContent() {
    return OrderManagementPage();
  }

  Widget _buildServicesContent() {
   return ServicesManagementPage();
  }

  Widget _buildCustomersContent() {
    return CustomerManagementPage();
  }

  Widget _buildSupportChatContent() {
    return _buildSupportChatInterface();
  }

  Widget _buildPaymentsContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment_outlined, size: 60, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text('Payments Management', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          SizedBox(height: 8),
          Text('Coming Soon', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    return _buildAnalyticsInterface();
  }

  Widget _buildProductsContent() {
   return ProductManagementPage();
  }

  Widget _buildNotificationsContent() {
    return _buildNotificationsInterface();
  }

  Widget _buildSettingsContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_outlined, size: 60, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text('Settings', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          SizedBox(height: 8),
          Text('Coming Soon', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildSupportChatInterface() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          color: Colors.white,
          child: Row(
            children: [
              Icon(Icons.chat, color: Colors.blue.shade700),
              SizedBox(width: 12),
              Text(
                'Support Chat Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<QuerySnapshot>(
            future: _firestore
                .collection('support_chats')
                .orderBy('lastMessageAt', descending: true)
                .limit(20)
                .get(GetOptions(source: Source.serverAndCache)),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
                      SizedBox(height: 16),
                      Text('Error loading chats', style: TextStyle(color: Colors.red.shade600)),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              
              final chats = snapshot.data?.docs ?? [];
              
              if (chats.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey.shade300),
                      SizedBox(height: 16),
                      Text('No chat messages yet', 
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final data = chat.data() as Map<String, dynamic>;
                  return _buildChatItem(chat.id, data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatItem(String chatId, Map<String, dynamic> data) {
    final lastMessageTime = data['lastMessageAt'] as Timestamp?;
    final timeStr = lastMessageTime != null 
        ? DateFormat('MMM dd, HH:mm').format(lastMessageTime.toDate())
        : '';
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: data['isGuestChat'] == true 
              ? Colors.orange.shade100 
              : Colors.blue.shade100,
          child: Icon(
            data['isGuestChat'] == true ? Icons.person_outline : Icons.person,
            color: data['isGuestChat'] == true 
                ? Colors.orange.shade700 
                : Colors.blue.shade700,
          ),
        ),
        title: Text(
          data['userName'] ?? 'Unknown User',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['lastMessage'] ?? 'No messages'),
            SizedBox(height: 4),
            Text(timeStr, style: TextStyle(fontSize: 12)),
          ],
        ),
        trailing: data['hasUnreadMessages'] == true
            ? Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () => _openChatDetail(chatId, data),
      ),
    );
  }

  void _openChatDetail(String chatId, Map<String, dynamic> chatData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          height: 600,
          child: _buildChatDetailDialog(chatId, chatData),
        ),
      ),
    );
  }

  Widget _buildChatDetailDialog(String chatId, Map<String, dynamic> chatData) {
    final messageController = TextEditingController();
    
    return Column(
      children: [
        // Chat Header
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue.shade700),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chatData['userName'] ?? 'Unknown User',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      chatData['userEmail'] ?? '',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        
        // Messages
        Expanded(
          child: FutureBuilder<QuerySnapshot>(
            future: _firestore
                .collection('support_chats')
                .doc(chatId)
                .collection('messages')
                .orderBy('timestamp')
                .get(GetOptions(source: Source.serverAndCache)),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading messages', style: TextStyle(color: Colors.red)),
                );
              }
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              
              final messages = snapshot.data?.docs ?? [];
              
              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index].data() as Map<String, dynamic>;
                  return _buildMessageBubble(message);
                },
              );
            },
          ),
        ),
        
        // Message Input
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your response...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 8),
              FloatingActionButton.small(
                onPressed: () async {
                  if (messageController.text.isNotEmpty) {
                    try {
                      await _firestore
                          .collection('support_chats')
                          .doc(chatId)
                          .collection('messages')
                          .add({
                        'message': messageController.text,
                        'senderId': _auth.currentUser!.uid,
                        'senderName': 'Admin',
                        'senderType': 'admin',
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      
                      await _firestore
                          .collection('support_chats')
                          .doc(chatId)
                          .update({
                        'lastMessage': messageController.text,
                        'lastMessageAt': FieldValue.serverTimestamp(),
                        'hasUnreadMessages': false,
                      });
                      
                      messageController.clear();
                      // Refresh the dialog
                      setState(() {});
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to send message'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['senderType'] == 'user';
    final timestamp = message['timestamp'] as Timestamp?;
    final time = timestamp != null 
        ? DateFormat('HH:mm').format(timestamp.toDate())
        : '';
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isUser ? 50 : 0,
          right: isUser ? 0 : 50,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue.shade700 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: isUser ? Radius.circular(4) : Radius.circular(18),
            bottomLeft: isUser ? Radius.circular(18) : Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['message'] ?? '',
              style: TextStyle(
                color: isUser ? Colors.white : Colors.grey.shade800,
                fontSize: 14,
              ),
            ),
            if (time.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: isUser ? Colors.white70 : Colors.grey.shade500,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsInterface() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 20),
          
          // Analytics Cards
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile(context) ? 2 : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildAnalyticsCard(
                'Page Views',
                '125,847',
                Icons.visibility,
                Colors.blue,
                '+12.5%',
              ),
              _buildAnalyticsCard(
                'Bounce Rate',
                '32.4%',
                Icons.exit_to_app,
                Colors.orange,
                '-2.1%',
              ),
              _buildAnalyticsCard(
                'Conversion Rate',
                '3.8%',
                Icons.trending_up,
                Colors.green,
                '+0.8%',
              ),
              _buildAnalyticsCard(
                'Avg. Session',
                '4m 32s',
                Icons.timer,
                Colors.purple,
                '+15s',
              ),
            ],
          ),
          
          SizedBox(height: 30),
          
          // Traffic Sources
          Container(
            padding: EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Traffic Sources',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                _buildTrafficSource('Direct', 45.2, Colors.blue),
                _buildTrafficSource('Search Engines', 32.1, Colors.green),
                _buildTrafficSource('Social Media', 15.7, Colors.purple),
                _buildTrafficSource('Referrals', 7.0, Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color, String change) {
    return Container(
      padding: EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color),
              Text(
                change,
                style: TextStyle(
                  color: change.startsWith('+') ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficSource(String source, double percentage, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(source),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsInterface() {
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
                'New Order Received',
                'Order #ORD123 from John Doe - \$2,500',
                Icons.shopping_cart,
                Colors.blue,
                '2 min ago',
                true,
              ),
              _buildNotificationItem(
                'Payment Completed',
                'Payment received for Order #ORD122',
                Icons.payment,
                Colors.green,
                '1 hour ago',
                true,
              ),
              _buildNotificationItem(
                'New User Registration',
                'Jane Smith has registered as a new customer',
                Icons.person_add,
                Colors.purple,
                '3 hours ago',
                false,
              ),
              _buildNotificationItem(
                'Support Message',
                'New message in support chat from Mike Johnson',
                Icons.chat,
                Colors.orange,
                '5 hours ago',
                true,
              ),
              _buildNotificationItem(
                'Server Maintenance',
                'Scheduled maintenance completed successfully',
                Icons.build,
                Colors.grey,
                '1 day ago',
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
}




class ProductManagementPage extends StatefulWidget {
  @override
  _ProductManagementPageState createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> 
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  
  final List<String> categories = [
    'All',
    'Mobile Development',
    'Web Development',
    'E-commerce',
    'IoT Solutions',
    'Security',
    'Enterprise'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 768;

  Stream<QuerySnapshot> _getProductsStream() {
    Query query = _firestore.collection('products');
    
    if (_selectedCategory != 'All') {
      query = query.where('category', isEqualTo: _selectedCategory);
    }
    
    return query.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleProductStatus(String productId, bool isActive) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'isActive': !isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product status updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating product status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
    //  appBar: CommonAppBar(
    //     type: AppBarType.admin, // Use appropriate type
    //   ),
      
      body: Column(
        children: [
          // Move TabBar here as a separate widget
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.blue.shade700,
              labelColor: Colors.blue.shade700,
              unselectedLabelColor: Colors.grey.shade600,
              tabs: [
                Tab(
                  icon: Icon(Icons.list),
                  text: 'All Products',
                ),
                Tab(
                  icon: Icon(Icons.add_box),
                  text: 'Add Product',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsList(),
                _buildAddProductForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
              SizedBox(height: 16),
              // Category Filter
              Container(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _selectedCategory == category;
                    
                    return Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        selectedColor: Colors.blue.shade700,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Products List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getProductsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Error loading products'),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              
              var products = snapshot.data!.docs;
              
              // Apply search filter
              if (_searchQuery.isNotEmpty) {
                products = products.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name'].toString().toLowerCase();
                  final description = data['description'].toString().toLowerCase();
                  return name.contains(_searchQuery) || description.contains(_searchQuery);
                }).toList();
              }
              
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_outlined,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'No products found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _tabController.animateTo(1),
                        child: Text('Add First Product'),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final data = product.data() as Map<String, dynamic>;
                  return _buildProductCard(product.id, data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(String productId, Map<String, dynamic> data) {
    final isActive = data['isActive'] ?? true;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(data['image'] ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
              child: !isActive
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: Center(
                        child: Text(
                          'INACTIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 16),
            
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data['name'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.grey.shade800 : Colors.grey.shade500,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    data['category'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${data['price']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(width: 8),
                      if (data['originalPrice'] != null)
                        Text(
                          '\$${data['originalPrice']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Spacer(),
                      if (data['isPopular'] == true)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 12, color: Colors.orange),
                              SizedBox(width: 4),
                              Text(
                                'Popular',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            Column(
              children: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditProductDialog(productId, data);
                        break;
                      case 'toggle':
                        _toggleProductStatus(productId, isActive);
                        break;
                      case 'delete':
                        _showDeleteConfirmDialog(productId, data['name']);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            isActive ? Icons.visibility_off : Icons.visibility,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProductForm() {
    return AddProductForm();
  }

  void _showEditProductDialog(String productId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: isMobile(context) ? double.infinity : 600,
          height: 500,
          child: EditProductForm(
            productId: productId,
            productData: data,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(String productId, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete "$productName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(productId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Add Product Form
class AddProductForm extends StatefulWidget {
  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _imageController = TextEditingController();
  final _durationController = TextEditingController();
  final _discountController = TextEditingController();
  
  String _selectedCategory = 'Mobile Development';
  String _selectedBadge = 'Hot';
  String _selectedBadgeColor = 'orange';
  bool _isPopular = false;
  bool _isActive = true;
  List<String> _features = [];
  final _featureController = TextEditingController();
  
  final List<String> categories = [
    'Mobile Development',
    'Web Development',
    'E-commerce',
    'IoT Solutions',
    'Security',
    'Enterprise'
  ];
  
  final List<Map<String, String>> badgeOptions = [
    {'value': 'Hot', 'color': 'red'},
    {'value': 'New', 'color': 'blue'},
    {'value': 'Sale', 'color': 'orange'},
    {'value': 'Premium', 'color': 'purple'},
    {'value': 'Popular', 'color': 'green'},
  ];
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _imageController.dispose();
    _durationController.dispose();
    _discountController.dispose();
    _featureController.dispose();
    super.dispose();
  }

  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 768;

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final price = double.parse(_priceController.text);
      final originalPrice = _originalPriceController.text.isNotEmpty 
          ? double.parse(_originalPriceController.text) 
          : price;
      
      // Calculate discount percentage
      double discount = 0;
      if (originalPrice > price) {
        discount = ((originalPrice - price) / originalPrice * 100);
      }
      
      final productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'price': price,
        'originalPrice': originalPrice,
        'discount': discount.round(),
        'image': _imageController.text.trim(),
        'duration': _durationController.text.trim(),
        'badge': _selectedBadge,
        'badgeColor': _selectedBadgeColor,
        'features': _features,
        'isPopular': _isPopular,
        'isActive': _isActive,
        'rating': 4.5, // Default rating
        'reviewCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore.collection('products').add(productData);
      
      // Clear form
      _clearForm();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _originalPriceController.clear();
    _imageController.clear();
    _durationController.clear();
    _discountController.clear();
    setState(() {
      _features.clear();
      _isPopular = false;
      _isActive = true;
    });
  }

  void _addFeature() {
    if (_featureController.text.trim().isNotEmpty) {
      setState(() {
        _features.add(_featureController.text.trim());
        _featureController.clear();
      });
    }
  }

  void _removeFeature(int index) {
    setState(() {
      _features.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Product',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            
            // Basic Information
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Product Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Product Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter product name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Category
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category *',
                        border: OutlineInputBorder(),
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter product description';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Pricing
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pricing',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: InputDecoration(
                              labelText: 'Current Price (\$) *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter price';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter valid price';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _originalPriceController,
                            decoration: InputDecoration(
                              labelText: 'Original Price (\$)',
                              border: OutlineInputBorder(),
                              helperText: 'Leave empty if no discount',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.trim().isNotEmpty) {
                                if (double.tryParse(value) == null) {
                                  return 'Please enter valid price';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Media & Display
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Media & Display',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Image URL
                    TextFormField(
                      controller: _imageController,
                      decoration: InputDecoration(
                        labelText: 'Image URL *',
                        border: OutlineInputBorder(),
                        helperText: 'Enter a valid image URL',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter image URL';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Badge Selection
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedBadge,
                            decoration: InputDecoration(
                              labelText: 'Badge',
                              border: OutlineInputBorder(),
                            ),
                            items: badgeOptions.map((badge) {
                              return DropdownMenuItem(
                                value: badge['value'],
                                child: Text(badge['value']!),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBadge = value!;
                                _selectedBadgeColor = badgeOptions
                                    .firstWhere((badge) => badge['value'] == value)['color']!;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getBadgeColor(_selectedBadgeColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selectedBadge,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Features
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Add Feature
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _featureController,
                            decoration: InputDecoration(
                              labelText: 'Add Feature',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addFeature(),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addFeature,
                          child: Text('Add'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Features List
                    if (_features.isNotEmpty)
                      Column(
                        children: _features.asMap().entries.map((entry) {
                          final index = entry.key;
                          final feature = entry.value;
                          
                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 20),
                                SizedBox(width: 8),
                                Expanded(child: Text(feature)),
                                IconButton(
                                  icon: Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => _removeFeature(index),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Additional Settings
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Duration
                    TextFormField(
                      controller: _durationController,
                      decoration: InputDecoration(
                        labelText: 'Duration/Timeline',
                        border: OutlineInputBorder(),
                        helperText: 'e.g., "2-3 weeks", "1 month"',
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Switches
                    SwitchListTile(
                      title: Text('Mark as Popular'),
                      subtitle: Text('Show in featured/popular section'),
                      value: _isPopular,
                      onChanged: (value) {
                        setState(() {
                          _isPopular = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: Text('Active'),
                      subtitle: Text('Product will be visible to customers'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Adding Product...'),
                        ],
                      )
                    : Text(
                        'Add Product',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 16),
            
            // Clear Form Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _clearForm,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Clear Form'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBadgeColor(String color) {
    switch (color) {
      case 'orange':
        return Colors.orange;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'indigo':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}

// Edit Product Form
class EditProductForm extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const EditProductForm({
    Key? key,
    required this.productId,
    required this.productData,
  }) : super(key: key);

  @override
  _EditProductFormState createState() => _EditProductFormState();
}

class _EditProductFormState extends State<EditProductForm> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;
  late TextEditingController _imageController;
  late TextEditingController _durationController;
  
  late String _selectedCategory;
  late String _selectedBadge;
  late String _selectedBadgeColor;
  late bool _isPopular;
  late bool _isActive;
  late List<String> _features;
  final _featureController = TextEditingController();
  
  final List<String> categories = [
    'Mobile Development',
    'Web Development',
    'E-commerce',
    'IoT Solutions',
    'Security',
    'Enterprise'
  ];
  
  final List<Map<String, String>> badgeOptions = [
    {'value': 'Hot', 'color': 'red'},
    {'value': 'New', 'color': 'blue'},
    {'value': 'Sale', 'color': 'orange'},
    {'value': 'Premium', 'color': 'purple'},
    {'value': 'Popular', 'color': 'green'},
  ];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.productData['name'] ?? '');
    _descriptionController = TextEditingController(text: widget.productData['description'] ?? '');
    _priceController = TextEditingController(text: widget.productData['price']?.toString() ?? '');
    _originalPriceController = TextEditingController(text: widget.productData['originalPrice']?.toString() ?? '');
    _imageController = TextEditingController(text: widget.productData['image'] ?? '');
    _durationController = TextEditingController(text: widget.productData['duration'] ?? '');
    
    _selectedCategory = widget.productData['category'] ?? 'Mobile Development';
    _selectedBadge = widget.productData['badge'] ?? 'Hot';
    _selectedBadgeColor = widget.productData['badgeColor'] ?? 'orange';
    _isPopular = widget.productData['isPopular'] ?? false;
    _isActive = widget.productData['isActive'] ?? true;
    _features = List<String>.from(widget.productData['features'] ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _imageController.dispose();
    _durationController.dispose();
    _featureController.dispose();
    super.dispose();
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final price = double.parse(_priceController.text);
      final originalPrice = _originalPriceController.text.isNotEmpty 
          ? double.parse(_originalPriceController.text) 
          : price;
      
      // Calculate discount percentage
      double discount = 0;
      if (originalPrice > price) {
        discount = ((originalPrice - price) / originalPrice * 100);
      }
      
      final productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'price': price,
        'originalPrice': originalPrice,
        'discount': discount.round(),
        'image': _imageController.text.trim(),
        'duration': _durationController.text.trim(),
        'badge': _selectedBadge,
        'badgeColor': _selectedBadgeColor,
        'features': _features,
        'isPopular': _isPopular,
        'isActive': _isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore.collection('products').doc(widget.productId).update(productData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addFeature() {
    if (_featureController.text.trim().isNotEmpty) {
      setState(() {
        _features.add(_featureController.text.trim());
        _featureController.clear();
      });
    }
  }

  void _removeFeature(int index) {
    setState(() {
      _features.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CommonAppBar(type: AppBarType.admin),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Product Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category *',
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter product description';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              // Pricing
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pricing',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: InputDecoration(
                                labelText: 'Current Price (\$) *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter price';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter valid price';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _originalPriceController,
                              decoration: InputDecoration(
                                labelText: 'Original Price (\$)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              // Media & Settings
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Media & Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _imageController,
                        decoration: InputDecoration(
                          labelText: 'Image URL *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter image URL';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _durationController,
                        decoration: InputDecoration(
                          labelText: 'Duration/Timeline',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      SwitchListTile(
                        title: Text('Mark as Popular'),
                        value: _isPopular,
                        onChanged: (value) {
                          setState(() {
                            _isPopular = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: Text('Active'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text('Update'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}