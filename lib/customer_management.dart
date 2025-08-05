import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'common_appbar.dart';

class CustomerManagementPage extends StatefulWidget {
  @override
  _CustomerManagementPageState createState() => _CustomerManagementPageState();
}

class _CustomerManagementPageState extends State<CustomerManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _searchController = TextEditingController();
  
  String _searchQuery = '';
  String _sortBy = 'newest';
  String _filterRole = 'all';
  
  final List<Map<String, dynamic>> sortOptions = [
    {'value': 'newest', 'label': 'Newest First'},
    {'value': 'oldest', 'label': 'Oldest First'},
    {'value': 'name', 'label': 'Name (A-Z)'},
    {'value': 'orders', 'label': 'Most Orders'},
    {'value': 'spent', 'label': 'Highest Spent'},
  ];
  
  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 768;
  
  Stream<QuerySnapshot> _getCustomersStream() {
    // Simplified query - we'll do filtering and sorting in memory
    return _firestore.collection('users').limit(1000).snapshots();
  }
  
  List<QueryDocumentSnapshot> _filterAndSortUsers(List<QueryDocumentSnapshot> docs) {
    // Filter by role
    var filteredDocs = docs;
    if (_filterRole != 'all') {
      filteredDocs = docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['role'] == _filterRole;
      }).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredDocs = filteredDocs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['name'] ?? '').toString().toLowerCase();
        final email = (data['email'] ?? '').toString().toLowerCase();
        final phone = (data['phone'] ?? '').toString().toLowerCase();
        
        return name.contains(_searchQuery) ||
               email.contains(_searchQuery) ||
               phone.contains(_searchQuery);
      }).toList();
    }
    
    // Sort in memory
    filteredDocs.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;
      
      switch (_sortBy) {
        case 'newest':
          final aTime = (aData['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
          final bTime = (bData['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
          return bTime.compareTo(aTime);
        case 'oldest':
          final aTime = (aData['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
          final bTime = (bData['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
          return aTime.compareTo(bTime);
        case 'name':
          final aName = (aData['name'] ?? '').toString().toLowerCase();
          final bName = (bData['name'] ?? '').toString().toLowerCase();
          return aName.compareTo(bName);
        default:
          return 0;
      }
    });
    
    return filteredDocs;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
       appBar: CommonAppBar(
        type: AppBarType.customerManagement,
        additionalData: {
          'onExport': _exportCustomers,
        },
        
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name, email, or phone...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
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
                    ),
                    SizedBox(width: 16),
                    // Sort Dropdown
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton<String>(
                        value: _sortBy,
                        underline: SizedBox(),
                        icon: Icon(Icons.sort),
                        items: sortOptions.map<DropdownMenuItem<String>>((option) {
                          return DropdownMenuItem<String>(
                            value: option['value'] as String,
                            child: Text(option['label']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Role Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      SizedBox(width: 8),
                      _buildFilterChip('Customers', 'customer'),
                      SizedBox(width: 8),
                      _buildFilterChip('Admins', 'admin'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Customers List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getCustomersStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                
                final allUsers = snapshot.data!.docs;
                final customers = _filterAndSortUsers(allUsers);
                
                if (customers.isEmpty) {
                  return _buildEmptyState();
                }
                
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    final data = customer.data() as Map<String, dynamic>;
                    return FutureBuilder<Map<String, dynamic>>(
                      future: _getCustomerStats(customer.id, data['email']),
                      builder: (context, statsSnapshot) {
                        final stats = statsSnapshot.data ?? {
                          'totalOrders': 0,
                          'totalSpent': 0,
                          'lastOrder': null,
                        };
                        return _buildCustomerCard(customer.id, data, stats);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterRole == value;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterRole = value;
        });
      },
      selectedColor: Colors.blue.shade700,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 20),
          Text(
            'No customers found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Customers will appear here when they register',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<Map<String, dynamic>> _getCustomerStats(String userId, String? email) async {
    try {
      // Simple query for orders by user email - no compound index needed
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('customerEmail', isEqualTo: email)
          .limit(100) // Limit to prevent large queries
          .get();
      
      double totalSpent = 0;
      DateTime? lastOrderDate;
      
      for (var doc in ordersSnapshot.docs) {
        final data = doc.data();
        totalSpent += (data['amount'] ?? 0).toDouble();
        
        final orderDate = (data['createdAt'] as Timestamp?)?.toDate();
        if (orderDate != null && (lastOrderDate == null || orderDate.isAfter(lastOrderDate))) {
          lastOrderDate = orderDate;
        }
      }
      
      return {
        'totalOrders': ordersSnapshot.docs.length,
        'totalSpent': totalSpent,
        'lastOrder': lastOrderDate,
      };
    } catch (e) {
      print('Error getting customer stats: $e');
      return {
        'totalOrders': 0,
        'totalSpent': 0,
        'lastOrder': null,
      };
    }
  }
  
  Widget _buildCustomerCard(String customerId, Map<String, dynamic> data, Map<String, dynamic> stats) {
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final formattedDate = createdAt != null 
        ? DateFormat('MMM dd, yyyy').format(createdAt)
        : 'N/A';
    
    final lastOrderDate = stats['lastOrder'] as DateTime?;
    final lastOrderFormatted = lastOrderDate != null
        ? DateFormat('MMM dd, yyyy').format(lastOrderDate)
        : 'No orders yet';
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () => _showCustomerDetails(customerId, data, stats),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: data['profileImage'] != null
                        ? NetworkImage(data['profileImage'])
                        : null,
                    child: data['profileImage'] == null
                        ? Text(
                            (data['name'] ?? data['email'] ?? 'U')[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: 16),
                  
                  // Customer Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              data['name'] ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: data['role'] == 'admin' 
                                    ? Colors.purple.shade100 
                                    : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                data['role'] ?? 'customer',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: data['role'] == 'admin' 
                                      ? Colors.purple.shade700 
                                      : Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          data['email'] ?? 'No email',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (data['phone'] != null && data['phone'].toString().isNotEmpty)
                          Text(
                            data['phone'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Actions
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 20),
                            SizedBox(width: 12),
                            Text('View Details'),
                          ],
                        ),
                        value: 'view',
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(Icons.email, size: 20),
                            SizedBox(width: 12),
                            Text('Send Email'),
                          ],
                        ),
                        value: 'email',
                      ),
                      if (data['role'] != 'admin')
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.admin_panel_settings, size: 20),
                              SizedBox(width: 12),
                              Text('Make Admin'),
                            ],
                          ),
                          value: 'make_admin',
                        ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(Icons.block, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Disable Account', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        value: 'disable',
                      ),
                    ],
                    onSelected: (value) async {
                      switch (value) {
                        case 'view':
                          _showCustomerDetails(customerId, data, stats);
                          break;
                        case 'make_admin':
                          _makeAdmin(customerId);
                          break;
                        case 'disable':
                          _disableAccount(customerId);
                          break;
                      }
                    },
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Stats
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Orders',
                      stats['totalOrders'].toString(),
                      Icons.shopping_cart,
                      Colors.blue,
                    ),
                    _buildStatItem(
                      'Total Spent',
                      '\$${stats['totalSpent'].toStringAsFixed(0)}',
                      Icons.attach_money,
                      Colors.green,
                    ),
                    _buildStatItem(
                      'Last Order',
                      lastOrderFormatted,
                      Icons.access_time,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 12),
              
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Joined: $formattedDate',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (data['lastActive'] != null)
                    Text(
                      'Last active: ${_formatLastActive(data['lastActive'] as Timestamp)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
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
  
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  String _formatLastActive(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return DateFormat('MMM dd, yyyy').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
  
  void _showCustomerDetails(String customerId, Map<String, dynamic> data, Map<String, dynamic> stats) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomerDetailsSheet(
        customerId: customerId,
        customerData: data,
        stats: stats,
      ),
    );
  }
  
  Future<void> _makeAdmin(String customerId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Make Admin'),
        content: Text('Are you sure you want to grant admin privileges to this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await _firestore.collection('users').doc(customerId).update({
          'role': 'admin',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User has been granted admin privileges'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating user role'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _disableAccount(String customerId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Disable Account'),
        content: Text('Are you sure you want to disable this account? The user will not be able to login.'),
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
            child: Text('Disable'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await _firestore.collection('users').doc(customerId).update({
          'isDisabled': true,
          'disabledAt': FieldValue.serverTimestamp(),
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account has been disabled'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error disabling account'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _exportCustomers() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting customers...'),
        backgroundColor: Colors.blue,
      ),
    );
    // Implement CSV export functionality
  }
}

// Customer Details Sheet
class CustomerDetailsSheet extends StatelessWidget {
  final String customerId;
  final Map<String, dynamic> customerData;
  final Map<String, dynamic> stats;
  
  const CustomerDetailsSheet({
    Key? key,
    required this.customerId,
    required this.customerData,
    required this.stats,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final createdAt = (customerData['createdAt'] as Timestamp?)?.toDate();
    final formattedDate = createdAt != null 
        ? DateFormat('MMMM dd, yyyy').format(createdAt)
        : 'N/A';
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 10),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Customer Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue.shade100,
                          backgroundImage: customerData['profileImage'] != null
                              ? NetworkImage(customerData['profileImage'])
                              : null,
                          child: customerData['profileImage'] == null
                              ? Text(
                                  (customerData['name'] ?? customerData['email'] ?? 'U')[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                )
                              : null,
                        ),
                        SizedBox(height: 16),
                        Text(
                          customerData['name'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          customerData['email'] ?? 'No email',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: customerData['role'] == 'admin' 
                                ? Colors.purple.shade100 
                                : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            customerData['role']?.toUpperCase() ?? 'CUSTOMER',
                            style: TextStyle(
                              fontSize: 12,
                              color: customerData['role'] == 'admin' 
                                  ? Colors.purple.shade700 
                                  : Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Orders',
                          stats['totalOrders'].toString(),
                          Icons.shopping_cart,
                          Colors.blue,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Total Spent',
                          "\${stats['totalSpent'].toStringAsFixed(2)}",

                          Icons.attach_money,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Contact Information
                  _buildSection(
                    'Contact Information',
                    [
                      _buildInfoRow('Email', customerData['email'] ?? 'Not provided'),
                      _buildInfoRow('Phone', customerData['phone'] ?? 'Not provided'),
                      if (customerData['bio'] != null && customerData['bio'].toString().isNotEmpty)
                        _buildInfoRow('Bio', customerData['bio']),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Account Information
                  _buildSection(
                    'Account Information',
                    [
                      _buildInfoRow('Customer ID', customerId),
                      _buildInfoRow('Joined Date', formattedDate),
                      _buildInfoRow('Account Status', customerData['isDisabled'] == true ? 'Disabled' : 'Active'),
                      if (stats['lastOrder'] != null)
                        _buildInfoRow('Last Order', DateFormat('MMM dd, yyyy').format(stats['lastOrder'])),
                    ],
                  ),
                  
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}