import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:itapp/ai-floating-chat-widget.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:itapp/customer_management.dart';
import 'package:itapp/firebase_initializer.dart';
import 'package:itapp/order_tracking.dart';
import 'package:itapp/product_catalog.dart';
import 'package:itapp/servicemanad.dart';
import 'package:itapp/shopping_cart.dart';
import 'package:itapp/unified_login.dart';
import 'package:itapp/user_dashboard.dart';
import 'package:itapp/user_profile.dart';
import 'common_appbar.dart';
import 'firebase_options.dart';

// Import all pages
import 'admindashbord.dart';
import 'servicepage.dart';
import 'contactpage.dart';
import 'paymentintregation.dart';
import 'ordermanagementadmin.dart';

// Import new components
import 'floating_chat_widget.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize database with sample data
  await FirebaseInitializer.initializeDatabase();
  await FirebaseInitializer.createSampleUsers();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppTech Vibe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => EnhancedLandingPage(),
        '/unified-login': (context) => UnifiedLoginPage(),
        '/admin': (context) => EnhancedAdminDashboard(),
        '/user-dashboard': (context) => EnhancedUserDashboard(),
        '/services': (context) => ServicesPage(),
        '/contact': (context) => ContactPage(),
        '/products': (context) => ProductCatalogPage(),
        '/cart': (context) => ShoppingCartPage(),
        '/profile': (context) => UserProfilePage(),
        '/customer-management': (context) => CustomerManagementPage(),
        '/order-management': (context) => OrderManagementPage(),
        '/product-management': (context) => ProductManagementPage(),
        '/services-management': (context) => ServicesManagementPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/payment') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => PaymentPage(orderDetails: args),
          );
        }
        if (settings.name == '/order-tracking') {
          final orderId = settings.arguments as String? ?? '';
          return MaterialPageRoute(
            builder: (context) => OrderTrackingPage(orderId: orderId),
          );
        }
        return null;
      },
    );
  }
}

// Animated Background Widget
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  
  const AnimatedBackground({Key? key, required this.child}) : super(key: key);
  
  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  
  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      5,
      (index) => AnimationController(
        duration: Duration(seconds: 10 + index * 2),
        vsync: this,
      ),
    );
    
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 2 * math.pi).animate(controller);
    }).toList();
    
    for (var controller in _controllers) {
      controller.repeat();
    }
  }
  
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A237E).withOpacity(0.05),
                Color(0xFF3949AB).withOpacity(0.05),
                Color(0xFF5C6BC0).withOpacity(0.05),
              ],
            ),
          ),
        ),
        // Animated Shapes
        ...List.generate(5, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Positioned(
                left: index * 200.0 + math.sin(_animations[index].value) * 50,
                top: index * 150.0 + math.cos(_animations[index].value) * 50,
                child: Transform.rotate(
                  angle: _animations[index].value,
                  child: Container(
                    width: 100 + index * 20.0,
                    height: 100 + index * 20.0,
                    decoration: BoxDecoration(
                      shape: index % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.03),
                          Colors.purple.withOpacity(0.03),
                        ],
                      ),
                      borderRadius: index % 2 == 0 ? null : BorderRadius.circular(20),
                    ),
                  ),
                ),
              );
            },
          );
        }),
        widget.child,
      ],
    );
  }
}

// Glassmorphism Card
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  
  const GlassmorphicCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.blur = 10,
    this.opacity = 0.1,
    this.borderRadius,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(opacity),
              borderRadius: borderRadius ?? BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// Enhanced Landing Page
class EnhancedLandingPage extends StatefulWidget {
  @override
  _EnhancedLandingPageState createState() => _EnhancedLandingPageState();
}

