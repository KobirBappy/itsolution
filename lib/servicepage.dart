import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'unified_login.dart'; // Import the login popup

class ServicesPage extends StatefulWidget {
  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late AnimationController _controller;
  late AnimationController _heroController;
  late List<AnimationController> _cardControllers;
  late AnimationController _filterController;
  String selectedCategory = 'All';
  
  final List<ServiceDetail> services = [
    ServiceDetail(
      icon: FontAwesomeIcons.mobileAlt,
      title: 'Mobile App Development',
      category: 'Development',
      description: 'Create powerful native and cross-platform mobile applications for iOS and Android with cutting-edge technology.',
      features: [
        'Native iOS & Android Development',
        'Cross-platform Solutions (Flutter, React Native)',
        'UI/UX Design & Prototyping',
        'App Store Deployment',
        'Performance Optimization',
        'Push Notifications & Analytics'
      ],
      pricing: 'Starting from \$5,000',
      duration: '2-6 months',
      color: Color(0xFF667EEA),
      image: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=800',
      gradient: [Color(0xFF667EEA), Color(0xFF764BA2)],
    ),
    ServiceDetail(
      icon: FontAwesomeIcons.globe,
      title: 'Web Development',
      category: 'Development',
      description: 'Build responsive, modern websites and web applications tailored to your business needs with latest frameworks.',
      features: [
        'Responsive Design',
        'E-commerce Integration',
        'Content Management Systems',
        'Progressive Web Apps',
        'SEO Optimization',
        'API Development'
      ],
      pricing: 'Starting from \$3,000',
      duration: '1-4 months',
      color: Color(0xFFE056FD),
      image: 'https://images.unsplash.com/photo-1467232004584-a241de8bcf5d?w=800',
      gradient: [Color(0xFFE056FD), Color(0xFF3FCEBC)],
    ),
    ServiceDetail(
      icon: FontAwesomeIcons.networkWired,
      title: 'Networking Solutions',
      category: 'Infrastructure',
      description: 'Design and implement robust network infrastructure for your organization with enterprise-grade security.',
      features: [
        'Network Design & Architecture',
        'Firewall Configuration',
        'VPN Setup',
        'Network Security Audits',
        'Wireless Solutions',
        '24/7 Monitoring'
      ],
      pricing: 'Starting from \$2,500',
      duration: '1-2 months',
      color: Color(0xFF11998E),
      image: 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=800',
      gradient: [Color(0xFF11998E), Color(0xFF38EF7D)],
    ),
    ServiceDetail(
      icon: FontAwesomeIcons.server,
      title: 'cPanel & Server Management',
      category: 'Infrastructure',
      description: 'Professional server management and optimization services for peak performance and reliability.',
      features: [
        'Server Setup & Configuration',
        'cPanel Installation',
        'Performance Optimization',
        'Security Hardening',
        'Backup Solutions',
        'Migration Services'
      ],
      pricing: 'Starting from \$500/month',
      duration: 'Ongoing',
      color: Color(0xFFFF8A56),
      image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
      gradient: [Color(0xFFFF8A56), Color(0xFFFFAD56)],
    ),
    ServiceDetail(
      icon: FontAwesomeIcons.microchip,
      title: 'IoT Solutions',
      category: 'Emerging Tech',
      description: 'Connect and automate your devices with cutting-edge Internet of Things technology for smart operations.',
      features: [
        'Smart Device Integration',
        'Sensor Networks',
        'Data Analytics',
        'Cloud Connectivity',
        'Mobile App Control',
        'Automation Scripts'
      ],
      pricing: 'Starting from \$8,000',
      duration: '3-6 months',
      color: Color(0xFF4FACFE),
      image: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800',
      gradient: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    ),
    ServiceDetail(
      icon: FontAwesomeIcons.shieldAlt,
      title: 'Ethical Hacking & Security',
      category: 'Security',
      description: 'Protect your digital assets with comprehensive security testing and advanced threat protection solutions.',
      features: [
        'Penetration Testing',
        'Vulnerability Assessment',
        'Security Audits',
        'Incident Response',
        'Security Training',
        'Compliance Consulting'
      ],
      pricing: 'Starting from \$2,000',
      duration: '2-4 weeks',
      color: Color(0xFFFF416C),
      image: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800',
      gradient: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
    ),
    ServiceDetail(
      icon: FontAwesomeIcons.shoppingCart,
      title: 'E-commerce Solutions',
      category: 'Development',
      description: 'Launch your online store with secure payment processing, inventory management, and growth analytics.',
      features: [
        'Custom Store Development',
        'Payment Gateway Integration',
        'Inventory Management',
        'Multi-vendor Support',
        'Mobile Commerce',
        'Analytics Dashboard'
      ],
      pricing: 'Starting from \$4,500',
      duration: '2-3 months',
      color: Color(0xFF6C5CE7),
      image: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800',
      gradient: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
    ),
    ServiceDetail(
      icon: FontAwesomeIcons.building,
      title: 'ERP Solutions',
      category: 'Enterprise',
      description: 'Streamline your business operations with integrated enterprise resource planning and automation.',
      features: [
        'Custom ERP Development',
        'Module Integration',
        'Process Automation',
        'Reporting & Analytics',
        'Multi-branch Support',
        'Cloud Deployment'
      ],
      pricing: 'Starting from \$15,000',
      duration: '4-8 months',
      color: Color(0xFF8B5A2B),
      image: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=800',
      gradient: [Color(0xFF8B5A2B), Color(0xFFCD853F)],
    ),
  ];

