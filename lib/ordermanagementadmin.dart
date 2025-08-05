import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'common_appbar.dart';

class OrderManagementPage extends StatefulWidget {
  @override
  _OrderManagementPageState createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'All';
  DateTimeRange? _dateRange;
  
  final List<String> orderStatuses = [
    'All',
    'Processing',
    'Active',
    'Completed',
    'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 768;

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.grey.shade50,
  //     appBar: AppBar(
  //       backgroundColor: Colors.white,
  //       elevation: 1,
  //       title: Text(
  //         'Order Management',
  //         style: TextStyle(
  //           color: Colors.grey.shade800,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       bottom: TabBar(
  //         controller: _tabController,
  //         isScrollable: isMobile(context),
  //         labelColor: Colors.blue.shade700,
  //         unselectedLabelColor: Colors.grey.shade600,
  //         indicatorColor: Colors.blue.shade700,
  //         tabs: [
  //           Tab(text: 'All Orders'),
  //           Tab(text: 'Processing'),
  //           Tab(text: 'Active'),
  //           Tab(text: 'Completed'),
  //           Tab(text: 'Cancelled'),
  //         ],
  //         onTap: (index) {
  //           setState(() {
  //             _selectedStatus = index == 0 ? 'All' : orderStatuses[index];
  //           });
  //         },
  //       ),
  //       actions: [
  //         IconButton(
  //           icon: Icon(Icons.filter_list),
  //           onPressed: _showFilterDialog,
  //         ),
  //         if (!isMobile(context))
  //           Padding(
  //             padding: EdgeInsets.symmetric(horizontal: 8),
  //             child: IconButton(
  //               icon: Icon(Icons.download),
  //               onPressed: _exportOrders,
  //               tooltip: 'Export Orders',
  //             ),
  //           ),
  //       ],
  //     ),
  //     body: Column(
  //       children: [
  //         // Search Bar
  //         Container(
  //           padding: EdgeInsets.all(16),
  //           color: Colors.white,
  //           child: TextField(
  //             controller: _searchController,
  //             decoration: InputDecoration(
  //               hintText: 'Search by order ID, customer name, or email...',
  //               prefixIcon: Icon(Icons.search),
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(10),
  //                 borderSide: BorderSide.none,
  //               ),
  //               filled: true,
  //               fillColor: Colors.grey.shade100,
  //             ),
  //             onChanged: (value) {
  //               setState(() {
  //                 _searchQuery = value.toLowerCase();
  //               });
  //             },
  //           ),
  //         ),
          
  //         // Orders List
  //         Expanded(
  //           child: TabBarView(
  //             controller: _tabController,
  //             children: [
  //               _buildOrdersList('All'),
  //               _buildOrdersList('Processing'),
  //               _buildOrdersList('Active'),
  //               _buildOrdersList('Completed'),
  //               _buildOrdersList('Cancelled'),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //     floatingActionButton: isMobile(context)
  //         ? FloatingActionButton(
  //             onPressed: _exportOrders,
  //             child: Icon(Icons.download),
  //             backgroundColor: Colors.blue.shade700,
  //             tooltip: 'Export Orders',
  //           )
  //         : null,
  //   );
  // }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey.shade50,
    
    // REPLACE AppBar with CommonAppBar
    appBar: CommonAppBar(
      type: AppBarType.orderManagement,
      title: 'Order Management',
      additionalData: {
        'onShowFilter': _showFilterDialog,
        'onExport': _exportOrders,
      },
    ),
    
    body: Column(
      children: [
        // Move TabBar here
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: isMobile(context),
            labelColor: Colors.blue.shade700,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: Colors.blue.shade700,
            tabs: [
              Tab(text: 'All Orders'),
              Tab(text: 'Processing'),
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
            onTap: (index) {
              setState(() {
                _selectedStatus = index == 0 ? 'All' : orderStatuses[index];
              });
            },
          ),
        ),
        
        // Search Bar (exactly the same)
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by order ID, customer name, or email...',
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
        
        // Orders List (exactly the same)
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersList('All'),
              _buildOrdersList('Processing'),
              _buildOrdersList('Active'),
              _buildOrdersList('Completed'),
              _buildOrdersList('Cancelled'),
            ],
          ),
        ),
      ],
    ),
    
    // FloatingActionButton (exactly the same)
    floatingActionButton: isMobile(context)
        ? FloatingActionButton(
            onPressed: _exportOrders,
            child: Icon(Icons.download),
            backgroundColor: Colors.blue.shade700,
            tooltip: 'Export Orders',
          )
        : null,
  );
}

  Widget _buildOrdersList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getOrdersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        final allOrders = snapshot.data!.docs;
        final orders = _filterOrders(allOrders, status);
        
        if (orders.isEmpty) {
          return _buildEmptyState(status);
        }
        
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final data = order.data() as Map<String, dynamic>;
            return _buildOrderCard(order.id, data);
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _getOrdersStream() {
    // Simple query without compound conditions to avoid index requirements
    return _firestore.collection('orders').limit(1000).snapshots();
  }

  List<QueryDocumentSnapshot> _filterOrders(List<QueryDocumentSnapshot> orders, String status) {
    var filteredOrders = orders;
    
    // Filter by status
    if (status != 'All') {
      filteredOrders = orders.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['orderStatus']?.toLowerCase() == status.toLowerCase();
      }).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredOrders = filteredOrders.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final orderId = data['orderId']?.toString().toLowerCase() ?? '';
        final customerName = data['customerName']?.toString().toLowerCase() ?? '';
        final customerEmail = data['customerEmail']?.toString().toLowerCase() ?? '';
        
        return orderId.contains(_searchQuery) ||
               customerName.contains(_searchQuery) ||
               customerEmail.contains(_searchQuery);
      }).toList();
    }
    
    // Apply date filter
    if (_dateRange != null) {
      filteredOrders = filteredOrders.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final orderDate = (data['createdAt'] as Timestamp?)?.toDate();
        if (orderDate == null) return false;
        
        return orderDate.isAfter(_dateRange!.start) &&
               orderDate.isBefore(_dateRange!.end.add(Duration(days: 1)));
      }).toList();
    }
    
    // Sort by creation date (newest first)
    filteredOrders.sort((a, b) {
      final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
      final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
      
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      
      return bTime.compareTo(aTime);
    });
    
    return filteredOrders;
  }

  Widget _buildEmptyState(String status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 20),
          Text(
            status == 'All' ? 'No orders found' : 'No $status orders',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Orders will appear here when customers place them',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(String orderId, Map<String, dynamic> data) {
    final orderDate = (data['createdAt'] as Timestamp?)?.toDate();
    final formattedDate = orderDate != null 
        ? DateFormat('MMM dd, yyyy • hh:mm a').format(orderDate)
        : 'Unknown date';
    final status = data['orderStatus'] ?? 'processing';
    
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
        onTap: () => _showOrderDetails(orderId, data),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['orderId'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusChip(status),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Customer Info
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        (data['customerName'] ?? 'U')[0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['customerName'] ?? 'Unknown Customer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          data['customerEmail'] ?? 'No email',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Service and Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          data['service'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '\$${data['amount'] ?? '0'}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Payment Method
              if (data['paymentMethod'] != null) ...[
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      _getPaymentIcon(data['paymentMethod']),
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _formatPaymentMethod(data['paymentMethod']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'processing':
        color = Colors.orange;
        icon = Icons.access_time;
        break;
      case 'active':
        color = Colors.blue;
        icon = Icons.work_outline;
        break;
      case 'completed':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 5),
          Text(
            status.substring(0, 1).toUpperCase() + status.substring(1),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'stripe':
        return FontAwesomeIcons.creditCard;
      case 'bkash':
        return FontAwesomeIcons.mobileAlt;
      case 'nagad':
        return FontAwesomeIcons.wallet;
      case 'googlepay':
        return FontAwesomeIcons.google;
      default:
        return Icons.payment;
    }
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'stripe':
        return 'Credit Card';
      case 'bkash':
        return 'bKash';
      case 'nagad':
        return 'Nagad';
      case 'googlepay':
        return 'Google Pay';
      default:
        return method;
    }
  }

  void _showOrderDetails(String orderId, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsSheet(
        orderId: orderId,
        orderData: data,
        onStatusChanged: () {
          setState(() {});
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Orders'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.date_range),
              title: Text(_dateRange == null
                  ? 'Select Date Range'
                  : '${DateFormat('MMM dd').format(_dateRange!.start)} - ${DateFormat('MMM dd').format(_dateRange!.end)}'),
              onTap: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (range != null) {
                  setState(() {
                    _dateRange = range;
                  });
                  Navigator.pop(context);
                }
              },
            ),
            if (_dateRange != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _dateRange = null;
                  });
                  Navigator.pop(context);
                },
                child: Text('Clear Date Filter'),
              ),
          ],
        ),
      ),
    );
  }

  void _exportOrders() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting orders...'),
        backgroundColor: Colors.blue,
      ),
    );
    // Implement CSV export functionality
  }
}

