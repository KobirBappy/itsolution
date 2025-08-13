// common_app_bar.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'unified_login.dart'; // Add this import for the login popup

enum AppBarType {
  home,
  admin,
  user,
  products,
  services,
  contact,
  cart,
  payment,
  orderTracking,
  profile,
  customerManagement,
  orderManagement,
  servicesManagement,
}

class CommonAppBar extends StatefulWidget implements PreferredSizeWidget {
  final AppBarType type;
  final String? title;
  final Map<String, dynamic>? additionalData;
  final VoidCallback? onBack;
  final List<Widget>? customActions;
  final Widget? customTitle;
  final Color? backgroundColor;
  final bool showBackButton;
  final bool centerTitle;

  const CommonAppBar({
    Key? key,
    required this.type,
    this.title,
    this.additionalData,
    this.onBack,
    this.customActions,
    this.customTitle,
    this.backgroundColor,
    this.showBackButton = true,
    this.centerTitle = false,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  _CommonAppBarState createState() => _CommonAppBarState();
}

class _CommonAppBarState extends State<CommonAppBar> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 768;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _getBackgroundColor(),
      elevation: _getElevation(),
      leading: _buildLeading(),
      title: _buildTitle(),
      centerTitle: widget.centerTitle || _shouldCenterTitle(),
      actions: _buildActions(),
      automaticallyImplyLeading: false,
      toolbarHeight: _getToolbarHeight(),
    );
  }

  Color _getBackgroundColor() {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    
    switch (widget.type) {
      case AppBarType.home:
        return Colors.transparent;
      case AppBarType.admin:
        return Colors.white;
      case AppBarType.payment:
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  double _getElevation() {
    switch (widget.type) {
      case AppBarType.home:
        return 0;
      case AppBarType.admin:
        return 2;
      default:
        return 0;
    }
  }

  double _getToolbarHeight() {
    switch (widget.type) {
      case AppBarType.home:
        return isMobile(context) ? 60 : 80;
      default:
        return kToolbarHeight;
    }
  }

  bool _shouldCenterTitle() {
    return widget.type == AppBarType.home && isMobile(context);
  }

  Widget? _buildLeading() {
    if (!widget.showBackButton) return null;
    
    switch (widget.type) {
      case AppBarType.home:
        return null; // No back button on home
      case AppBarType.admin:
        return null; // Admin uses drawer
      case AppBarType.user:
        return null; // User dashboard uses drawer
      default:
        return IconButton(
          icon: Icon(Icons.arrow_back, color: _getIconColor()),
          onPressed: widget.onBack ?? () => Navigator.pop(context),
        );
    }
  }

  Color _getIconColor() {
    switch (widget.type) {
      case AppBarType.home:
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade800;
    }
  }

  Widget _buildTitle() {
    if (widget.customTitle != null) return widget.customTitle!;
    
    switch (widget.type) {
      case AppBarType.home:
        return _buildHomeTitle();
      case AppBarType.admin:
        return _buildAdminTitle();
      case AppBarType.user:
        return _buildUserTitle();
      case AppBarType.products:
        return _buildProductsTitle();
      case AppBarType.services:
        return _buildServicesTitle();
      case AppBarType.contact:
        return _buildContactTitle();
      case AppBarType.cart:
        return _buildCartTitle();
      case AppBarType.payment:
        return _buildPaymentTitle();
      case AppBarType.orderTracking:
        return _buildOrderTrackingTitle();
      case AppBarType.profile:
        return _buildProfileTitle();
      case AppBarType.customerManagement:
        return _buildCustomerManagementTitle();
      case AppBarType.orderManagement:
        return _buildOrderManagementTitle();
      case AppBarType.servicesManagement:
        return _buildServicesManagementTitle();
      default:
        return Text(
          widget.title ?? 'AppTech Vibe',
          style: TextStyle(
            color: _getIconColor(),
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }

  Widget _buildHomeTitle() {
    return Row(
      mainAxisAlignment: isMobile(context) 
        ? MainAxisAlignment.center 
        : MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => Navigator.pushReplacementNamed(context, '/'),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FontAwesomeIcons.code,
                color: Colors.blue.shade700,
                size: isMobile(context) ? 24 : 30,
              ),
              SizedBox(width: 10),
              Text(
                'AppTech Vibe',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile(context) ? 18 : 22,
                ),
              ),
            ],
          ),
        ),
        if (!isMobile(context))
          Row(
            children: [
              _buildNavButton('Shop', '/products', isHighlighted: true),
              _buildNavButton('Services', '/services'),
              _buildNavButton('About', null),
              _buildNavButton('Contact', '/contact'),
              SizedBox(width: 20),
              _buildAnimatedLoginButton(),
            ],
          ),
      ],
    );
  }

  Widget _buildAdminTitle() {
    return Row(
      children: [
        if (!isMobile(context)) ...[
          Icon(FontAwesomeIcons.code, color: Colors.blue.shade700, size: 24),
          SizedBox(width: 10),
        ],
        Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
            fontSize: isMobile(context) ? 18 : 22,
          ),
        ),
      ],
    );
  }

  Widget _buildUserTitle() {
    return Row(
      children: [
        if (!isMobile(context)) ...[
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
    );
  }

  Widget _buildProductsTitle() {
    return Text(
      'Products',
      style: TextStyle(
        color: Colors.grey.shade800,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildServicesTitle() {
    return Text(
      'Our Services',
      style: TextStyle(
        color: Colors.grey.shade800,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildContactTitle() {
    return Text(
      'Contact Us',
      style: TextStyle(
        color: Colors.grey.shade800,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCartTitle() {
    return StreamBuilder<int>(
      stream: _getCartItemCount(),
      builder: (context, snapshot) {
        final itemCount = snapshot.data ?? 0;
        return Text(
          'Shopping Cart ($itemCount)',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  Widget _buildPaymentTitle() {
    return Row(
      children: [
        Text(
          'Secure Payment',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 10),
        Icon(Icons.lock, color: Colors.green, size: 20),
        SizedBox(width: 5),
        Text(
          'Secure',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTrackingTitle() {
    return Text(
      'Track Order',
      style: TextStyle(
        color: Colors.grey.shade800,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildProfileTitle() {
    return Text(
      'Profile Settings',
      style: TextStyle(
        color: Colors.grey.shade800,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCustomerManagementTitle() {
    return Text(
      'Customer Management',
      style: TextStyle(
        color: Colors.grey.shade800,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOrderManagementTitle() {
    return Text(
      'Order Management',
      style: TextStyle(
        color: Colors.grey.shade800,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildServicesManagementTitle() {
    return Text(
      'Services Management',
      style: TextStyle(
        color: Colors.grey.shade800,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  List<Widget> _buildActions() {
    List<Widget> actions = [];
    
    // Add custom actions first
    if (widget.customActions != null) {
      actions.addAll(widget.customActions!);
    }
    
    // Add type-specific actions
    switch (widget.type) {
      case AppBarType.home:
        actions.addAll(_buildHomeActions());
        break;
      case AppBarType.admin:
        actions.addAll(_buildAdminActions());
        break;
      case AppBarType.user:
        actions.addAll(_buildUserActions());
        break;
      case AppBarType.products:
        actions.addAll(_buildProductsActions());
        break;
      case AppBarType.services:
        actions.addAll(_buildServicesActions());
        break;
      case AppBarType.cart:
        actions.addAll(_buildCartActions());
        break;
      case AppBarType.payment:
        actions.addAll(_buildPaymentActions());
        break;
      case AppBarType.orderTracking:
        actions.addAll(_buildOrderTrackingActions());
        break;
      case AppBarType.profile:
        actions.addAll(_buildProfileActions());
        break;
      case AppBarType.customerManagement:
        actions.addAll(_buildCustomerManagementActions());
        break;
      case AppBarType.orderManagement:
        actions.addAll(_buildOrderManagementActions());
        break;
      case AppBarType.servicesManagement:
        actions.addAll(_buildServicesManagementActions());
        break;
      default:
        break;
    }
    
    return actions;
  }

  List<Widget> _buildHomeActions() {
    if (isMobile(context)) {
      return [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.blue.shade700),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ];
    }
    return [];
  }

  List<Widget> _buildAdminActions() {
    return [
      // Refresh Button
      IconButton(
        icon: Icon(Icons.refresh, color: Colors.grey.shade700),
        onPressed: () {
          // Trigger refresh callback if provided
          if (widget.additionalData?['onRefresh'] != null) {
            widget.additionalData!['onRefresh']();
          }
        },
        tooltip: 'Refresh Data',
      ),
      // Notifications
      _buildNotificationIcon(),
      // Messages
      _buildMessagesIcon(),
      // User Profile Menu
      _buildAdminProfileMenu(),
    ];
  }

  List<Widget> _buildUserActions() {
    return [
      // Refresh Button
      IconButton(
        icon: Icon(Icons.refresh, color: Colors.grey.shade700),
        onPressed: () {
          if (widget.additionalData?['onRefresh'] != null) {
            widget.additionalData!['onRefresh']();
          }
        },
        tooltip: 'Refresh Data',
      ),
      // Notifications
      _buildNotificationIcon(),
      // Shopping Cart
      _buildCartIcon(),
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
      _buildUserProfileMenu(),
    ];
  }

  List<Widget> _buildProductsActions() {
    return [
      _buildCartIcon(),
      if (_auth.currentUser != null) _buildUserAvatar(),
    ];
  }

  List<Widget> _buildServicesActions() {
    return [
      if (!isMobile(context))
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/contact'),
            icon: Icon(Icons.chat),
            label: Text('Get Quote'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
    ];
  }

  List<Widget> _buildCartActions() {
    return [
      if (widget.additionalData?['itemCount'] != null && 
          widget.additionalData!['itemCount'] > 0)
        TextButton.icon(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Clear Cart'),
                content: Text('Are you sure you want to remove all items?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('Clear'),
                  ),
                ],
              ),
            );
            
            if (confirm == true && widget.additionalData?['onClearCart'] != null) {
              widget.additionalData!['onClearCart']();
            }
          },
          icon: Icon(Icons.delete_outline, color: Colors.red),
          label: Text('Clear', style: TextStyle(color: Colors.red)),
        ),
    ];
  }

  List<Widget> _buildPaymentActions() {
    return [
      // Payment actions are minimal for security
    ];
  }

  List<Widget> _buildOrderTrackingActions() {
    return [
      PopupMenuButton(
        icon: Icon(Icons.more_vert, color: Colors.grey.shade800),
        itemBuilder: (context) => [
          PopupMenuItem(
            child: Row(
              children: [
                Icon(Icons.receipt, size: 20),
                SizedBox(width: 12),
                Text('View Invoice'),
              ],
            ),
            value: 'invoice',
          ),
          PopupMenuItem(
            child: Row(
              children: [
                Icon(Icons.support_agent, size: 20),
                SizedBox(width: 12),
                Text('Contact Support'),
              ],
            ),
            value: 'support',
          ),
        ],
        onSelected: (value) {
          if (value == 'support') {
            Navigator.pushNamed(context, '/contact');
          }
        },
      ),
    ];
  }

  List<Widget> _buildProfileActions() {
    return [
      // Profile actions are handled in tabs
    ];
  }

  List<Widget> _buildCustomerManagementActions() {
    return [
      IconButton(
        icon: Icon(Icons.download),
        onPressed: () {
          if (widget.additionalData?['onExport'] != null) {
            widget.additionalData!['onExport']();
          }
        },
        tooltip: 'Export Customers',
      ),
    ];
  }

  List<Widget> _buildOrderManagementActions() {
    return [
      IconButton(
        icon: Icon(Icons.filter_list),
        onPressed: () {
          if (widget.additionalData?['onShowFilter'] != null) {
            widget.additionalData!['onShowFilter']();
          }
        },
      ),
      if (!isMobile(context))
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              if (widget.additionalData?['onExport'] != null) {
                widget.additionalData!['onExport']();
              }
            },
            tooltip: 'Export Orders',
          ),
        ),
    ];
  }

  List<Widget> _buildServicesManagementActions() {
    return [
      // Services management actions are handled in tabs
    ];
  }

  // Helper Widgets
  Widget _buildNavButton(String text, String? route, {bool isHighlighted = false}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: TextButton(
        onPressed: route != null ? () => Navigator.pushNamed(context, route) : null,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted ? Colors.orange : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLoginButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => LoginPopupModal.show(context), // Updated to use popup instead of navigation
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_circle, size: 20),
            SizedBox(width: 8),
            Text(
              'Login',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade700),
          onPressed: () {
            if (widget.additionalData?['onNotificationPressed'] != null) {
              widget.additionalData!['onNotificationPressed']();
            }
          },
        ),
        if (widget.additionalData?['notificationCount'] != null && 
            widget.additionalData!['notificationCount'] > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                widget.additionalData!['notificationCount'] > 99 
                  ? '99+' 
                  : widget.additionalData!['notificationCount'].toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMessagesIcon() {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.chat_outlined, color: Colors.grey.shade700),
          onPressed: () {
            if (widget.additionalData?['onMessagesPressed'] != null) {
              widget.additionalData!['onMessagesPressed']();
            }
          },
        ),
        if (widget.additionalData?['unreadMessages'] != null && 
            widget.additionalData!['unreadMessages'] > 0)
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
    );
  }

  Widget _buildCartIcon() {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.shopping_cart_outlined, color: Colors.grey.shade800),
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
        StreamBuilder<int>(
          stream: _getCartItemCount(),
          builder: (context, snapshot) {
            final itemCount = snapshot.data ?? 0;
            return itemCount > 0
              ? Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      itemCount > 99 ? '99+' : itemCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildUserAvatar() {
    if (_auth.currentUser == null) return SizedBox();
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: CircleAvatar(
        backgroundColor: Colors.blue.shade700,
        child: Text(
          _auth.currentUser!.email![0].toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAdminProfileMenu() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
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
                  backgroundColor: Colors.blue.shade700,
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                if (!isMobile(context)) ...[
                  SizedBox(width: 8),
                  Text(
                    _auth.currentUser?.email?.split('@')[0] ?? 'Admin',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton(
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
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
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
                value: 'logout',
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _signOut();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileMenu() {
    return Padding(
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
                backgroundColor: Colors.blue.shade700,
                child: Text(
                  _auth.currentUser?.displayName?.substring(0, 1).toUpperCase() ?? 
                  _auth.currentUser?.email?.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              if (!isMobile(context)) ...[
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _auth.currentUser?.displayName ?? _auth.currentUser?.email?.split('@')[0] ?? 'User',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      widget.additionalData?['membershipLevel'] ?? 'Bronze',
                      style: TextStyle(color: Colors.blue.shade700, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
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
              if (widget.additionalData?['onOrdersPressed'] != null) {
                widget.additionalData!['onOrdersPressed']();
              }
              break;
            case 'settings':
              if (widget.additionalData?['onSettingsPressed'] != null) {
                widget.additionalData!['onSettingsPressed']();
              }
              break;
            case 'support':
              if (widget.additionalData?['onSupportPressed'] != null) {
                widget.additionalData!['onSupportPressed']();
              }
              break;
            case 'logout':
              _signOut();
              break;
          }
        },
      ),
    );
  }

  // Helper Methods
  Stream<int> _getCartItemCount() {
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
}