import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:itapp/ai-floating-chat-widget.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:itapp/customer_management.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:itapp/firebase_initializer.dart';
import 'package:itapp/order_tracking.dart';
import 'package:itapp/privacy_policy_page.dart';
import 'package:itapp/product_catalog.dart';
import 'package:itapp/servicemanad.dart';
import 'package:itapp/shared_widgets.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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
        '/privacy-policy': (context) => PrivacyPolicyPage(),
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

class EnhancedLandingPage extends StatefulWidget {
  @override
  _EnhancedLandingPageState createState() => _EnhancedLandingPageState();
}

class _EnhancedLandingPageState extends State<EnhancedLandingPage> with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AnimationController _controller;
  late AnimationController _marqueeController;
  late Animation<double> _marqueeAnimation;
  ScrollController _pageScrollController = ScrollController();
  
  String selectedCategory = 'All';
  double _scrollOffset = 0.0;
  bool _showScrollToTop = false;
  bool _chatAutoOpened = false;
  
  // Cached data
  String? _cachedProfileImageUrl;
  bool _isLoadingProfile = true;
  
  final List<String> announcements = [
    "🔥 MEGA SALE: 75% OFF on all premium services!",
    "🚀 New AI-powered solutions now available",
    "💡 Free consultation for enterprise clients",
    "⚡ 24/7 support with 99.9% uptime guarantee",
  ];
  
  final List<Map<String, dynamic>> stats = [
    {'number': 5, 'suffix': '+', 'label': 'Happy Clients', 'icon': FontAwesomeIcons.users},
    {'number': 40, 'suffix': '+', 'label': 'Projects Completed', 'icon': FontAwesomeIcons.projectDiagram},
    {'number': 24, 'suffix': '/7', 'label': 'Support Available', 'icon': FontAwesomeIcons.headset},
    {'number': 99, 'suffix': '%', 'label': 'Client Satisfaction', 'icon': FontAwesomeIcons.star},
  ];
  
  final List<Service> services = [
    Service(
      icon: FontAwesomeIcons.mobileAlt,
      title: 'App Development',
      description: 'Native & Cross-platform mobile applications',
      color: Colors.blue,
    ),
    Service(
      icon: FontAwesomeIcons.networkWired,
      title: 'Networking Solutions',
      description: 'Enterprise network setup and management',
      color: Colors.green,
    ),
    Service(
      icon: FontAwesomeIcons.server,
      title: 'cPanel Maintenance',
      description: 'Server management and optimization',
      color: Colors.orange,
    ),
    Service(
      icon: FontAwesomeIcons.globe,
      title: 'Website Development',
      description: 'Responsive web design and maintenance',
      color: Colors.purple,
    ),
    Service(
      icon: FontAwesomeIcons.microchip,
      title: 'IoT Development',
      description: 'Smart device integration and automation',
      color: Colors.teal,
    ),
    Service(
      icon: FontAwesomeIcons.shieldAlt,
      title: 'Ethical Hacking',
      description: 'Security audits and penetration testing',
      color: Colors.red,
    ),
    Service(
      icon: FontAwesomeIcons.shoppingCart,
      title: 'E-commerce Solutions',
      description: 'Complete online store development',
      color: Colors.indigo,
    ),
    Service(
      icon: FontAwesomeIcons.building,
      title: 'ERP Applications',
      description: 'Enterprise resource planning systems',
      color: Colors.brown,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _marqueeController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _marqueeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _marqueeController,
      curve: Curves.linear,
    ));
    
    _controller.forward();
    
    _pageScrollController.addListener(() {
      setState(() {
        _scrollOffset = _pageScrollController.offset;
        _showScrollToTop = _scrollOffset > 300;
      });
    });
    
    // Load profile image
    _loadProfileImage();
    
    // Auto-open chat after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (mounted && !_chatAutoOpened) {
        setState(() {
          _chatAutoOpened = true;
        });
      }
    });
  }

  Future<void> _loadProfileImage() async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('profile/pp.png');
      final url = await storageRef.getDownloadURL();
      if (mounted) {
        setState(() {
          _cachedProfileImageUrl = url;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      print('Error loading profile image: $e');
      if (mounted) {
        setState(() {
          _cachedProfileImageUrl = 'https://firebasestorage.googleapis.com/v0/b/itsolution-93657.firebasestorage.app/o/profile%2Fpp.png?alt=media&token=c5df34cc-7634-4920-80f1-0d58173badd1';
          _isLoadingProfile = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _marqueeController.dispose();
    _pageScrollController.dispose();
    super.dispose();
  }

  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  bool isTablet(BuildContext context) => MediaQuery.of(context).size.width < 1200 && MediaQuery.of(context).size.width >= 600;
  bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;

  double getResponsiveFontSize(BuildContext context, {required double mobile, required double tablet, required double desktop}) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  EdgeInsets getResponsivePadding(BuildContext context, {bool compact = false}) {
    final multiplier = compact ? 0.5 : 1.0;
    if (isMobile(context)) return EdgeInsets.symmetric(horizontal: 20, vertical: (35 * multiplier));
    if (isTablet(context)) return EdgeInsets.symmetric(horizontal: 40, vertical: (45 * multiplier));
    return EdgeInsets.symmetric(horizontal: 80, vertical: (55 * multiplier));
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
            _buildDrawerItem(Icons.info, 'Policy', '/privacy-policy', context),
            _buildDrawerItem(Icons.contact_mail, 'Contact', '/contact', context),
            Divider(),
            _buildDrawerItem(Icons.login, 'Login', null, context, isSpecial: true, isLogin: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, String? route, BuildContext context, {bool isHighlighted = false, bool isSpecial = false, bool isLogin = false}) {
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
          if (isLogin) {
            LoginPopupModal.show(context);
          } else if (route != null) {
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
                  _buildMarqueeBar(),
                  _buildEnhancedHeroSection(),
                  _buildProfileSection(),
                  _buildHireMeSection(),
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
          AIFloatingChatWidget(autoOpen: _chatAutoOpened),
        //  if (_showScrollToTop)
            // Positioned(
            //   right: 20,
            //   bottom: 80,
            //   child: FloatingActionButton(
            //     onPressed: () {
            //       _pageScrollController.animateTo(
            //         0,
            //         duration: Duration(milliseconds: 500),
            //         curve: Curves.easeInOut,
            //       );
            //     },
            //     backgroundColor: Colors.blue,
            //     child: Icon(Icons.arrow_upward, color: Colors.white),
            //   ),
            // ),
        ],
      ),
    );
  }

  Widget _buildMarqueeBar() {
    return RepaintBoundary(
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRect(
          child: AnimatedBuilder(
            animation: _marqueeAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    left: _getMarqueePosition(),
                    child: Row(
                      children: [
                        ...announcements.map((announcement) => _buildMarqueeItem(announcement)).toList(),
                        ...announcements.map((announcement) => _buildMarqueeItem(announcement)).toList(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMarqueeItem(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 80),
      child: Row(
        children: [
          Icon(Icons.campaign, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  double _getMarqueePosition() {
    final screenWidth = MediaQuery.of(context).size.width;
    final totalWidth = announcements.length * 400.0 * 2;
    return -((_marqueeAnimation.value * totalWidth) % totalWidth) + screenWidth;
  }

  Widget _buildEnhancedHeroSection() {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = isMobile(context) ? screenHeight * 0.85 : screenHeight * 0.75;
    
    return RepaintBoundary(
      child: Container(
        height: heroHeight,
        child: Stack(
          children: [
            // Simplified background - removed floating particles for performance
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.withOpacity(0.05),
                    Colors.purple.withOpacity(0.05),
                  ],
                ),
              ),
            ),
            
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
                            horizontal: isMobile(context) ? 25 : 35, 
                            vertical: isMobile(context) ? 15 : 18
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFF6B6B),
                                Color(0xFFFF8E53),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_fire_department, 
                                  color: Colors.white, size: 26),
                              SizedBox(width: 12),
                              Text(
                                '🔥 ULTIMATE SALE - UP TO 75% OFF!',
                                style: TextStyle(
                                  fontSize: getResponsiveFontSize(context, 
                                    mobile: 14, tablet: 16, desktop: 18),
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 40),
                      
                      Container(
                        height: isMobile(context) ? 85 : 110,
                        child: DefaultTextStyle(
                          style: TextStyle(
                            fontSize: getResponsiveFontSize(context,
                              mobile: 34, tablet: 44, desktop: 58),
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                            height: 1.1,
                          ),
                          child: AnimatedTextKit(
                            repeatForever: true,
                            pause: Duration(milliseconds: 1200),
                            animatedTexts: [
                              TypewriterAnimatedText(
                                'Revolutionary IT Solutions',
                                textStyle: TextStyle(
                                  foreground: Paint()
                                    ..shader = LinearGradient(
                                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                                ),
                              ),
                              TypewriterAnimatedText(
                                'Future-Ready Technology',
                                textStyle: TextStyle(
                                  foreground: Paint()
                                    ..shader = LinearGradient(
                                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                                    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                                ),
                              ),
                              TypewriterAnimatedText(
                                'Digital Transformation',
                                textStyle: TextStyle(
                                  foreground: Paint()
                                    ..shader = LinearGradient(
                                      colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                                    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 30),
                      
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, 1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _controller,
                          curve: Curves.easeOutCubic,
                        )),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Elevate your business with cutting-edge technology solutions designed for tomorrow\'s challenges',
                            style: TextStyle(
                              fontSize: getResponsiveFontSize(context,
                                mobile: 18, tablet: 21, desktop: 24),
                              color: Colors.grey.shade600,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 50),
                      
                      Wrap(
                        spacing: 25,
                        runSpacing: 25,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildEnhancedHeroButton(
                            'Explore Products',
                            Icons.rocket_launch,
                            [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                            () => Navigator.pushNamed(context, '/products'),
                            true,
                          ),
                          _buildEnhancedHeroButton(
                            'Our Services',
                            Icons.stars,
                            [Color(0xFF667EEA), Color(0xFF764BA2)],
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
      ),
    );
  }

  Widget _buildEnhancedHeroButton(String text, IconData icon, List<Color> colors, VoidCallback onPressed, bool filled) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: filled
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile(context) ? 40 : 50,
                      vertical: isMobile(context) ? 20 : 25,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 22),
                      SizedBox(width: 12),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: isMobile(context) ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors[0], width: 2.5),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile(context) ? 40 : 50,
                    vertical: isMobile(context) ? 20 : 25,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: colors[0], size: 22),
                    SizedBox(width: 12),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: isMobile(context) ? 16 : 18,
                        color: colors[0],
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: getResponsivePadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA).withOpacity(0.05),
            Color(0xFF764BA2).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildSectionHeader(
            '👨‍💼 About the Founder',
            'Leading innovation in IT and system reliability',
            Colors.indigo,
          ),
          
          SizedBox(height: 50),
          
          if (_isLoadingProfile)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (isMobile(context)) {
                  return _buildMobileProfileCard();
                } else {
                  return _buildDesktopProfileCard();
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMobileProfileCard() {
    return RepaintBoundary(
      child: GlassmorphicCard(
        padding: EdgeInsets.all(30),
        gradientColors: [
          Colors.white.withOpacity(0.95),
          Colors.indigo.withOpacity(0.05),
        ],
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF667EEA),
                    Color(0xFF764BA2),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              padding: EdgeInsets.all(5),
              child: CircleAvatar(
                radius: 80,
                backgroundImage: _cachedProfileImageUrl != null 
                    ? CachedNetworkImageProvider(_cachedProfileImageUrl!)
                    : null,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            
            SizedBox(height: 25),
            
            Text(
              'Kobir Hosan',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            
            SizedBox(height: 10),
            
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Site Reliability Engineer',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            
            SizedBox(height: 25),
            
            Text(
              '5+ years of experience in IT infrastructure, cloud services, and enterprise security. Passionate about building scalable solutions and driving digital transformation.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 30),
            
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _buildSkillTag('Azure', Colors.blue),
                _buildSkillTag('AWS', Colors.orange),
                _buildSkillTag('M365', Colors.purple),
                _buildSkillTag('PowerShell', Colors.teal),
                _buildSkillTag('Flutter', Colors.cyan),
                _buildSkillTag('IoT', Colors.green),
                // _buildSkillTag('Docker', Colors.blueAccent),
                _buildSkillTag('Linux', Colors.indigo),
              ],
            ),
            
            SizedBox(height: 35),
            
            _buildDownloadCVButton(),
            
            SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildContactIcon(
                  FontAwesomeIcons.envelope,
                  'mailto:kobirit.bappy@gmail.com',
                  Colors.red,
                ),
                SizedBox(width: 20),
                _buildContactIcon(
                  FontAwesomeIcons.linkedin,
                  'https://www.linkedin.com/in/kobir-hosan-102880137/',
                  Colors.blue,
                ),
                SizedBox(width: 20),
                _buildContactIcon(
                  FontAwesomeIcons.github,
                  'https://github.com/KobirBappy?tab=repositories',
                  Colors.grey.shade800,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopProfileCard() {
    return RepaintBoundary(
      child: GlassmorphicCard(
        padding: EdgeInsets.all(50),
        gradientColors: [
          Colors.white.withOpacity(0.95),
          Colors.indigo.withOpacity(0.05),
        ],
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF667EEA),
                          Color(0xFF764BA2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(8),
                    child: CircleAvatar(
                      radius: 120,
                      backgroundImage: _cachedProfileImageUrl != null 
                          ? CachedNetworkImageProvider(_cachedProfileImageUrl!)
                          : null,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildContactIcon(
                        FontAwesomeIcons.envelope,
                        'mailto:kobirit.bappy@gmail.com',
                        Colors.red,
                      ),
                      SizedBox(width: 25),
                      _buildContactIcon(
                        FontAwesomeIcons.linkedin,
                        'https://www.linkedin.com/in/kobir-hosan-102880137/',
                        Colors.blue,
                      ),
                      SizedBox(width: 25),
                      _buildContactIcon(
                        FontAwesomeIcons.github,
                        'https://github.com/KobirBappy?tab=repositories',
                        Colors.grey.shade800,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(width: 60),
            
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kobir Hosan',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  
                  SizedBox(height: 15),
                  
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'Site Reliability Engineer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  Text(
                    '5+ years of experience in IT infrastructure, cloud services, and enterprise security. Skilled in managing site operations, Microsoft 365, Active Directory/Azure AD, and endpoint lifecycle.',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey.shade600,
                      height: 1.7,
                    ),
                  ),
                  
                  SizedBox(height: 25),
                  
                  Text(
                    'Passionate about ensuring system resilience, strengthening cybersecurity, and driving automation to reduce operational overhead and improve service delivery.',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey.shade600,
                      height: 1.7,
                    ),
                  ),
                  
                  SizedBox(height: 35),
                  
                  Text(
                    'Expertise:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  
                  SizedBox(height: 15),
                  
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildSkillTag('Azure', Colors.blue),
                      _buildSkillTag('AWS', Colors.orange),
                      _buildSkillTag('Microsoft 365', Colors.purple),
                      _buildSkillTag('PowerShell', Colors.teal),
                      _buildSkillTag('Flutter', Colors.cyan),
                      _buildSkillTag('IoT', Colors.green),
                      _buildSkillTag('Docker', Colors.blueAccent),
                      _buildSkillTag('Linux', Colors.indigo),
                    ],
                  ),
                  
                  SizedBox(height: 40),
                  
                  _buildDownloadCVButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillTag(String skill, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Text(
        skill,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildContactIcon(IconData icon, String url, Color color) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadCVButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _downloadCV(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.4),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => _downloadCV(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 35,
                vertical: 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FontAwesomeIcons.download, size: 18),
                SizedBox(width: 12),
                Text(
                  'Download CV',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadCV() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white, 
                  strokeWidth: 2
                ),
              ),
              SizedBox(width: 15),
              Text('Preparing CV download...'),
            ],
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.indigo,
        ),
      );

      // Get download URL from Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('cv/Kobir Hosan - SRE CV, 5 years.pdf');
      final downloadUrl = await storageRef.getDownloadURL();
      
      final uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 15),
                  Text('CV download started!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('CV Download Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 15),
                Expanded(
                  child: Text('Failed to download CV: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Widget _buildHireMeSection() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      padding: getResponsivePadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            FontAwesomeIcons.briefcase,
            color: Colors.white,
            size: 60,
          ),
          
          SizedBox(height: 25),
          
          Text(
            '🚀 Want to Hire Me?',
            style: TextStyle(
              fontSize: getResponsiveFontSize(context,
                mobile: 30, tablet: 36, desktop: 42),
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 20),
          
          Text(
            'Looking for a reliable Site Reliability Engineer to strengthen your team?\nLet\'s discuss how I can help your organization.',
            style: TextStyle(
              fontSize: getResponsiveFontSize(context,
                mobile: 16, tablet: 18, desktop: 20),
              color: Colors.white.withOpacity(0.9),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 35),
          
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildHireMeButton(
                'Contact Me',
                FontAwesomeIcons.envelope,
                () => Navigator.pushNamed(context, '/contact'),
              ),
              _buildHireMeButton(
                'View Projects',
                FontAwesomeIcons.github,
                () async {
                  final uri = Uri.parse('https://github.com/KobirBappy?tab=repositories');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              _buildHireMeButton(
                'LinkedIn',
                FontAwesomeIcons.linkedin,
                () async {
                  final uri = Uri.parse('https://www.linkedin.com/in/kobir-hosan-102880137/');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHireMeButton(String text, IconData icon, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile(context) ? 25 : 30,
            vertical: isMobile(context) ? 15 : 18,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Color(0xFF667EEA),
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontSize: isMobile(context) ? 15 : 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667EEA),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedProducts() {
    return Container(
      padding: getResponsivePadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.orange.shade50,
            Colors.orange.shade100.withOpacity(0.3),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildSectionHeader(
            '🔥 Hot Deals',
            'Limited time offers on our most popular products',
            Colors.orange,
          ),
          
          SizedBox(height: 40),
          
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
          
          SizedBox(height: 35),
          
          _buildViewAllButton('View All Products', '/products', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(Icons.local_fire_department, color: color, size: 38),
            ),
            SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: getResponsiveFontSize(context,
                  mobile: 30, tablet: 34, desktop: 38),
                fontWeight: FontWeight.w900,
                color: Colors.grey.shade800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 18),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: getResponsiveFontSize(context,
              mobile: 16, tablet: 18, desktop: 20),
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildViewAllButton(String text, String route, Color color) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), Colors.white.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedProductCard(Map<String, dynamic> data) {
    return RepaintBoundary(
      child: Container(
        width: isMobile(context) ? 290 : 330,
        margin: EdgeInsets.only(right: 25),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GlassmorphicCard(
            padding: EdgeInsets.zero,
            gradientColors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                        child: CachedNetworkImage(
                          imageUrl: data['image'] ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade300,
                            child: Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
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
                        top: 15,
                        left: 15,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.4),
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
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    if (data['badge'] != null)
                      Positioned(
                        top: 15,
                        right: 15,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getBadgeColor(data['badgeColor']),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: _getBadgeColor(data['badgeColor']).withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Text(
                            data['badge'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? '',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            "\$${data['price']}",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(width: 12),
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
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange, Colors.deepOrange],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/products'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            child: Text(
                              'View Details',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
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
      ),
    );
  }

  Color _getBadgeColor(String? color) {
    switch (color) {
      case 'orange': return Colors.orange;
      case 'blue': return Colors.blue;
      case 'red': return Colors.red;
      case 'green': return Colors.green;
      case 'purple': return Colors.purple;
      case 'indigo': return Colors.indigo;
      default: return Colors.grey;
    }
  }

  Widget _buildEnhancedServicesSection() {
    return Container(
      padding: getResponsivePadding(context),
      child: Column(
        children: [
          _buildSectionHeader(
            'Our Services',
            'Comprehensive IT solutions tailored for your business needs',
            Colors.blue,
          ),
          
          SizedBox(height: 50),
          
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile(context) ? 1 : 
                              isTablet(context) ? 2 : 4,
              crossAxisSpacing: 25,
              mainAxisSpacing: 25,
              childAspectRatio: isMobile(context) ? 1.5 : 1.2,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return _buildEnhancedServiceCard(services[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedServiceCard(Service service) {
    return RepaintBoundary(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GlassmorphicCard(
          padding: EdgeInsets.all(25),
          gradientColors: [
            Colors.white.withOpacity(0.9),
            service.color.withOpacity(0.05),
          ],
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/services'),
            borderRadius: BorderRadius.circular(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        service.color.withOpacity(0.2),
                        service.color.withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: service.color.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    service.icon,
                    size: isMobile(context) ? 35 : 40,
                    color: service.color,
                  ),
                ),
                SizedBox(height: 22),
                Text(
                  service.title,
                  style: TextStyle(
                    fontSize: isMobile(context) ? 17 : 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  service.description,
                  style: TextStyle(
                    fontSize: isMobile(context) ? 14 : 15,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
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
            Colors.grey.shade50,
            Colors.grey.shade100,
          ],
        ),
      ),
      child: Column(
        children: [
          _buildSectionHeader(
            'Secure Payment Options',
            'Multiple payment gateways for your convenience',
            Colors.green,
          ),
          
          SizedBox(height: 50),
          
          Wrap(
            spacing: 25,
            runSpacing: 25,
            alignment: WrapAlignment.center,
            children: paymentMethods.map((method) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GlassmorphicCard(
                  padding: EdgeInsets.all(30),
                  gradientColors: [
                    Colors.white,
                    (method['color'] as Color).withOpacity(0.05),
                  ],
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              (method['color'] as Color).withOpacity(0.2),
                              (method['color'] as Color).withOpacity(0.05),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          method['icon'] as IconData,
                          size: isMobile(context) ? 40 : 45,
                          color: method['color'] as Color,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        method['name'] as String,
                        style: TextStyle(
                          fontSize: isMobile(context) ? 15 : 16,
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
        'text': 'Excellent service! They transformed our entire IT infrastructure with cutting-edge solutions.',
        'rating': 5,
      },
      {
        'name': 'Jane Smith',
        'company': 'StartUp Inc',
        'image': 'https://i.pravatar.cc/150?img=2',
        'text': 'Professional team with innovative solutions. Highly recommended for any tech challenges!',
        'rating': 5,
      },
      {
        'name': 'Mike Johnson',
        'company': 'Enterprise Ltd',
        'image': 'https://i.pravatar.cc/150?img=3',
        'text': 'Their IoT solutions helped us automate our entire workflow. Amazing results!',
        'rating': 5,
      },
    ];

    return Container(
      padding: getResponsivePadding(context, compact: true),
      child: Column(
        children: [
          _buildSectionHeader(
            '💬 What Our Clients Say',
            'Real feedback from our satisfied customers',
            Colors.purple,
          ),
          
          SizedBox(height: 35),
          
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 4),
              enlargeCenterPage: true,
              viewportFraction: isMobile(context) ? 0.9 : 0.5,
              enableInfiniteScroll: true,
              height: isMobile(context) ? 320 : 350,
            ),
            items: testimonials.map((testimonial) {
              return RepaintBoundary(
                child: GlassmorphicCard(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  padding: EdgeInsets.all(25),
                  gradientColors: [
                    Colors.white.withOpacity(0.9),
                    Colors.purple.withOpacity(0.05),
                  ],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.purple.withOpacity(0.2),
                              Colors.purple.withOpacity(0.05),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: isMobile(context) ? 35 : 40,
                          backgroundImage: CachedNetworkImageProvider(
                            testimonial['image'] as String,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Icon(
                            Icons.star,
                            color: index < (testimonial['rating'] as int)
                                ? Colors.amber
                                : Colors.grey.shade300,
                            size: 22,
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
                          height: 1.5,
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
                      SizedBox(height: 5),
                      Text(
                        testimonial['company'] as String,
                        style: TextStyle(
                          fontSize: isMobile(context) ? 12 : 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
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

  Widget _buildStatsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: getResponsivePadding(context, compact: true),
      margin: EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '🏆 Our Achievements',
            style: TextStyle(
              fontSize: getResponsiveFontSize(context,
                mobile: 30, tablet: 34, desktop: 38),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 15),
          Text(
            'Numbers that speak for our excellence',
            style: TextStyle(
              fontSize: getResponsiveFontSize(context,
                mobile: 16, tablet: 18, desktop: 20),
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 35),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile(context) ? 2 : 4,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.2,
            ),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final statMap = stats[index];
              return _buildGlassmorphicStatCard(statMap);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphicStatCard(Map<String, dynamic> statMap) {
    return RepaintBoundary(
      child: GlassmorphicCard(
        padding: EdgeInsets.all(20),
        gradientColors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.1),
        ],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                statMap['icon'] as IconData,
                size: 35,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 15),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: statMap['number']),
              duration: Duration(seconds: 2),
              builder: (context, value, child) {
                return Text(
                  '$value${statMap['suffix']}',
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(context,
                      mobile: 26, tablet: 30, desktop: 34),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),
            SizedBox(height: 8),
            Text(
              statMap['label'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: getResponsiveFontSize(context,
                  mobile: 13, tablet: 14, desktop: 15),
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
                        // SizedBox(width: 15),
                        // _buildSocialIcon(FontAwesomeIcons.instagram, Colors.pink),
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
                  'kobirit.bappy@gmail.com',
                  '+880 1727507239',
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
                        // SizedBox(width: 15),
                        // _buildSocialIcon(FontAwesomeIcons.instagram, Colors.pink),
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
                  'kobirit.bappy@gmail.com',
                  '+880 1727507239',
                  'Dhaka, Bangladesh',
                ]),
              ],
            ),
          SizedBox(height: 40),
          Divider(color: Colors.grey.shade700),
          SizedBox(height: 20),
          Text(
            '© ${DateTime.now().year} AppTech Vibe. All rights reserved.',
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

  Service({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}