// Order Details Sheet
class OrderDetailsSheet extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> orderData;
  final VoidCallback onStatusChanged;

  const OrderDetailsSheet({
    Key? key,
    required this.orderId,
    required this.orderData,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  _OrderDetailsSheetState createState() => _OrderDetailsSheetState();
}

class _OrderDetailsSheetState extends State<OrderDetailsSheet> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _currentStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.orderData['orderStatus'] ?? 'processing';
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    
    try {
      await _firestore.collection('orders').doc(widget.orderId).update({
        'orderStatus': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      setState(() {
        _currentStatus = newStatus;
      });
      
      widget.onStatusChanged();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating order status'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderDate = (widget.orderData['createdAt'] as Timestamp?)?.toDate();
    final formattedDate = orderDate != null 
        ? DateFormat('MMMM dd, yyyy • hh:mm a').format(orderDate)
        : 'Unknown date';
    
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      widget.orderData['orderId'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
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
                  // Status Update
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          children: ['processing', 'active', 'completed', 'cancelled'].map((status) {
                            final isSelected = _currentStatus == status;
                            return ChoiceChip(
                              label: Text(
                                status.substring(0, 1).toUpperCase() + status.substring(1),
                              ),
                              selected: isSelected,
                              onSelected: _isUpdating
                                  ? null
                                  : (selected) {
                                      if (selected) {
                                        _updateOrderStatus(status);
                                      }
                                    },
                              selectedColor: _getStatusColor(status),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Order Information
                  _buildSection(
                    'Order Information',
                    [
                      _buildInfoRow('Order Date', formattedDate),
                      _buildInfoRow('Payment Method', _formatPaymentMethod(widget.orderData['paymentMethod'] ?? 'N/A')),
                      _buildInfoRow('Payment Status', widget.orderData['paymentStatus'] ?? 'N/A'),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Customer Information
                  _buildSection(
                    'Customer Information',
                    [
                      _buildInfoRow('Name', widget.orderData['customerName'] ?? 'N/A'),
                      _buildInfoRow('Email', widget.orderData['customerEmail'] ?? 'N/A'),
                      _buildInfoRow('Phone', widget.orderData['customerPhone'] ?? 'N/A'),
                      if (widget.orderData['customerCompany'] != null)
                        _buildInfoRow('Company', widget.orderData['customerCompany']),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Service Details
                  _buildSection(
                    'Service Details',
                    [
                      _buildInfoRow('Service', widget.orderData['service'] ?? 'N/A'),
                      _buildInfoRow('Package', widget.orderData['package'] ?? 'Standard'),
                      _buildInfoRow('Duration', widget.orderData['duration'] ?? 'N/A'),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Payment Summary
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildInfoRow('Subtotal', '\$${widget.orderData['subtotal'] ?? '0'}'),
                        _buildInfoRow('Tax', '\$${widget.orderData['tax'] ?? '0'}'),
                        Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            Text(
                              '\$${widget.orderData['amount'] ?? '0'}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  if (widget.orderData['notes'] != null) ...[
                    SizedBox(height: 20),
                    _buildSection(
                      'Additional Notes',
                      [
                        Text(
                          widget.orderData['notes'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  SizedBox(height: 30),
                ],
              ),
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
            fontSize: 16,
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
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return Colors.orange;
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'stripe':
        return 'Credit Card';
      case 'bkash':
        return 'bKash';
      case 'nagad':
        return 'Nagad';
      case 'googlepay':
        return 'Google Pay';
      default:
        return method;
    }
  }
}