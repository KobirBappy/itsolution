import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;
  
  const OrderTrackingPage({Key? key, required this.orderId}) : super(key: key);
  
  @override
  _OrderTrackingPageState createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  
  Map<String, dynamic>? _orderData;
  bool _isLoading = true;
  
  final List<Map<String, dynamic>> _orderStatuses = [
    {
      'status': 'placed',
      'title': 'Order Placed',
      'description': 'We have received your order',
      'icon': Icons.shopping_cart,
    },
    {
      'status': 'processing',
      'title': 'Processing',
      'description': 'We are preparing your order',
      'icon': Icons.access_time,
    },
    {
      'status': 'active',
      'title': 'In Progress',
      'description': 'Your order is being worked on',
      'icon': Icons.work_outline,
    },
    {
      'status': 'completed',
      'title': 'Completed',
      'description': 'Your order has been completed',
      'icon': Icons.check_circle,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _loadOrderData();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 768;
  
  Future<void> _loadOrderData() async {
    try {
      final orderDoc = await _firestore
          .collection('orders')
          .doc(widget.orderId)
          .get();
      
      if (orderDoc.exists) {
        setState(() {
          _orderData = orderDoc.data();
          _isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading order: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  int _getStatusIndex(String status) {
    switch (status) {
      case 'placed':
        return 0;
      case 'processing':
        return 1;
      case 'active':
        return 2;
      case 'completed':
        return 3;
      case 'cancelled':
        return -1;
      default:
        return 0;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_orderData == null) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Order Tracking'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Order not found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    final orderDate = (_orderData!['createdAt'] as Timestamp).toDate();
    final formattedDate = DateFormat('MMMM dd, yyyy • hh:mm a').format(orderDate);
    final currentStatusIndex = _getStatusIndex(_orderData!['orderStatus'] ?? 'placed');
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Track Order',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
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
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order ID',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            _orderData!['orderId'] ?? 'N/A',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(_orderData!['orderStatus']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _orderData!['orderStatus']?.toUpperCase() ?? 'PROCESSING',
                          style: TextStyle(
                            color: _getStatusColor(_orderData!['orderStatus']),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Progress Tracker
            if (_orderData!['orderStatus'] != 'cancelled')
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 30),
                    if (isMobile(context))
                      _buildMobileProgress(currentStatusIndex)
                    else
                      _buildDesktopProgress(currentStatusIndex),
                  ],
                ),
              ),
            
            // Order Details
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildDetailRow('Service', _orderData!['service'] ?? 'N/A'),
                  _buildDetailRow('Quantity', '${_orderData!['quantity'] ?? 1}'),
                  _buildDetailRow('Duration', _orderData!['duration'] ?? 'N/A'),
                  Divider(height: 30),
                  _buildDetailRow('Subtotal', '\$${_orderData!['subtotal'] ?? '0'}'),
                  _buildDetailRow('Tax', '\$${_orderData!['tax'] ?? '0'}'),
                  _buildDetailRow(
                    'Total',
                    '\$${_orderData!['amount'] ?? '0'}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
            
            // Delivery Info
            if (_orderData!['deliveryAddress'] != null)
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey.shade600),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _orderData!['deliveryAddress'] ?? 'Digital Delivery',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_orderData!['estimatedDelivery'] != null) ...[
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.schedule, color: Colors.grey.shade600),
                          SizedBox(width: 12),
                          Text(
                            'Estimated Delivery: ${_orderData!['estimatedDelivery']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            
            // Activity Timeline
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity Timeline',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildTimelineItem(
                    'Order placed',
                    formattedDate,
                    Icons.shopping_cart,
                    true,
                  ),
                  if (currentStatusIndex >= 1)
                    _buildTimelineItem(
                      'Order confirmed',
                      'Your order has been confirmed',
                      Icons.check_circle,
                      true,
                    ),
                  if (currentStatusIndex >= 2)
                    _buildTimelineItem(
                      'Work in progress',
                      'Team is working on your order',
                      Icons.work,
                      true,
                    ),
                  if (currentStatusIndex >= 3)
                    _buildTimelineItem(
                      'Order completed',
                      'Your order has been completed',
                      Icons.done_all,
                      true,
                    ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMobileProgress(int currentIndex) {
    return Column(
      children: List.generate(_orderStatuses.length, (index) {
        final status = _orderStatuses[index];
        final isActive = index <= currentIndex;
        final isCompleted = index < currentIndex;
        
        return Row(
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isActive ? _getStatusColor(status['status']) : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : status['icon'],
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                if (index < _orderStatuses.length - 1)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    width: 2,
                    height: 50,
                    color: isCompleted ? _getStatusColor(status['status']) : Colors.grey.shade300,
                  ),
              ],
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? Colors.grey.shade800 : Colors.grey.shade500,
                    ),
                  ),
                  Text(
                    status['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: index < _orderStatuses.length - 1 ? 40 : 0),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
  
  Widget _buildDesktopProgress(int currentIndex) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_orderStatuses.length, (index) {
            final status = _orderStatuses[index];
            final isActive = index <= currentIndex;
            final isCompleted = index < currentIndex;
            
            return Expanded(
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isActive ? _getStatusColor(status['status']) : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : status['icon'],
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    status['title'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? Colors.grey.shade800 : Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    status['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }),
        ),
        SizedBox(height: 20),
        Stack(
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  widthFactor: (currentIndex + 1) / _orderStatuses.length * _progressAnimation.value,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
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
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimelineItem(String title, String subtitle, IconData icon, bool isCompleted) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green.shade50 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isCompleted ? Colors.green : Colors.grey.shade400,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
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
  
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'placed':
        return Colors.blue;
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
}