import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:itapp/shopping_cart.dart';
import 'dart:async';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> orderDetails;
  
  const PaymentPage({Key? key, required this.orderDetails}) : super(key: key);
  
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CartService _cartService = CartService();
  
  String _selectedPaymentMethod = 'stripe';
  bool _isProcessing = false;
  bool _acceptTerms = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Payment form controllers
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  
  // Mobile payment controllers
  final _mobileNumberController = TextEditingController();
  final _pinController = TextEditingController();

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    _mobileNumberController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 768;

  Future<void> _processPayment() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please accept terms and conditions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Simulate payment processing
      await Future.delayed(Duration(seconds: 3));
      
      // Get user data
      final userData = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      
      final userInfo = userData.data() ?? {};
      
      // Generate order ID
      final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
      
      // Create order in Firestore with all necessary fields
      final orderData = {
        'orderId': orderId,
        'userId': _auth.currentUser!.uid,
        'customerName': userInfo['name'] ?? widget.orderDetails['customerName'] ?? _auth.currentUser!.displayName ?? 'Customer',
        'customerEmail': _auth.currentUser!.email,
        'customerPhone': userInfo['phone'] ?? widget.orderDetails['customerPhone'] ?? '',
        'service': widget.orderDetails['service'] ?? 'Product Order',
        'items': widget.orderDetails['items'] ?? [],
        'quantity': widget.orderDetails['quantity'] ?? 1,
        'duration': widget.orderDetails['duration'] ?? 'Variable',
        'subtotal': double.tryParse(widget.orderDetails['subtotal'].toString()) ?? 0,
        'tax': double.tryParse(widget.orderDetails['tax'].toString()) ?? 0,
        'amount': double.tryParse(widget.orderDetails['amount'].toString()) ?? 0,
        'paymentMethod': _selectedPaymentMethod,
        'paymentStatus': 'completed',
        'orderStatus': 'processing',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isFromCart': widget.orderDetails['isFromCart'] ?? false,
        'notes': '',
      };
      
      final orderRef = await _firestore.collection('orders').add(orderData);
      
      // If order was from cart, clear the cart
      if (widget.orderDetails['isFromCart'] == true) {
        await _cartService.clearCart();
      }
      
      // Create a notification for admin
      await _firestore.collection('notifications').add({
        'type': 'new_order',
        'orderId': orderRef.id,
        'orderNumber': orderId,
        'customerName': orderData['customerName'],
        'amount': orderData['amount'],
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
        'forAdmin': true,
      });

      // Show success dialog
      _showSuccessDialog(orderId);
      
    } catch (e) {
      print('Payment error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Order ID: $orderId',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Thank you for your order. We\'ll send you a confirmation email shortly.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamedAndRemoveUntil('/user-dashboard', (route) => false);
                      },
                      child: Text('Dashboard'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamedAndRemoveUntil('/user-dashboard', (route) => false);
                        // You can navigate to order tracking once implemented
                      },
                      child: Text('View Orders'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    final totalAmount = double.tryParse(widget.orderDetails['amount'].toString()) ?? 0;
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Secure Payment',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.lock, color: Colors.green, size: 20),
                SizedBox(width: 5),
                Text(
                  'Secure',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Form
            Expanded(
              flex: isMobile(context) ? 1 : 2,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Indicator
                    _buildProgressIndicator(),
                    SizedBox(height: 30),
                    
                    // Payment Methods
                    Text(
                      'Select Payment Method',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildPaymentMethods(),
                    SizedBox(height: 30),
                    
                    // Payment Form
                    _buildPaymentForm(),
                    
                    // Terms and Conditions
                    CheckboxListTile(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                      title: Text(
                        'I accept the terms and conditions and privacy policy',
                        style: TextStyle(fontSize: 14),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    
                    SizedBox(height: 30),
                    
                    // Pay Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getPaymentColor(),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        child: _isProcessing
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text('Processing...'),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.lock),
                                  SizedBox(width: 10),
                                  Text(
                                    'Pay \$${totalAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    
                    // Security badges
                    SizedBox(height: 30),
                    _buildSecurityBadges(),
                  ],
                ),
              ),
            ),
            
            // Order Summary (Desktop only)
            if (!isMobile(context))
              Container(
                width: 350,
                margin: EdgeInsets.all(20),
                child: _buildOrderSummary(),
              ),
          ],
        ),
      ),
      
      // Mobile Bottom Sheet for Order Summary
      bottomSheet: isMobile(context) ? _buildMobileOrderSummary() : null,
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildProgressStep('1', 'Details', true),
        Expanded(child: _buildProgressLine(true)),
        _buildProgressStep('2', 'Payment', true),
        Expanded(child: _buildProgressLine(false)),
        _buildProgressStep('3', 'Complete', false),
      ],
    );
  }

  Widget _buildProgressStep(String number, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue.shade700 : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.blue.shade700 : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Container(
      height: 2,
      margin: EdgeInsets.only(bottom: 20),
      color: isActive ? Colors.blue.shade700 : Colors.grey.shade300,
    );
  }

  Widget _buildPaymentMethods() {
    final methods = [
      {'id': 'stripe', 'name': 'Credit/Debit Card', 'icon': FontAwesomeIcons.creditCard, 'color': Colors.purple},
      {'id': 'bkash', 'name': 'bKash', 'icon': FontAwesomeIcons.mobileAlt, 'color': Colors.pink},
      {'id': 'nagad', 'name': 'Nagad', 'icon': FontAwesomeIcons.wallet, 'color': Colors.orange},
      {'id': 'googlepay', 'name': 'Google Pay', 'icon': FontAwesomeIcons.google, 'color': Colors.blue},
    ];

    return Wrap(
      spacing: 15,
      runSpacing: 15,
      children: methods.map((method) {
        final isSelected = _selectedPaymentMethod == method['id'];
        
        return InkWell(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = method['id'] as String;
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? (method['color'] as Color).withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected ? method['color'] as Color : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  method['icon'] as IconData,
                  size: 30,
                  color: method['color'] as Color,
                ),
                SizedBox(height: 10),
                Text(
                  method['name'] as String,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? method['color'] as Color : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentForm() {
    switch (_selectedPaymentMethod) {
      case 'stripe':
        return _buildCardForm();
      case 'bkash':
      case 'nagad':
        return _buildMobilePaymentForm();
      case 'googlepay':
        return _buildGooglePayForm();
      default:
        return Container();
    }
  }

  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 20),
        TextFormField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Card Number',
            hintText: '1234 5678 9012 3456',
            prefixIcon: Icon(Icons.credit_card, color: Colors.purple),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.purple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  prefixIcon: Icon(Icons.lock, color: Colors.purple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        TextFormField(
          controller: _cardHolderController,
          decoration: InputDecoration(
            labelText: 'Cardholder Name',
            hintText: 'John Doe',
            prefixIcon: Icon(Icons.person, color: Colors.purple),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildMobilePaymentForm() {
    final color = _selectedPaymentMethod == 'bkash' ? Colors.pink : Colors.orange;
    final paymentName = _selectedPaymentMethod == 'bkash' ? 'bKash' : 'Nagad';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$paymentName Payment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 20),
        TextFormField(
          controller: _mobileNumberController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: '$paymentName Number',
            hintText: '01XXXXXXXXX',
            prefixIcon: Icon(Icons.phone_android, color: color),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        SizedBox(height: 20),
        TextFormField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'PIN',
            hintText: '****',
            prefixIcon: Icon(Icons.lock, color: color),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: color, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You will receive a payment request on your $paymentName app',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGooglePayForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Google Pay',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Icon(
                FontAwesomeIcons.google,
                size: 50,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              Text(
                'Click pay to continue with Google Pay',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'You will be redirected to complete payment',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSecurityBadge(Icons.lock, 'SSL Secured'),
        SizedBox(width: 20),
        _buildSecurityBadge(Icons.verified_user, 'PCI Compliant'),
        SizedBox(width: 20),
        _buildSecurityBadge(Icons.security, '256-bit Encryption'),
      ],
    );
  }

  Widget _buildSecurityBadge(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        SizedBox(width: 5),
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

  Widget _buildOrderSummary() {
    final subtotal = double.tryParse(widget.orderDetails['subtotal'].toString()) ?? 0;
    final tax = double.tryParse(widget.orderDetails['tax'].toString()) ?? 0;
    final total = double.tryParse(widget.orderDetails['amount'].toString()) ?? 0;
    
    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 20),
          if (widget.orderDetails['items'] != null && (widget.orderDetails['items'] as List).isNotEmpty)
            ...List<Widget>.from((widget.orderDetails['items'] as List).map((item) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item['name']} x${item['quantity']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Text(
                      '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              );
            }))
          else
            _buildOrderItem(
              widget.orderDetails['service'] ?? 'Service',
              '\$${subtotal.toStringAsFixed(2)}',
            ),
          SizedBox(height: 15),
          Divider(),
          SizedBox(height: 15),
          _buildOrderItem('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          _buildOrderItem('Tax (10%)', '\$${tax.toStringAsFixed(2)}'),
          SizedBox(height: 15),
          Divider(),
          SizedBox(height: 15),
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
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getPaymentColor(),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '30-day money back guarantee',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(String label, String value) {
    return Row(
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
    );
  }

  Widget _buildMobileOrderSummary() {
    final total = double.tryParse(widget.orderDetails['amount'].toString()) ?? 0;
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _getPaymentColor(),
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: EdgeInsets.all(20),
                  child: _buildOrderSummary(),
                ),
              );
            },
            child: Text('View Details'),
          ),
        ],
      ),
    );
  }

  Color _getPaymentColor() {
    switch (_selectedPaymentMethod) {
      case 'stripe':
        return Colors.purple;
      case 'bkash':
        return Colors.pink;
      case 'nagad':
        return Colors.orange;
      case 'googlepay':
        return Colors.blue;
      default:
        return Colors.blue.shade700;
    }
  }
}