class _EnhancedLandingPageState extends State<EnhancedLandingPage> with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AnimationController _controller;
  late List<AnimationController> _cardControllers;
  late AnimationController _scrollController;
  late AnimationController _pulseController;
  ScrollController _pageScrollController = ScrollController();
  
  String selectedCategory = 'All';
  double _scrollOffset = 0.0;
  bool _showScrollToTop = false;
  
  // Stats for animated counters
  final List<Map<String, dynamic>> stats = [
    {'number': 500, 'suffix': '+', 'label': 'Happy Clients'},
    {'number': 50, 'suffix': '+', 'label': 'Projects Completed'},
    {'number': 24, 'suffix': '/7', 'label': 'Support Available'},
    {'number': 99, 'suffix': '%', 'label': 'Client Satisfaction'},
  ];
  
  final List<Service> services = [
    Service(
      icon: FontAwesomeIcons.mobileAlt,
      title: 'App Development',
      description: 'Native & Cross-platform mobile applications',
      color: Colors.blue,
      image: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400',
    ),
    Service(
      icon: FontAwesomeIcons.networkWired,
      title: 'Networking Solutions',
      description: 'Enterprise network setup and management',
      color: Colors.green,
      image: 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=400',
    ),
    Service(
      icon: FontAwesomeIcons.server,
      title: 'cPanel Maintenance',
      description: 'Server management and optimization',
      color: Colors.orange,
      image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
    ),
    Service(
      icon: FontAwesomeIcons.globe,
      title: 'Website Development',
      description: 'Responsive web design and maintenance',
      color: Colors.purple,
      image: 'https://images.unsplash.com/photo-1467232004584-a241de8bcf5d?w=400',
    ),
    Service(
      icon: FontAwesomeIcons.microchip,
      title: 'IoT Development',
      description: 'Smart device integration and automation',
      color: Colors.teal,
      image: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=400',
    ),
    Service(
      icon: FontAwesomeIcons.shieldAlt,
      title: 'Ethical Hacking',
      description: 'Security audits and penetration testing',
      color: Colors.red,
      image: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=400',
    ),
    Service(
      icon: FontAwesomeIcons.shoppingCart,
      title: 'E-commerce Solutions',
      description: 'Complete online store development',
      color: Colors.indigo,
      image: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400',
    ),
    Service(
      icon: FontAwesomeIcons.building,
      title: 'ERP Applications',
      description: 'Enterprise resource planning systems',
      color: Colors.brown,
      image: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=400',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _scrollController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _cardControllers = List.generate(
      services.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    
    _controller.forward();
    _animateCards();
    
    _pageScrollController.addListener(() {
      setState(() {
        _scrollOffset = _pageScrollController.offset;
        _showScrollToTop = _scrollOffset > 300;
      });
    });
  }

  void _animateCards() async {
    for (int i = 0; i < _cardControllers.length; i++) {
      await Future.delayed(Duration(milliseconds: 100));
      if (mounted) {
        _cardControllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    _pageScrollController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Responsive helper methods
  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  bool isTablet(BuildContext context) => MediaQuery.of(context).size.width < 1200 && MediaQuery.of(context).size.width >= 600;
  bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;

  double getResponsiveFontSize(BuildContext context, {required double mobile, required double tablet, required double desktop}) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return EdgeInsets.symmetric(horizontal: 20, vertical: 40);
    if (isTablet(context)) return EdgeInsets.symmetric(horizontal: 40, vertical: 60);
    return EdgeInsets.symmetric(horizontal: 80, vertical: 80);
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
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
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, 'Home', '/', context),
            _buildDrawerItem(Icons.shopping_bag, 'Shop', '/products', context, isHighlighted: true),
            _buildDrawerItem(Icons.design_services, 'Services', '/services', context),
            _buildDrawerItem(Icons.info, 'About', null, context),
            _buildDrawerItem(Icons.contact_mail, 'Contact', '/contact', context),
            Divider(),
            _buildDrawerItem(Icons.login, 'Login', '/unified-login', context, isSpecial: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, String? route, BuildContext context, {bool isHighlighted = false, bool isSpecial = false}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: isHighlighted ? Colors.orange.withOpacity(0.1) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isHighlighted ? Colors.orange : (isSpecial ? Colors.blue : Colors.grey.shade700),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted ? Colors.orange : (isSpecial ? Colors.blue : Colors.grey.shade700),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          if (route != null) {
            if (route == '/') {
              Navigator.pushReplacementNamed(context, route);
            } else {
              Navigator.pushNamed(context, route);
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: isMobile(context) ? _buildMobileDrawer() : null,
      appBar: CommonAppBar(
        type: AppBarType.home,
        backgroundColor: _scrollOffset > 50 ? Colors.white.withOpacity(0.95) : Colors.transparent,
      ),
      body: Stack(
        children: [
          AnimatedBackground(
            child: SingleChildScrollView(
              controller: _pageScrollController,
              child: Column(
                children: [
                  _buildEnhancedHeroSection(),
                  _buildFeaturedProducts(),
                  _buildEnhancedServicesSection(),
                  _buildPaymentSection(),
                  _buildTestimonialsSection(),
                   _buildStatsSection(context),
                  _buildFooter(),
                ],
              ),
            ),
          ),
          // Floating Chat Widget
         AIFloatingChatWidget(),
          // Scroll to Top Button
   
        ],
      ),
    );
  }

  Widget _buildEnhancedHeroSection() {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = isMobile(context) ? screenHeight * 0.9 : screenHeight * 0.8;
    
    return Container(
      height: heroHeight,
      child: Stack(
        children: [
          // Parallax Background
          Transform.translate(
            offset: Offset(0, _scrollOffset * 0.5),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3949AB).withOpacity(0.1),
                    Color(0xFF5C6BC0).withOpacity(0.1),
                    Color(0xFF7986CB).withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
          // Floating Elements
          ...List.generate(3, (index) {
            return Positioned(
              left: index * 200.0,
              top: 100 + index * 50.0 - (_scrollOffset * 0.3),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      math.sin(_pulseController.value * 2 * math.pi) * 20,
                      math.cos(_pulseController.value * 2 * math.pi) * 20,
                    ),
                    child: Container(
                      width: 80 + index * 20.0,
                      height: 80 + index * 20.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.blue.withOpacity(0.3),
                            Colors.purple.withOpacity(0.1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          // Content
          Center(
            child: FadeTransition(
              opacity: _controller,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _controller,
                        curve: Curves.elasticOut,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile(context) ? 15 : 20, 
                          vertical: isMobile(context) ? 8 : 10
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange, Colors.deepOrange],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_fire_department, color: Colors.white, size: 20),
                            SizedBox(width: 5),
                            Text(
                              '🔥 Special Launch Offer - Up to 75% OFF!',
                              style: TextStyle(
                                fontSize: getResponsiveFontSize(context, 
                                  mobile: 12, tablet: 14, desktop: 16),
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile(context) ? 20 : 30),
                    SizedBox(
                      height: isMobile(context) ? 60 : 80,
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: getResponsiveFontSize(context,
                            mobile: 28, tablet: 36, desktop: 48),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        child: AnimatedTextKit(
                          repeatForever: true,
                          animatedTexts: [
                            TypewriterAnimatedText('Innovative IT Solutions'),
                            TypewriterAnimatedText('Expert Consultation'),
                            TypewriterAnimatedText('Digital Transformation'),
                            TypewriterAnimatedText('Future-Ready Technology'),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _controller,
                        curve: Curves.easeOutCubic,
                      )),
                      child: Text(
                        'Transform your business with our comprehensive IT services',
                        style: TextStyle(
                          fontSize: getResponsiveFontSize(context,
                            mobile: 16, tablet: 18, desktop: 20),
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: isMobile(context) ? 30 : 40),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildHeroButton(
                          'Shop Now',
                          Icons.shopping_bag,
                          Colors.orange,
                          () => Navigator.pushNamed(context, '/products'),
                          true,
                        ),
                        _buildHeroButton(
                          'View Services',
                          Icons.design_services,
                          Colors.blue.shade700,
                          () => Navigator.pushNamed(context, '/services'),
                          false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroButton(String text, IconData icon, Color color, VoidCallback onPressed, bool filled) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _controller.value) * 50),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              child: filled
                  ? ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile(context) ? 30 : 40,
                          vertical: isMobile(context) ? 15 : 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon),
                          SizedBox(width: 10),
                          Text(
                            text,
                            style: TextStyle(
                              fontSize: isMobile(context) ? 16 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : OutlinedButton(
                      onPressed: onPressed,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: color, width: 2),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile(context) ? 30 : 40,
                          vertical: isMobile(context) ? 15 : 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: color),
                          SizedBox(width: 10),
                          Text(
                            text,
                            style: TextStyle(
                              fontSize: isMobile(context) ? 16 : 18,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

 

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return GlassmorphicCard(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: stat['number']),
            duration: Duration(seconds: 2),
            builder: (context, value, child) {
              return Text(
                '$value${stat['suffix']}',
                style: TextStyle(
                  fontSize: getResponsiveFontSize(context,
                    mobile: 24, tablet: 28, desktop: 32),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
          ),
          SizedBox(height: 5),
          Text(
            stat['label'],
            style: TextStyle(
              fontSize: getResponsiveFontSize(context,
                mobile: 12, tablet: 13, desktop: 14),
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProducts() {
    return Container(
      padding: getResponsivePadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade50,
            Colors.orange.shade100,
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.2),
                    child: Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 35,
                    ),
                  );
                },
              ),
              SizedBox(width: 10),
              Text(
                'Hot Deals',
                style: TextStyle(
                  fontSize: getResponsiveFontSize(context,
                    mobile: 32, tablet: 36, desktop: 40),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Limited time offers on our most popular products',
            style: TextStyle(
              fontSize: getResponsiveFontSize(context,
                mobile: 16, tablet: 17, desktop: 18),
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile(context) ? 30 : 40),
          
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('products')
                .where('isPopular', isEqualTo: true)
                .limit(3)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                );
              }
              
              final products = snapshot.data!.docs;
              
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: products.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildEnhancedProductCard(data);
                  }).toList(),
                ),
              );
            },
          ),
          SizedBox(height: 30),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/products'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View All Products',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(width: 5),
                Icon(Icons.arrow_forward, color: Colors.orange, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedProductCard(Map<String, dynamic> data) {
    return Container(
      width: isMobile(context) ? 280 : 320,
      margin: EdgeInsets.only(right: 20),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          transform: Matrix4.identity()..scale(1.0),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(data['image'] ?? ''),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Gradient Overlay
                          Container(
                            height: 200,
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
                          if (data['discount'] != null)
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.red, Colors.red.shade700],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${data['discount']}% OFF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          if (data['badge'] != null)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _getBadgeColor(data['badgeColor']),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getBadgeColor(data['badgeColor']).withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  data['badge'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'] ?? '',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  "\$${data['price']}",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(width: 10),
                                if (data['originalPrice'] != null)
                                  Text(
                                    "\$${data['originalPrice']}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade500,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pushNamed(context, '/products'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 5,
                                ),
                                child: Text(
                                  'View Details',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBadgeColor(String? color) {
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

  Widget _buildEnhancedServicesSection() {
    return Container(
      padding: getResponsivePadding(context),
      child: Column(
        children: [
          Text(
            'Our Services',
            style: TextStyle(
              fontSize: getResponsiveFontSize(context,
                mobile: 32, tablet: 36, desktop: 40),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Comprehensive IT solutions tailored for your business needs',
            style: TextStyle(
              fontSize: getResponsiveFontSize(context,
                mobile: 16, tablet: 17, desktop: 18),
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile(context) ? 40 : 60),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile(context) ? 1 : 
                              isTablet(context) ? 2 : 4,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: isMobile(context) ? 1.5 : 1.2,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return _buildEnhancedServiceCard(services[index], index);
            },
          ),
        ],
      ),
    );
  }

Widget _buildStatsSection(BuildContext context) {
  return Container(
    width: double.infinity,
    padding: getResponsivePadding(context),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.indigo.shade900.withOpacity(0.95),
          Colors.blueAccent.shade700.withOpacity(0.85),
        ],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '🌟 Our Achievements',
          style: TextStyle(
            fontSize: getResponsiveFontSize(context,
              mobile: 26, tablet: 30, desktop: 36),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 30),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile(context) ? 2 : 4,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.3,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final statMap = stats[index];
            final stat = Stat(
              icon: FontAwesomeIcons.award, // Replace with appropriate icon if available in statMap
              value: '${statMap['number']}${statMap['suffix']}',
              label: statMap['label'],
            );
            return _buildGlassmorphicStatCard(stat);
          },
        ),
      ],
    ),
  );
}

Widget _buildGlassmorphicStatCard(Stat stat) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(stat.icon, size: 40, color: Colors.white),
            SizedBox(height: 12),
            Text(
              stat.value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              stat.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildEnhancedServiceCard(Service service, int index) {
    return AnimatedBuilder(
      animation: _cardControllers[index],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _cardControllers[index].value) * 50),
          child: Opacity(
            opacity: _cardControllers[index].value,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey.shade50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: service.color.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, '/services'),
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_pulseController.value * 0.1),
                            child: Container(
                              padding: EdgeInsets.all(isMobile(context) ? 15 : 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    service.color.withOpacity(0.2),
                                    service.color.withOpacity(0.1),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                service.icon,
                                size: isMobile(context) ? 30 : 40,
                                color: service.color,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: isMobile(context) ? 15 : 20),
                      Text(
                        service.title,
                        style: TextStyle(
                          fontSize: isMobile(context) ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isMobile(context) ? 15 : 20),
                        child: Text(
                          service.description,
                          style: TextStyle(
                            fontSize: isMobile(context) ? 12 : 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentSection() {
    final paymentMethods = [
      {'name': 'bKash', 'color': Colors.pink, 'icon': FontAwesomeIcons.mobileAlt},
      {'name': 'Nagad', 'color': Colors.orange, 'icon': FontAwesomeIcons.wallet},
      {'name': 'Google Pay', 'color': Colors.blue, 'icon': FontAwesomeIcons.google},
      {'name': 'Stripe', 'color': Colors.purple, 'icon': FontAwesomeIcons.stripe},
    ];

    return Container(
      padding: getResponsivePadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade100,
            Colors.grey.shade200,
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Secure Payment Options',
            style: TextStyle(
              fontSize: getResponsiveFontSize(context,
                mobile: 32, tablet: 36, desktop: 40),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            'Multiple payment gateways for your convenience',
            style: TextStyle(
              fontSize: getResponsiveFontSize(context,
                mobile: 16, tablet: 17, desktop: 18),
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile(context) ? 40 : 60),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: paymentMethods.map((method) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.all(isMobile(context) ? 25 : 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (method['color'] as Color).withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        method['icon'] as IconData,
                        size: isMobile(context) ? 40 : 50,
                        color: method['color'] as Color,
                      ),
                      SizedBox(height: 10),
                      Text(
                        method['name'] as String,
                        style: TextStyle(
                          fontSize: isMobile(context) ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection() {
    final testimonials = [
      {
        'name': 'John Doe',
        'company': 'Tech Corp',
        'image': 'https://i.pravatar.cc/150?img=1',
        'text': 'Excellent service! They transformed our entire IT infrastructure.',
        'rating': 5,
      },
      {
        'name': 'Jane Smith',
        'company': 'StartUp Inc',
        'image': 'https://i.pravatar.cc/150?img=2',
        'text': 'Professional team with innovative solutions. Highly recommended!',
        'rating': 5,
      },
      {
        'name': 'Mike Johnson',
        'company': 'Enterprise Ltd',
        'image': 'https://i.pravatar.cc/150?img=3',
        'text': 'Their IoT solutions helped us automate our entire workflow.',
        'rating': 5,
      },
    ];

    return Container(
      padding: getResponsivePadding(context),
      child: Column(
        children: [
          Text(
            'What Our Clients Say',
            style: TextStyle(
              fontSize: getResponsiveFontSize(context,
                mobile: 32, tablet: 36, desktop: 40),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile(context) ? 40 : 60),
          CarouselSlider(
            options: CarouselOptions(
              height: isMobile(context) ? 400 : 350,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 5),
              enlargeCenterPage: true,
              viewportFraction: isMobile(context) ? 0.9 : 0.5,
            ),
            items: testimonials.map((testimonial) {
              return GlassmorphicCard(
                margin: EdgeInsets.symmetric(horizontal: 10),
                padding: EdgeInsets.all(isMobile(context) ? 20 : 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: isMobile(context) ? 40 : 50,
                        backgroundImage: NetworkImage(testimonial['image'] as String),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          color: index < (testimonial['rating'] as int) ? Colors.amber : Colors.grey.shade300,
                          size: 20,
                        );
                      }),
                    ),
                    SizedBox(height: 15),
                    Text(
                      testimonial['text'] as String,
                      style: TextStyle(
                        fontSize: isMobile(context) ? 14 : 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      testimonial['name'] as String,
                      style: TextStyle(
                        fontSize: isMobile(context) ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      testimonial['company'] as String,
                      style: TextStyle(
                        fontSize: isMobile(context) ? 12 : 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile(context) ? 40 : 60, 
        horizontal: 20
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade900,
            Colors.black87,
          ],
        ),
      ),
      child: Column(
        children: [
          if (isMobile(context))
            Column(
              children: [
                Column(
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
                    SizedBox(height: 20),
                    Text(
                      'Your trusted partner in digital transformation',
                      style: TextStyle(color: Colors.grey.shade400),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialIcon(FontAwesomeIcons.facebook, Colors.blue),
                        SizedBox(width: 15),
                        _buildSocialIcon(FontAwesomeIcons.twitter, Colors.lightBlue),
                        SizedBox(width: 15),
                        _buildSocialIcon(FontAwesomeIcons.linkedin, Colors.blueAccent),
                        SizedBox(width: 15),
                        _buildSocialIcon(FontAwesomeIcons.instagram, Colors.pink),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 40),
                _buildFooterSection('Services', [
                  'App Development',
                  'Web Development',
                  'IoT Solutions',
                  'Security Services',
                ]),
                SizedBox(height: 40),
                _buildFooterSection('Contact', [
                  'info@apptechvibe.com',
                  '+880 1234567890',
                  'Dhaka, Bangladesh',
                ]),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.code, color: Colors.white, size: 30),
                        SizedBox(width: 10),
                        Text(
                          'AppTech Vibe',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Your trusted partner in digital transformation',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        _buildSocialIcon(FontAwesomeIcons.facebook, Colors.blue),
                        SizedBox(width: 15),
                        _buildSocialIcon(FontAwesomeIcons.twitter, Colors.lightBlue),
                        SizedBox(width: 15),
                        _buildSocialIcon(FontAwesomeIcons.linkedin, Colors.blueAccent),
                        SizedBox(width: 15),
                        _buildSocialIcon(FontAwesomeIcons.instagram, Colors.pink),
                      ],
                    ),
                  ],
                ),
                _buildFooterSection('Services', [
                  'App Development',
                  'Web Development',
                  'IoT Solutions',
                  'Security Services',
                ]),
                _buildFooterSection('Quick Links', [
                  'About Us',
                  'Our Team',
                  'Portfolio',
                  'Careers',
                ]),
                _buildFooterSection('Contact', [
                  'info@apptechvibe.com',
                  '+880 1234567890',
                  'Dhaka, Bangladesh',
                ]),
              ],
            ),
          SizedBox(height: 40),
          Divider(color: Colors.grey.shade700),
          SizedBox(height: 20),
          Text(
            '© 2024 AppTech Vibe. All rights reserved.',
            style: TextStyle(color: Colors.grey.shade400, fontSize: isMobile(context) ? 12 : 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15),
        ...items.map((item) => Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Text(
            item,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }
}

class Service {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String image;

  Service({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.image,
  });
}

class Stat {
  final IconData icon;
  final String value;
  final String label;

  Stat({
    required this.icon,
    required this.value,
    required this.label,
  });
}