  final List<String> categories = ['All', 'Development', 'Infrastructure', 'Security', 'Emerging Tech', 'Enterprise'];

  @override
  void initState() {
    super.initState();
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
    
    _cardControllers = List.generate(
      services.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 800),
        vsync: this,
      ),
    );
    
    _heroController.forward();
    _controller.forward();
    _filterController.forward();
    _animateCards();
  }

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
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  bool isTablet(BuildContext context) => MediaQuery.of(context).size.width < 1200;

  List<ServiceDetail> get filteredServices {
    if (selectedCategory == 'All') {
      return services;
    }
    return services.where((service) => service.category == selectedCategory).toList();
  }

  void _handleGetQuote() {
    if (_auth.currentUser == null) {
      // Show login popup if user is not authenticated
      LoginPopupModal.show(context);
    } else {
      // Navigate to contact page if user is logged in
      Navigator.pushNamed(context, '/contact');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: _buildEnhancedAppBar(),
      body: Column(
        children: [
          _buildHeroSection(),
          _buildCategoryFilter(),
          Expanded(child: _buildServicesGrid()),
        ],
      ),
      floatingActionButton: isMobile(context) ? _buildFloatingActionButton() : null,
    );
  }

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
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey.shade700, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ).createShader(bounds),
        child: Text(
          'Our Services',
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
        
        // Get Quote Button
        if (!isMobile(context))
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.red],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _handleGetQuote,
              icon: Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white),
              label: Text(
                'Get Quote',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
        
        // User Avatar for authenticated users
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
                    Navigator.pushNamed(context, '/cart');
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

Widget _buildHeroSection() {
  return SlideTransition(
    position: Tween<Offset>(
      begin: Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    )),
    child: FadeTransition(
      opacity: _heroController,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA).withOpacity(0.08),
              Color(0xFF764BA2).withOpacity(0.08),
              Color(0xFFE056FD).withOpacity(0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF667EEA).withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ).createShader(bounds),
              child: Text(
                'Professional IT Services',
                style: TextStyle(
                  fontSize: isMobile(context) ? 22 : 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Transform your business with our comprehensive suite of cutting-edge IT solutions',
              style: TextStyle(
                fontSize: isMobile(context) ? 14 : 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatCard('50+', 'Projects', fontSize: 14),
                SizedBox(width: 12),
                _buildStatCard('24/7', 'Support', fontSize: 14),
                SizedBox(width: 12),
                _buildStatCard('99%', 'Uptime', fontSize: 14),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildStatCard(String number, String label, {required int fontSize}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667EEA),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _filterController,
        curve: Curves.easeOutCubic,
      )),
      child: Container(
        height: 60,
        margin: EdgeInsets.only(bottom: 20),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category;
            
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
                      selectedCategory = category;
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
    );
  }

  Widget _buildServicesGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile(context) ? 1 : isTablet(context) ? 2 : 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: isMobile(context) ? 1.5 : 1.4,
      ),
      itemCount: filteredServices.length,
      itemBuilder: (context, index) {
        return _buildServiceCard(filteredServices[index], index);
      },
    );
  }

  Widget _buildServiceCard(ServiceDetail service, int index) {
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
            onTap: () => _showServiceDetails(service),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: service.color.withOpacity(0.15),
                    spreadRadius: 0,
                    blurRadius: 30,
                    offset: Offset(0, 15),
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
                  // Enhanced Image Section
                  Stack(
                    children: [
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                          gradient: LinearGradient(
                            colors: service.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(
                                  service.image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      service.color.withOpacity(0.8),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Category Badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Text(
                            service.category,
                            style: TextStyle(
                              color: service.color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Icon
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: service.color.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            service.icon,
                            color: service.color,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Enhanced Content Section
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              service.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Starting from',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: service.gradient,
                                    ).createShader(bounds),
                                    child: Text(
                                      service.pricing.split('from ')[1],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: service.gradient),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => _showServiceDetails(service),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Details',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ],
                                      ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange, Colors.red],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _handleGetQuote,
        icon: Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: Text(
          'Get Quote',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  void _showServiceDetails(ServiceDetail service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceDetailModal(service: service, onGetQuote: _handleGetQuote),
    );
  }
}

class ServiceDetailModal extends StatelessWidget {
  final ServiceDetail service;
  final VoidCallback onGetQuote;

  const ServiceDetailModal({
    Key? key, 
    required this.service,
    required this.onGetQuote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 0,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Enhanced Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 60,
            height: 5,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: service.gradient),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: service.gradient),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: service.color.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 0,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          service.icon,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.title,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                                height: 1.2,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 4),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: service.gradient),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                service.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.grey.shade600),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Enhanced Description
                  _buildSection(
                    'Overview',
                    service.description,
                    service.gradient,
                  ),
                  
                  SizedBox(height: 28),
                  
                  // Enhanced Features
                  _buildFeaturesSection(service),
                  
                  SizedBox(height: 28),
                  
                  // Enhanced Pricing & Duration
                  _buildPricingSection(service),
                  
                  SizedBox(height: 32),
                  
                  // Enhanced CTA Buttons
                  _buildActionButtons(context, service),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, List<Color> gradient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(colors: gradient).createShader(bounds),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(ServiceDetail service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(colors: service.gradient).createShader(bounds),
          child: Text(
            'What\'s Included',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 16),
        ...service.features.asMap().entries.map((entry) {
          int index = entry.key;
          String feature = entry.value;
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: service.gradient),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      fontSize: 15,
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
    );
  }

  Widget _buildPricingSection(ServiceDetail service) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  service.gradient[0].withOpacity(0.1),
                  service.gradient[1].withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: service.color.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Investment',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(colors: service.gradient).createShader(bounds),
                  child: Text(
                    service.pricing,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  service.gradient[1].withOpacity(0.1),
                  service.gradient[0].withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: service.color.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timeline',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(colors: service.gradient).createShader(bounds),
                  child: Text(
                    service.duration,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ServiceDetail service) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: service.gradient),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: service.color.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onGetQuote();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/contact');
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: service.color, width: 2),
              padding: EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(colors: service.gradient).createShader(bounds),
              child: Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ServiceDetail {
  final IconData icon;
  final String title;
  final String category;
  final String description;
  final List<String> features;
  final String pricing;
  final String duration;
  final Color color;
  final String image;
  final List<Color> gradient;

  ServiceDetail({
    required this.icon,
    required this.title,
    required this.category,
    required this.description,
    required this.features,
    required this.pricing,
    required this.duration,
    required this.color,
    required this.image,
    required this.gradient,
  });
}