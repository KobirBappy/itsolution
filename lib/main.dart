// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:itapp/ai-floating-chat-widget.dart';
// import 'dart:math' as math;
// import 'dart:ui';
// import 'package:itapp/customer_management.dart';
// import 'package:itapp/firebase_initializer.dart';
// import 'package:itapp/order_tracking.dart';
// import 'package:itapp/product_catalog.dart';
// import 'package:itapp/servicemanad.dart';
// import 'package:itapp/shopping_cart.dart';
// import 'package:itapp/unified_login.dart';
// import 'package:itapp/user_dashboard.dart';
// import 'package:itapp/user_profile.dart';
// import 'common_appbar.dart';
// import 'firebase_options.dart';

// // Import all pages
// import 'admindashbord.dart';
// import 'servicepage.dart';
// import 'contactpage.dart';
// import 'paymentintregation.dart';
// import 'ordermanagementadmin.dart';


// // Import new components
// import 'floating_chat_widget.dart';


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
  
//   // Initialize database with sample data
//   await FirebaseInitializer.initializeDatabase();
//   await FirebaseInitializer.createSampleUsers();
  
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'AppTech Vibe',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         fontFamily: 'Poppins',
//         useMaterial3: true,
//       ),
//       debugShowCheckedModeBanner: false,
//       initialRoute: '/',
//       routes: {
//         '/': (context) => EnhancedLandingPage(),
//         // Removed '/unified-login' route since we're using popup now
//         '/admin': (context) => EnhancedAdminDashboard(),
//         '/user-dashboard': (context) => EnhancedUserDashboard(),
//         '/services': (context) => ServicesPage(),
//         '/contact': (context) => ContactPage(),
//         '/products': (context) => ProductCatalogPage(),
//         '/cart': (context) => ShoppingCartPage(),
//         '/profile': (context) => UserProfilePage(),
//         '/customer-management': (context) => CustomerManagementPage(),
//         '/order-management': (context) => OrderManagementPage(),
//         '/product-management': (context) => ProductManagementPage(),
//         '/services-management': (context) => ServicesManagementPage(),
//       },
//       onGenerateRoute: (settings) {
//         if (settings.name == '/payment') {
//           final args = settings.arguments as Map<String, dynamic>? ?? {};
//           return MaterialPageRoute(
//             builder: (context) => PaymentPage(orderDetails: args),
//           );
//         }
//         if (settings.name == '/order-tracking') {
//           final orderId = settings.arguments as String? ?? '';
//           return MaterialPageRoute(
//             builder: (context) => OrderTrackingPage(orderId: orderId),
//           );
//         }
//         return null;
//       },
//     );
//   }
// }

// // Animated Background Widget
// class AnimatedBackground extends StatefulWidget {
//   final Widget child;
  
//   const AnimatedBackground({Key? key, required this.child}) : super(key: key);
  
//   @override
//   _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
// }

// class _AnimatedBackgroundState extends State<AnimatedBackground> with TickerProviderStateMixin {
//   late List<AnimationController> _controllers;
//   late List<Animation<double>> _animations;
  
//   @override
//   void initState() {
//     super.initState();
//     _controllers = List.generate(
//       6,
//       (index) => AnimationController(
//         duration: Duration(seconds: 8 + index * 2),
//         vsync: this,
//       ),
//     );
    
//     _animations = _controllers.map((controller) {
//       return Tween<double>(begin: 0, end: 2 * math.pi).animate(controller);
//     }).toList();
    
//     for (var controller in _controllers) {
//       controller.repeat();
//     }
//   }
  
//   @override
//   void dispose() {
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // Enhanced Gradient Background
//         Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Color(0xFFF8FAFC),
//                 Color(0xFFE2E8F0),
//                 Color(0xFFF1F5F9),
//               ],
//             ),
//           ),
//         ),
//         // Floating Tech Icons
//         ...List.generate(6, (index) {
//           final icons = [
//             FontAwesomeIcons.code,
//             FontAwesomeIcons.mobile,
//             FontAwesomeIcons.server,
//             FontAwesomeIcons.shield,
//             FontAwesomeIcons.globe,
//             FontAwesomeIcons.microchip,
//           ];
          
//           return AnimatedBuilder(
//             animation: _animations[index],
//             builder: (context, child) {
//               return Positioned(
//                 left: (index * 180.0) % MediaQuery.of(context).size.width + 
//                       math.sin(_animations[index].value) * 60,
//                 top: 80 + index * 120.0 + math.cos(_animations[index].value) * 40,
//                 child: Opacity(
//                   opacity: 0.08,
//                   child: Transform.rotate(
//                     angle: _animations[index].value * 0.5,
//                     child: Icon(
//                       icons[index],
//                       size: 80 + (index * 15.0),
//                       color: [
//                         Colors.blue,
//                         Colors.purple,
//                         Colors.orange,
//                         Colors.teal,
//                         Colors.indigo,
//                         Colors.red
//                       ][index].withOpacity(0.4),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         }),
//         widget.child,
//       ],
//     );
//   }
// }

// // Enhanced Glassmorphism Card
// class GlassmorphicCard extends StatelessWidget {
//   final Widget child;
//   final double? width;
//   final double? height;
//   final EdgeInsets? padding;
//   final EdgeInsets? margin;
//   final double blur;
//   final double opacity;
//   final BorderRadius? borderRadius;
//   final List<Color>? gradientColors;
  
//   const GlassmorphicCard({
//     Key? key,
//     required this.child,
//     this.width,
//     this.height,
//     this.padding,
//     this.margin,
//     this.blur = 15,
//     this.opacity = 0.1,
//     this.borderRadius,
//     this.gradientColors,
//   }) : super(key: key);
  
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: width,
//       height: height,
//       margin: margin,
//       child: ClipRRect(
//         borderRadius: borderRadius ?? BorderRadius.circular(25),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
//           child: Container(
//             padding: padding,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: gradientColors ?? [
//                   Colors.white.withOpacity(opacity),
//                   Colors.white.withOpacity(opacity * 0.8),
//                 ],
//               ),
//               borderRadius: borderRadius ?? BorderRadius.circular(25),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 1.5,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 20,
//                   spreadRadius: 0,
//                   offset: Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: child,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Enhanced Landing Page
// class EnhancedLandingPage extends StatefulWidget {
//   @override
//   _EnhancedLandingPageState createState() => _EnhancedLandingPageState();
// }

// class _EnhancedLandingPageState extends State<EnhancedLandingPage> with TickerProviderStateMixin {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late AnimationController _controller;
//   late List<AnimationController> _cardControllers;
//   late AnimationController _scrollController;
//   late AnimationController _pulseController;
//   late AnimationController _marqueeController;
//   late Animation<double> _marqueeAnimation;
//   late AnimationController _floatingController;
//   ScrollController _pageScrollController = ScrollController();
  
//   String selectedCategory = 'All';
//   double _scrollOffset = 0.0;
//   bool _showScrollToTop = false;
  
//   // Marquee announcements
//   final List<String> announcements = [
//     "🔥 MEGA SALE: 75% OFF on all premium services!",
//     "🚀 New AI-powered solutions now available",
//     "💡 Free consultation for enterprise clients",
//     "⚡ 24/7 support with 99.9% uptime guarantee",
//     "🎯 Custom solutions starting from \$99",
//     "🌟 Award-winning development team",
//   ];
  
//   // Stats for animated counters
//   final List<Map<String, dynamic>> stats = [
//     {'number': 500, 'suffix': '+', 'label': 'Happy Clients', 'icon': FontAwesomeIcons.users},
//     {'number': 50, 'suffix': '+', 'label': 'Projects Completed', 'icon': FontAwesomeIcons.projectDiagram},
//     {'number': 24, 'suffix': '/7', 'label': 'Support Available', 'icon': FontAwesomeIcons.headset},
//     {'number': 99, 'suffix': '%', 'label': 'Client Satisfaction', 'icon': FontAwesomeIcons.star},
//   ];
  
//   final List<Service> services = [
//     Service(
//       icon: FontAwesomeIcons.mobileAlt,
//       title: 'App Development',
//       description: 'Native & Cross-platform mobile applications',
//       color: Colors.blue,
//       image: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400',
//     ),
//     Service(
//       icon: FontAwesomeIcons.networkWired,
//       title: 'Networking Solutions',
//       description: 'Enterprise network setup and management',
//       color: Colors.green,
//       image: 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=400',
//     ),
//     Service(
//       icon: FontAwesomeIcons.server,
//       title: 'cPanel Maintenance',
//       description: 'Server management and optimization',
//       color: Colors.orange,
//       image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
//     ),
//     Service(
//       icon: FontAwesomeIcons.globe,
//       title: 'Website Development',
//       description: 'Responsive web design and maintenance',
//       color: Colors.purple,
//       image: 'https://images.unsplash.com/photo-1467232004584-a241de8bcf5d?w=400',
//     ),
//     Service(
//       icon: FontAwesomeIcons.microchip,
//       title: 'IoT Development',
//       description: 'Smart device integration and automation',
//       color: Colors.teal,
//       image: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=400',
//     ),
//     Service(
//       icon: FontAwesomeIcons.shieldAlt,
//       title: 'Ethical Hacking',
//       description: 'Security audits and penetration testing',
//       color: Colors.red,
//       image: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=400',
//     ),
//     Service(
//       icon: FontAwesomeIcons.shoppingCart,
//       title: 'E-commerce Solutions',
//       description: 'Complete online store development',
//       color: Colors.indigo,
//       image: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400',
//     ),
//     Service(
//       icon: FontAwesomeIcons.building,
//       title: 'ERP Applications',
//       description: 'Enterprise resource planning systems',
//       color: Colors.brown,
//       image: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=400',
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: Duration(seconds: 2),
//       vsync: this,
//     );
    
//     _scrollController = AnimationController(
//       duration: Duration(milliseconds: 500),
//       vsync: this,
//     );
    
//     _pulseController = AnimationController(
//       duration: Duration(seconds: 3),
//       vsync: this,
//     )..repeat(reverse: true);
    
//     // Marquee animation
//     _marqueeController = AnimationController(
//       duration: Duration(seconds: 25),
//       vsync: this,
//     )..repeat();
    
//     _marqueeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _marqueeController,
//       curve: Curves.linear,
//     ));
    
//     // Floating animation
//     _floatingController = AnimationController(
//       duration: Duration(seconds: 4),
//       vsync: this,
//     )..repeat(reverse: true);
    
//     _cardControllers = List.generate(
//       services.length,
//       (index) => AnimationController(
//         duration: Duration(milliseconds: 600),
//         vsync: this,
//       ),
//     );
    
//     _controller.forward();
//     _animateCards();
    
//     _pageScrollController.addListener(() {
//       setState(() {
//         _scrollOffset = _pageScrollController.offset;
//         _showScrollToTop = _scrollOffset > 300;
//       });
//     });
//   }

//   void _animateCards() async {
//     for (int i = 0; i < _cardControllers.length; i++) {
//       await Future.delayed(Duration(milliseconds: 100));
//       if (mounted) {
//         _cardControllers[i].forward();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     _pulseController.dispose();
//     _marqueeController.dispose();
//     _floatingController.dispose();
//     _pageScrollController.dispose();
//     for (var controller in _cardControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   // Responsive helper methods
//   bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
//   bool isTablet(BuildContext context) => MediaQuery.of(context).size.width < 1200 && MediaQuery.of(context).size.width >= 600;
//   bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;

//   double getResponsiveFontSize(BuildContext context, {required double mobile, required double tablet, required double desktop}) {
//     if (isMobile(context)) return mobile;
//     if (isTablet(context)) return tablet;
//     return desktop;
//   }

//   EdgeInsets getResponsivePadding(BuildContext context, {bool compact = false}) {
//     final multiplier = compact ? 0.5 : 1.0;
//     if (isMobile(context)) return EdgeInsets.symmetric(horizontal: 20, vertical: (35 * multiplier));
//     if (isTablet(context)) return EdgeInsets.symmetric(horizontal: 40, vertical: (45 * multiplier));
//     return EdgeInsets.symmetric(horizontal: 80, vertical: (55 * multiplier));
//   }

//   Widget _buildMobileDrawer() {
//     return Drawer(
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.blue.shade50,
//               Colors.white,
//             ],
//           ),
//         ),
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.blue.shade700, Colors.blue.shade500],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Icon(FontAwesomeIcons.code, color: Colors.white, size: 40),
//                   SizedBox(height: 10),
//                   Text(
//                     'AppTech Vibe',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             _buildDrawerItem(Icons.home, 'Home', '/', context),
//             _buildDrawerItem(Icons.shopping_bag, 'Shop', '/products', context, isHighlighted: true),
//             _buildDrawerItem(Icons.design_services, 'Services', '/services', context),
//             _buildDrawerItem(Icons.info, 'About', null, context),
//             _buildDrawerItem(Icons.contact_mail, 'Contact', '/contact', context),
//             Divider(),
//             _buildDrawerItem(Icons.login, 'Login', null, context, isSpecial: true, isLogin: true),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDrawerItem(IconData icon, String title, String? route, BuildContext context, {bool isHighlighted = false, bool isSpecial = false, bool isLogin = false}) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         color: isHighlighted ? Colors.orange.withOpacity(0.1) : null,
//       ),
//       child: ListTile(
//         leading: Icon(
//           icon,
//           color: isHighlighted ? Colors.orange : (isSpecial ? Colors.blue : Colors.grey.shade700),
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
//             color: isHighlighted ? Colors.orange : (isSpecial ? Colors.blue : Colors.grey.shade700),
//           ),
//         ),
//         onTap: () {
//           Navigator.pop(context);
//           if (isLogin) {
//             // Show login popup instead of navigating
//             LoginPopupModal.show(context);
//           } else if (route != null) {
//             if (route == '/') {
//               Navigator.pushReplacementNamed(context, route);
//             } else {
//               Navigator.pushNamed(context, route);
//             }
//           }
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       endDrawer: isMobile(context) ? _buildMobileDrawer() : null,
//       appBar: CommonAppBar(
//         type: AppBarType.home,
//         backgroundColor: _scrollOffset > 50 ? Colors.white.withOpacity(0.95) : Colors.transparent,
//       ),
//       body: Stack(
//         children: [
//           AnimatedBackground(
//             child: SingleChildScrollView(
//               controller: _pageScrollController,
//               child: Column(
//                 children: [
//                   _buildMarqueeBar(),
//                   _buildEnhancedHeroSection(),
//                   _buildFeaturedProducts(),
//                   _buildEnhancedServicesSection(),
//                   _buildPaymentSection(),
//                   _buildTestimonialsSection(),
//                   _buildStatsSection(context),
//                   _buildFooter(),
//                 ],
//               ),
//             ),
//           ),
//           // Floating Chat Widget
//           AIFloatingChatWidget(),
//           // Scroll to Top Button
        
//         ],
//       ),
//     );
//   }

//   Widget _buildMarqueeBar() {
//     return Container(
//       height: 55,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Color(0xFF667EEA),
//             Color(0xFF764BA2),
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.purple.withOpacity(0.4),
//             blurRadius: 20,
//             offset: Offset(0, 8),
//           ),
//         ],
//       ),
//       child: ClipRect(
//         child: AnimatedBuilder(
//           animation: _marqueeAnimation,
//           builder: (context, child) {
//             return Stack(
//               children: [
//                 Positioned(
//                   left: _getMarqueePosition(),
//                   child: Row(
//                     children: [
//                       // First set
//                       ...announcements.map((announcement) => _buildMarqueeItem(announcement)).toList(),
//                       // Duplicate for seamless loop
//                       ...announcements.map((announcement) => _buildMarqueeItem(announcement)).toList(),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildMarqueeItem(String text) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 80),
//       child: Row(
//         children: [
//           AnimatedBuilder(
//             animation: _pulseController,
//             builder: (context, child) {
//               return Transform.scale(
//                 scale: 1.0 + (_pulseController.value * 0.2),
//                 child: Icon(Icons.campaign, color: Colors.white, size: 22),
//               );
//             },
//           ),
//           SizedBox(width: 12),
//           Text(
//             text,
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.w600,
//               fontSize: 15,
//               letterSpacing: 0.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   double _getMarqueePosition() {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final totalWidth = announcements.length * 400.0 * 2; // Approximate width
//     return -((_marqueeAnimation.value * totalWidth) % totalWidth) + screenWidth;
//   }

//   Widget _buildEnhancedHeroSection() {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final heroHeight = isMobile(context) ? screenHeight * 0.85 : screenHeight * 0.75;
    
//     return Container(
//       height: heroHeight,
//       child: Stack(
//         children: [
//           // Enhanced Background with animated orbs
//           ...List.generate(5, (index) {
//             return AnimatedBuilder(
//               animation: _floatingController,
//               builder: (context, child) {
//                 return Positioned(
//                   left: (index * 220.0) + (_floatingController.value * 80),
//                   top: 120 + (index * 60.0) + (math.sin(_floatingController.value * 2 * math.pi + index) * 40),
//                   child: Container(
//                     width: 140 - (index * 25.0),
//                     height: 140 - (index * 25.0),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: RadialGradient(
//                         colors: [
//                           [Colors.blue, Colors.purple, Colors.orange, Colors.teal, Colors.pink][index].withOpacity(0.15),
//                           [Colors.blue, Colors.purple, Colors.orange, Colors.teal, Colors.pink][index].withOpacity(0.05),
//                         ],
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: [Colors.blue, Colors.purple, Colors.orange, Colors.teal, Colors.pink][index].withOpacity(0.3),
//                           blurRadius: 40,
//                           spreadRadius: 10,
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           }),
          
//           // Main Content
//           Center(
//             child: FadeTransition(
//               opacity: _controller,
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 20),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Enhanced Offer Badge
//                     ScaleTransition(
//                       scale: CurvedAnimation(
//                         parent: _controller,
//                         curve: Curves.elasticOut,
//                       ),
//                       child: Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: isMobile(context) ? 25 : 35, 
//                           vertical: isMobile(context) ? 15 : 18
//                         ),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               Color(0xFFFF6B6B),
//                               Color(0xFFFF8E53),
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(50),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.orange.withOpacity(0.6),
//                               blurRadius: 30,
//                               spreadRadius: 5,
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             AnimatedBuilder(
//                               animation: _pulseController,
//                               builder: (context, child) {
//                                 return Transform.scale(
//                                   scale: 1.0 + (_pulseController.value * 0.3),
//                                   child: Icon(Icons.local_fire_department, 
//                                       color: Colors.white, size: 26),
//                                 );
//                               },
//                             ),
//                             SizedBox(width: 12),
//                             Text(
//                               '🔥 ULTIMATE SALE - UP TO 75% OFF!',
//                               style: TextStyle(
//                                 fontSize: getResponsiveFontSize(context, 
//                                   mobile: 14, tablet: 16, desktop: 18),
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 letterSpacing: 1.2,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
                    
//                     SizedBox(height: 40),
                    
//                     // Enhanced Animated Title
//                     Container(
//                       height: isMobile(context) ? 85 : 110,
//                       child: DefaultTextStyle(
//                         style: TextStyle(
//                           fontSize: getResponsiveFontSize(context,
//                             mobile: 34, tablet: 44, desktop: 58),
//                           fontWeight: FontWeight.w900,
//                           letterSpacing: -1.5,
//                           height: 1.1,
//                         ),
//                         child: AnimatedTextKit(
//                           repeatForever: true,
//                           pause: Duration(milliseconds: 1200),
//                           animatedTexts: [
//                             TypewriterAnimatedText(
//                               'Revolutionary IT Solutions',
//                               textStyle: TextStyle(
//                                 foreground: Paint()
//                                   ..shader = LinearGradient(
//                                     colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                                   ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
//                               ),
//                             ),
//                             TypewriterAnimatedText(
//                               'Future-Ready Technology',
//                               textStyle: TextStyle(
//                                 foreground: Paint()
//                                   ..shader = LinearGradient(
//                                     colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
//                                   ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
//                               ),
//                             ),
//                             TypewriterAnimatedText(
//                               'Digital Transformation',
//                               textStyle: TextStyle(
//                                 foreground: Paint()
//                                   ..shader = LinearGradient(
//                                     colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
//                                   ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
                    
//                     SizedBox(height: 30),
                    
//                     // Enhanced Subtitle
//                     SlideTransition(
//                       position: Tween<Offset>(
//                         begin: Offset(0, 1),
//                         end: Offset.zero,
//                       ).animate(CurvedAnimation(
//                         parent: _controller,
//                         curve: Curves.easeOutCubic,
//                       )),
//                       child: Container(
//                         padding: EdgeInsets.symmetric(horizontal: 20),
//                         child: Text(
//                           'Elevate your business with cutting-edge technology solutions designed for tomorrow\'s challenges',
//                           style: TextStyle(
//                             fontSize: getResponsiveFontSize(context,
//                               mobile: 18, tablet: 21, desktop: 24),
//                             color: Colors.grey.shade600,
//                             height: 1.6,
//                             fontWeight: FontWeight.w500,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
                    
//                     SizedBox(height: 50),
                    
//                     // Enhanced CTA Buttons
//                     Wrap(
//                       spacing: 25,
//                       runSpacing: 25,
//                       alignment: WrapAlignment.center,
//                       children: [
//                         _buildEnhancedHeroButton(
//                           'Explore Products',
//                           Icons.rocket_launch,
//                           [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
//                           () => Navigator.pushNamed(context, '/products'),
//                           true,
//                         ),
//                         _buildEnhancedHeroButton(
//                           'Our Services',
//                           Icons.stars,
//                           [Color(0xFF667EEA), Color(0xFF764BA2)],
//                           () => Navigator.pushNamed(context, '/services'),
//                           false,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEnhancedHeroButton(String text, IconData icon, List<Color> colors, VoidCallback onPressed, bool filled) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(0, (1 - _controller.value) * 50),
//           child: MouseRegion(
//             cursor: SystemMouseCursors.click,
//             child: AnimatedContainer(
//               duration: Duration(milliseconds: 300),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(50),
//                 boxShadow: [
//                   BoxShadow(
//                     color: colors[0].withOpacity(0.4),
//                     blurRadius: 25,
//                     spreadRadius: 3,
//                     offset: Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: filled
//                   ? Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(colors: colors),
//                         borderRadius: BorderRadius.circular(50),
//                       ),
//                       child: ElevatedButton(
//                         onPressed: onPressed,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.transparent,
//                           foregroundColor: Colors.white,
//                           padding: EdgeInsets.symmetric(
//                             horizontal: isMobile(context) ? 40 : 50,
//                             vertical: isMobile(context) ? 20 : 25,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(50),
//                           ),
//                           elevation: 0,
//                           shadowColor: Colors.transparent,
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(icon, size: 22),
//                             SizedBox(width: 12),
//                             Text(
//                               text,
//                               style: TextStyle(
//                                 fontSize: isMobile(context) ? 16 : 18,
//                                 fontWeight: FontWeight.bold,
//                                 letterSpacing: 0.5,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                   : OutlinedButton(
//                       onPressed: onPressed,
//                       style: OutlinedButton.styleFrom(
//                         side: BorderSide(color: colors[0], width: 2.5),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: isMobile(context) ? 40 : 50,
//                           vertical: isMobile(context) ? 20 : 25,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(50),
//                         ),
//                         backgroundColor: Colors.white.withOpacity(0.1),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(icon, color: colors[0], size: 22),
//                           SizedBox(width: 12),
//                           Text(
//                             text,
//                             style: TextStyle(
//                               fontSize: isMobile(context) ? 16 : 18,
//                               color: colors[0],
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 0.5,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFeaturedProducts() {
//     return Container(
//       padding: getResponsivePadding(context),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.orange.shade50,
//             Colors.orange.shade100.withOpacity(0.3),
//           ],
//         ),
//       ),
//       child: Column(
//         children: [
//           // Enhanced Section Header
//           _buildSectionHeader(
//             '🔥 Hot Deals',
//             'Limited time offers on our most popular products',
//             Colors.orange,
//           ),
          
//           SizedBox(height: 40),
          
//           StreamBuilder<QuerySnapshot>(
//             stream: _firestore
//                 .collection('products')
//                 .where('isPopular', isEqualTo: true)
//                 .limit(3)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                 return Center(
//                   child: CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
//                   ),
//                 );
//               }
              
//               final products = snapshot.data!.docs;
              
//               return SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: products.map((doc) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     return _buildEnhancedProductCard(data);
//                   }).toList(),
//                 ),
//               );
//             },
//           ),
          
//           SizedBox(height: 35),
          
//           _buildViewAllButton('View All Products', '/products', Colors.orange),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title, String subtitle, Color color) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             AnimatedBuilder(
//               animation: _pulseController,
//               builder: (context, child) {
//                 return Transform.scale(
//                   scale: 1.0 + (_pulseController.value * 0.2),
//                   child: Container(
//                     padding: EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       gradient: RadialGradient(
//                         colors: [
//                           color.withOpacity(0.3),
//                           color.withOpacity(0.1),
//                         ],
//                       ),
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: color.withOpacity(0.4),
//                           blurRadius: 20,
//                           spreadRadius: 5,
//                         ),
//                       ],
//                     ),
//                     child: Icon(Icons.local_fire_department, color: color, size: 38),
//                   ),
//                 );
//               },
//             ),
//             SizedBox(width: 15),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: getResponsiveFontSize(context,
//                   mobile: 30, tablet: 34, desktop: 38),
//                 fontWeight: FontWeight.w900,
//                 color: Colors.grey.shade800,
//                 letterSpacing: -0.5,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 18),
//         Text(
//           subtitle,
//           style: TextStyle(
//             fontSize: getResponsiveFontSize(context,
//               mobile: 16, tablet: 18, desktop: 20),
//             color: Colors.grey.shade600,
//             fontWeight: FontWeight.w500,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildViewAllButton(String text, String route, Color color) {
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       child: GestureDetector(
//         onTap: () => Navigator.pushNamed(context, route),
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [color.withOpacity(0.1), Colors.white.withOpacity(0.1)],
//             ),
//             borderRadius: BorderRadius.circular(35),
//             border: Border.all(color: color.withOpacity(0.3), width: 2),
//             boxShadow: [
//               BoxShadow(
//                 color: color.withOpacity(0.2),
//                 blurRadius: 15,
//                 offset: Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 text,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: color,
//                 ),
//               ),
//               SizedBox(width: 10),
//               Icon(Icons.arrow_forward, color: color, size: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEnhancedProductCard(Map<String, dynamic> data) {
//     return Container(
//       width: isMobile(context) ? 290 : 330,
//       margin: EdgeInsets.only(right: 25),
//       child: MouseRegion(
//         cursor: SystemMouseCursors.click,
//         child: GlassmorphicCard(
//           padding: EdgeInsets.zero,
//           gradientColors: [
//             Colors.white.withOpacity(0.9),
//             Colors.white.withOpacity(0.7),
//           ],
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Stack(
//                 children: [
//                   Container(
//                     height: 220,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//                       image: DecorationImage(
//                         image: NetworkImage(data['image'] ?? ''),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     height: 220,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.transparent,
//                           Colors.black.withOpacity(0.4),
//                         ],
//                       ),
//                     ),
//                   ),
//                   if (data['discount'] != null)
//                     Positioned(
//                       top: 15,
//                       left: 15,
//                       child: Container(
//                         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
//                           ),
//                           borderRadius: BorderRadius.circular(30),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.red.withOpacity(0.6),
//                               blurRadius: 15,
//                               spreadRadius: 2,
//                             ),
//                           ],
//                         ),
//                         child: Text(
//                           '${data['discount']}% OFF',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                       ),
//                     ),
//                   if (data['badge'] != null)
//                     Positioned(
//                       top: 15,
//                       right: 15,
//                       child: Container(
//                         padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: _getBadgeColor(data['badgeColor']),
//                           borderRadius: BorderRadius.circular(20),
//                           boxShadow: [
//                             BoxShadow(
//                               color: _getBadgeColor(data['badgeColor']).withOpacity(0.5),
//                               blurRadius: 10,
//                               spreadRadius: 1,
//                             ),
//                           ],
//                         ),
//                         child: Text(
//                           data['badge'],
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 11,
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               Padding(
//                 padding: EdgeInsets.all(25),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       data['name'] ?? '',
//                       style: TextStyle(
//                         fontSize: 19,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey.shade800,
//                       ),
//                     ),
//                     SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Text(
//                           "\$${data['price']}",
//                           style: TextStyle(
//                             fontSize: 26,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.green,
//                           ),
//                         ),
//                         SizedBox(width: 12),
//                         if (data['originalPrice'] != null)
//                           Text(
//                             "\$${data['originalPrice']}",
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey.shade500,
//                               decoration: TextDecoration.lineThrough,
//                             ),
//                           ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     SizedBox(
//                       width: double.infinity,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [Colors.orange, Colors.deepOrange],
//                           ),
//                           borderRadius: BorderRadius.circular(18),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.orange.withOpacity(0.4),
//                               blurRadius: 15,
//                               offset: Offset(0, 8),
//                             ),
//                           ],
//                         ),
//                         child: ElevatedButton(
//                           onPressed: () => Navigator.pushNamed(context, '/products'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.transparent,
//                             foregroundColor: Colors.white,
//                             padding: EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(18),
//                             ),
//                             elevation: 0,
//                             shadowColor: Colors.transparent,
//                           ),
//                           child: Text(
//                             'View Details',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getBadgeColor(String? color) {
//     switch (color) {
//       case 'orange': return Colors.orange;
//       case 'blue': return Colors.blue;
//       case 'red': return Colors.red;
//       case 'green': return Colors.green;
//       case 'purple': return Colors.purple;
//       case 'indigo': return Colors.indigo;
//       default: return Colors.grey;
//     }
//   }

//   Widget _buildEnhancedServicesSection() {
//     return Container(
//       padding: getResponsivePadding(context),
//       child: Column(
//         children: [
//           _buildSectionHeader(
//             'Our Services',
//             'Comprehensive IT solutions tailored for your business needs',
//             Colors.blue,
//           ),
          
//           SizedBox(height: 50),
          
//           GridView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: isMobile(context) ? 1 : 
//                               isTablet(context) ? 2 : 4,
//               crossAxisSpacing: 25,
//               mainAxisSpacing: 25,
//               childAspectRatio: isMobile(context) ? 1.5 : 1.2,
//             ),
//             itemCount: services.length,
//             itemBuilder: (context, index) {
//               return _buildEnhancedServiceCard(services[index], index);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEnhancedServiceCard(Service service, int index) {
//     return AnimatedBuilder(
//       animation: _cardControllers[index],
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(0, (1 - _cardControllers[index].value) * 50),
//           child: Opacity(
//             opacity: _cardControllers[index].value,
//             child: MouseRegion(
//               cursor: SystemMouseCursors.click,
//               child: GlassmorphicCard(
//                 padding: EdgeInsets.all(25),
//                 gradientColors: [
//                   Colors.white.withOpacity(0.9),
//                   service.color.withOpacity(0.05),
//                 ],
//                 child: InkWell(
//                   onTap: () => Navigator.pushNamed(context, '/services'),
//                   borderRadius: BorderRadius.circular(25),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       AnimatedBuilder(
//                         animation: _pulseController,
//                         builder: (context, child) {
//                           return Transform.scale(
//                             scale: 1.0 + (_pulseController.value * 0.1),
//                             child: Container(
//                               padding: EdgeInsets.all(20),
//                               decoration: BoxDecoration(
//                                 gradient: RadialGradient(
//                                   colors: [
//                                     service.color.withOpacity(0.2),
//                                     service.color.withOpacity(0.05),
//                                   ],
//                                 ),
//                                 shape: BoxShape.circle,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: service.color.withOpacity(0.3),
//                                     blurRadius: 20,
//                                     spreadRadius: 5,
//                                   ),
//                                 ],
//                               ),
//                               child: Icon(
//                                 service.icon,
//                                 size: isMobile(context) ? 35 : 40,
//                                 color: service.color,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       SizedBox(height: 22),
//                       Text(
//                         service.title,
//                         style: TextStyle(
//                           fontSize: isMobile(context) ? 17 : 19,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       SizedBox(height: 12),
//                       Text(
//                         service.description,
//                         style: TextStyle(
//                           fontSize: isMobile(context) ? 14 : 15,
//                           color: Colors.grey.shade600,
//                           height: 1.4,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildPaymentSection() {
//     final paymentMethods = [
//       {'name': 'bKash', 'color': Colors.pink, 'icon': FontAwesomeIcons.mobileAlt},
//       {'name': 'Nagad', 'color': Colors.orange, 'icon': FontAwesomeIcons.wallet},
//       {'name': 'Google Pay', 'color': Colors.blue, 'icon': FontAwesomeIcons.google},
//       {'name': 'Stripe', 'color': Colors.purple, 'icon': FontAwesomeIcons.stripe},
//     ];

//     return Container(
//       padding: getResponsivePadding(context),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.grey.shade50,
//             Colors.grey.shade100,
//           ],
//         ),
//       ),
//       child: Column(
//         children: [
//           _buildSectionHeader(
//             'Secure Payment Options',
//             'Multiple payment gateways for your convenience',
//             Colors.green,
//           ),
          
//           SizedBox(height: 50),
          
//           Wrap(
//             spacing: 25,
//             runSpacing: 25,
//             alignment: WrapAlignment.center,
//             children: paymentMethods.map((method) {
//               return MouseRegion(
//                 cursor: SystemMouseCursors.click,
//                 child: GlassmorphicCard(
//                   padding: EdgeInsets.all(30),
//                   gradientColors: [
//                     Colors.white,
//                     (method['color'] as Color).withOpacity(0.05),
//                   ],
//                   child: Column(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(15),
//                         decoration: BoxDecoration(
//                           gradient: RadialGradient(
//                             colors: [
//                               (method['color'] as Color).withOpacity(0.2),
//                               (method['color'] as Color).withOpacity(0.05),
//                             ],
//                           ),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           method['icon'] as IconData,
//                           size: isMobile(context) ? 40 : 45,
//                           color: method['color'] as Color,
//                         ),
//                       ),
//                       SizedBox(height: 15),
//                       Text(
//                         method['name'] as String,
//                         style: TextStyle(
//                           fontSize: isMobile(context) ? 15 : 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.grey.shade800,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTestimonialsSection() {
//     final testimonials = [
//       {
//         'name': 'John Doe',
//         'company': 'Tech Corp',
//         'image': 'https://i.pravatar.cc/150?img=1',
//         'text': 'Excellent service! They transformed our entire IT infrastructure with cutting-edge solutions.',
//         'rating': 5,
//       },
//       {
//         'name': 'Jane Smith',
//         'company': 'StartUp Inc',
//         'image': 'https://i.pravatar.cc/150?img=2',
//         'text': 'Professional team with innovative solutions. Highly recommended for any tech challenges!',
//         'rating': 5,
//       },
//       {
//         'name': 'Mike Johnson',
//         'company': 'Enterprise Ltd',
//         'image': 'https://i.pravatar.cc/150?img=3',
//         'text': 'Their IoT solutions helped us automate our entire workflow. Amazing results!',
//         'rating': 5,
//       },
//     ];

//     return Container(
//       padding: getResponsivePadding(context, compact: true), // Reduced padding
//       child: Column(
//         children: [
//           _buildSectionHeader(
//             '💬 What Our Clients Say',
//             'Real feedback from our satisfied customers',
//             Colors.purple,
//           ),
          
//           SizedBox(height: 35), // Reduced spacing
          
//           CarouselSlider(
//             options: CarouselOptions(
//               autoPlay: true,
//               autoPlayInterval: Duration(seconds: 4),
//               enlargeCenterPage: true,
//               viewportFraction: isMobile(context) ? 0.9 : 0.5,
//               enableInfiniteScroll: true,
//               height: isMobile(context) ? 320 : 350,
//             ),
//             items: testimonials.map((testimonial) {
//               return GlassmorphicCard(
//                 margin: EdgeInsets.symmetric(horizontal: 10),
//                 padding: EdgeInsets.all(25),
//                 gradientColors: [
//                   Colors.white.withOpacity(0.9),
//                   Colors.purple.withOpacity(0.05),
//                 ],
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient: RadialGradient(
//                           colors: [
//                             Colors.purple.withOpacity(0.3),
//                             Colors.purple.withOpacity(0.1),
//                           ],
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.purple.withOpacity(0.4),
//                             blurRadius: 20,
//                             spreadRadius: 5,
//                           ),
//                         ],
//                       ),
//                       child: CircleAvatar(
//                         radius: isMobile(context) ? 35 : 40,
//                         backgroundImage: NetworkImage(testimonial['image'] as String),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: List.generate(5, (index) {
//                         return Icon(
//                           Icons.star,
//                           color: index < (testimonial['rating'] as int)
//                               ? Colors.amber
//                               : Colors.grey.shade300,
//                           size: 22,
//                         );
//                       }),
//                     ),
//                     SizedBox(height: 15),
//                     Text(
//                       testimonial['text'] as String,
//                       style: TextStyle(
//                         fontSize: isMobile(context) ? 14 : 16,
//                         fontStyle: FontStyle.italic,
//                         color: Colors.grey.shade700,
//                         height: 1.5,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 20),
//                     Text(
//                       testimonial['name'] as String,
//                       style: TextStyle(
//                         fontSize: isMobile(context) ? 16 : 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     SizedBox(height: 5),
//                     Text(
//                       testimonial['company'] as String,
//                       style: TextStyle(
//                         fontSize: isMobile(context) ? 12 : 14,
//                         color: Colors.grey.shade600,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsSection(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: getResponsivePadding(context, compact: true), // Reduced padding
//       margin: EdgeInsets.only(top: 15), // Reduced top margin
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFF667EEA),
//             Color(0xFF764BA2),
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.purple.withOpacity(0.3),
//             blurRadius: 30,
//             spreadRadius: 10,
//             offset: Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(
//             '🏆 Our Achievements',
//             style: TextStyle(
//               fontSize: getResponsiveFontSize(context,
//                 mobile: 30, tablet: 34, desktop: 38),
//               fontWeight: FontWeight.w900,
//               letterSpacing: 1.2,
//               color: Colors.white,
//             ),
//           ),
//           SizedBox(height: 15),
//           Text(
//             'Numbers that speak for our excellence',
//             style: TextStyle(
//               fontSize: getResponsiveFontSize(context,
//                 mobile: 16, tablet: 18, desktop: 20),
//               color: Colors.white70,
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 35), // Reduced spacing
//           GridView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: isMobile(context) ? 2 : 4,
//               crossAxisSpacing: 20,
//               mainAxisSpacing: 20,
//               childAspectRatio: 1.2,
//             ),
//             itemCount: stats.length,
//             itemBuilder: (context, index) {
//               final statMap = stats[index];
//               return _buildGlassmorphicStatCard(statMap);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGlassmorphicStatCard(Map<String, dynamic> statMap) {
//     return GlassmorphicCard(
//       padding: EdgeInsets.all(20),
//       gradientColors: [
//         Colors.white.withOpacity(0.2),
//         Colors.white.withOpacity(0.1),
//       ],
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           AnimatedBuilder(
//             animation: _pulseController,
//             builder: (context, child) {
//               return Transform.scale(
//                 scale: 1.0 + (_pulseController.value * 0.1),
//                 child: Container(
//                   padding: EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     gradient: RadialGradient(
//                       colors: [
//                         Colors.white.withOpacity(0.3),
//                         Colors.white.withOpacity(0.1),
//                       ],
//                     ),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     statMap['icon'] as IconData,
//                     size: 35,
//                     color: Colors.white,
//                   ),
//                 ),
//               );
//             },
//           ),
//           SizedBox(height: 15),
//           TweenAnimationBuilder<int>(
//             tween: IntTween(begin: 0, end: statMap['number']),
//             duration: Duration(seconds: 2),
//             builder: (context, value, child) {
//               return Text(
//                 '$value${statMap['suffix']}',
//                 style: TextStyle(
//                   fontSize: getResponsiveFontSize(context,
//                     mobile: 26, tablet: 30, desktop: 34),
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               );
//             },
//           ),
//           SizedBox(height: 8),
//           Text(
//             statMap['label'],
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: getResponsiveFontSize(context,
//                 mobile: 13, tablet: 14, desktop: 15),
//               color: Colors.white70,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

 

//   Widget _buildFooter() {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         vertical: isMobile(context) ? 40 : 60, 
//         horizontal: 20
//       ),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.grey.shade900,
//             Colors.black87,
//           ],
//         ),
//       ),
//       child: Column(
//         children: [
//           if (isMobile(context))
//             Column(
//               children: [
//                 Column(
//                   children: [
//                     Icon(FontAwesomeIcons.code, color: Colors.white, size: 40),
//                     SizedBox(height: 10),
//                     Text(
//                       'AppTech Vibe',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     Text(
//                       'Your trusted partner in digital transformation',
//                       style: TextStyle(color: Colors.grey.shade400),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         _buildSocialIcon(FontAwesomeIcons.facebook, Colors.blue),
//                         SizedBox(width: 15),
//                         _buildSocialIcon(FontAwesomeIcons.twitter, Colors.lightBlue),
//                         SizedBox(width: 15),
//                         _buildSocialIcon(FontAwesomeIcons.linkedin, Colors.blueAccent),
//                         SizedBox(width: 15),
//                         _buildSocialIcon(FontAwesomeIcons.instagram, Colors.pink),
//                       ],
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 40),
//                 _buildFooterSection('Services', [
//                   'App Development',
//                   'Web Development',
//                   'IoT Solutions',
//                   'Security Services',
//                 ]),
//                 SizedBox(height: 40),
//                 _buildFooterSection('Contact', [
//                   'info@apptechvibe.com',
//                   '+880 1234567890',
//                   'Dhaka, Bangladesh',
//                 ]),
//               ],
//             )
//           else
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(FontAwesomeIcons.code, color: Colors.white, size: 30),
//                         SizedBox(width: 10),
//                         Text(
//                           'AppTech Vibe',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     Text(
//                       'Your trusted partner in digital transformation',
//                       style: TextStyle(color: Colors.grey.shade400),
//                     ),
//                     SizedBox(height: 20),
//                     Row(
//                       children: [
//                         _buildSocialIcon(FontAwesomeIcons.facebook, Colors.blue),
//                         SizedBox(width: 15),
//                         _buildSocialIcon(FontAwesomeIcons.twitter, Colors.lightBlue),
//                         SizedBox(width: 15),
//                         _buildSocialIcon(FontAwesomeIcons.linkedin, Colors.blueAccent),
//                         SizedBox(width: 15),
//                         _buildSocialIcon(FontAwesomeIcons.instagram, Colors.pink),
//                       ],
//                     ),
//                   ],
//                 ),
//                 _buildFooterSection('Services', [
//                   'App Development',
//                   'Web Development',
//                   'IoT Solutions',
//                   'Security Services',
//                 ]),
//                 _buildFooterSection('Quick Links', [
//                   'About Us',
//                   'Our Team',
//                   'Portfolio',
//                   'Careers',
//                 ]),
//                 _buildFooterSection('Contact', [
//                   'info@apptechvibe.com',
//                   '+880 1234567890',
//                   'Dhaka, Bangladesh',
//                 ]),
//               ],
//             ),
//           SizedBox(height: 40),
//           Divider(color: Colors.grey.shade700),
//           SizedBox(height: 20),
//          Text(
//             '© ${DateTime.now().year} AppTech Vibe. All rights reserved.',
//             style: TextStyle(color: Colors.grey.shade400, fontSize: isMobile(context) ? 12 : 14),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFooterSection(String title, List<String> items) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(height: 15),
//         ...items.map((item) => Padding(
//           padding: EdgeInsets.symmetric(vertical: 5),
//           child: Text(
//             item,
//             style: TextStyle(
//               color: Colors.grey.shade400,
//               fontSize: 14,
//             ),
//           ),
//         )).toList(),
//       ],
//     );
//   }

//   Widget _buildSocialIcon(IconData icon, Color color) {
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         padding: EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           shape: BoxShape.circle,
//           border: Border.all(
//             color: color.withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Icon(
//           icon,
//           color: color,
//           size: 20,
//         ),
//       ),
//     );
//   }
// }

// class Service {
//   final IconData icon;
//   final String title;
//   final String description;
//   final Color color;
//   final String image;

//   Service({
//     required this.icon,
//     required this.title,
//     required this.description,
//     required this.color,
//     required this.image,
//   });
// }

// class Stat {
//   final IconData icon;
//   final String value;
//   final String label;

//   Stat({
//     required this.icon,
//     required this.value,
//     required this.label,
//   });
// }


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

// Optimized Background Widget - Reduced complexity
class OptimizedBackground extends StatefulWidget {
  final Widget child;
  
  const OptimizedBackground({Key? key, required this.child}) : super(key: key);
  
  @override
  _OptimizedBackgroundState createState() => _OptimizedBackgroundState();
}

class _OptimizedBackgroundState extends State<OptimizedBackground> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    // Single animation controller instead of multiple
    _controller = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_controller);
    _controller.repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Simplified gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF8FAFC),
                Color(0xFFE2E8F0),
                Color(0xFFF1F5F9),
              ],
            ),
          ),
        ),
        // Reduced number of floating icons (3 instead of 6)
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                children: List.generate(3, (index) {
                  final icons = [
                    FontAwesomeIcons.code,
                    FontAwesomeIcons.mobile,
                    FontAwesomeIcons.globe,
                  ];
                  
                  return Positioned(
                    left: (index * 300.0) % MediaQuery.of(context).size.width + 
                          math.sin(_animation.value + index) * 30,
                    top: 100 + index * 200.0 + math.cos(_animation.value + index) * 20,
                    child: Opacity(
                      opacity: 0.06,
                      child: Icon(
                        icons[index],
                        size: 60 + (index * 10.0),
                        color: [Colors.blue, Colors.purple, Colors.orange][index].withOpacity(0.3),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

// Optimized Glassmorphism Card - Reduced blur for performance
class OptimizedGlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final List<Color>? gradientColors;
  
  const OptimizedGlassmorphicCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.blur = 8, // Reduced from 15 to 8
    this.opacity = 0.1,
    this.borderRadius,
    this.gradientColors,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: width,
        height: height,
        margin: margin,
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors ?? [
                    Colors.white.withOpacity(opacity),
                    Colors.white.withOpacity(opacity * 0.8),
                  ],
                ),
                borderRadius: borderRadius ?? BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15, // Reduced from 20
                    spreadRadius: 0,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// Enhanced Landing Page with Performance Optimizations
class EnhancedLandingPage extends StatefulWidget {
  @override
  _EnhancedLandingPageState createState() => _EnhancedLandingPageState();
}

class _EnhancedLandingPageState extends State<EnhancedLandingPage> 
    with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Reduced number of animation controllers
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _marqueeController;
  late Animation<double> _marqueeAnimation;
  
  ScrollController _pageScrollController = ScrollController();
  
  String selectedCategory = 'All';
  double _scrollOffset = 0.0;
  bool _showScrollToTop = false;
  
  // Optimized marquee announcements
  final List<String> announcements = [
    "🔥 MEGA SALE: 75% OFF on all premium services!",
    "🚀 New AI-powered solutions now available",
    "💡 Free consultation for enterprise clients",
    "⚡ 24/7 support with 99.9% uptime guarantee",
  ];
  
  // Stats for animated counters
  final List<Map<String, dynamic>> stats = [
    {'number': 500, 'suffix': '+', 'label': 'Happy Clients', 'icon': FontAwesomeIcons.users},
    {'number': 50, 'suffix': '+', 'label': 'Projects Completed', 'icon': FontAwesomeIcons.projectDiagram},
    {'number': 24, 'suffix': '/7', 'label': 'Support Available', 'icon': FontAwesomeIcons.headset},
    {'number': 99, 'suffix': '%', 'label': 'Client Satisfaction', 'icon': FontAwesomeIcons.star},
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
    
    // Reduced animation controllers
    _mainController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: Duration(seconds: 4), // Increased duration for smoother animation
      vsync: this,
    )..repeat(reverse: true);
    
    // Optimized marquee animation
    _marqueeController = AnimationController(
      duration: Duration(seconds: 20), // Reduced from 25
      vsync: this,
    )..repeat();
    
    _marqueeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _marqueeController,
      curve: Curves.linear,
    ));
    
    _mainController.forward();
    
    _pageScrollController.addListener(() {
      setState(() {
        _scrollOffset = _pageScrollController.offset;
        _showScrollToTop = _scrollOffset > 300;
      });
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _marqueeController.dispose();
    _pageScrollController.dispose();
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
            _buildDrawerItem(Icons.info, 'About', null, context),
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
          OptimizedBackground(
            child: SingleChildScrollView(
              controller: _pageScrollController,
              child: Column(
                children: [
                  _buildOptimizedMarqueeBar(),
                  _buildOptimizedHeroSection(),
                  _buildOptimizedFeaturedProducts(),
                  _buildOptimizedServicesSection(),
                  _buildOptimizedPaymentSection(),
                  _buildOptimizedTestimonialsSection(),
                  _buildOptimizedStatsSection(context),
                  _buildOptimizedFooter(),
                ],
              ),
            ),
          ),
          AIFloatingChatWidget(),
        ],
      ),
    );
  }

  // Optimized Marquee Bar with reduced complexity
  Widget _buildOptimizedMarqueeBar() {
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
        ),
        child: ClipRect(
          child: AnimatedBuilder(
            animation: _marqueeAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    left: _getOptimizedMarqueePosition(),
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
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1), // Reduced animation intensity
                child: Icon(Icons.campaign, color: Colors.white, size: 22),
              );
            },
          ),
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

  double _getOptimizedMarqueePosition() {
    final screenWidth = MediaQuery.of(context).size.width;
    final totalWidth = announcements.length * 400.0 * 2;
    return -((_marqueeAnimation.value * totalWidth) % totalWidth) + screenWidth;
  }

  // Optimized Hero Section
  Widget _buildOptimizedHeroSection() {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = isMobile(context) ? screenHeight * 0.85 : screenHeight * 0.75;
    
    return RepaintBoundary(
      child: Container(
        height: heroHeight,
        child: Stack(
          children: [
            // Simplified background with fewer orbs
            ...List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return Positioned(
                    left: (index * 250.0) + (_mainController.value * 40),
                    top: 150 + (index * 80.0) + (math.sin(_mainController.value * 2 * math.pi + index) * 20),
                    child: Container(
                      width: 120 - (index * 20.0),
                      height: 120 - (index * 20.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            [Colors.blue, Colors.purple, Colors.orange][index].withOpacity(0.1),
                            [Colors.blue, Colors.purple, Colors.orange][index].withOpacity(0.03),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
            
            // Main Content
            Center(
              child: FadeTransition(
                opacity: _mainController,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Simplified offer badge
                      Container(
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
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_fire_department, color: Colors.white, size: 26),
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
                      
                      SizedBox(height: 40),
                      
                      // Simplified animated title
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
                            pause: Duration(milliseconds: 2000), // Increased pause
                            animatedTexts: [
                              TypewriterAnimatedText(
                                'Revolutionary IT Solutions',
                                textStyle: TextStyle(
                                  foreground: Paint()
                                    ..shader = LinearGradient(
                                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                                ),
                                speed: Duration(milliseconds: 100), // Faster typing
                              ),
                              TypewriterAnimatedText(
                                'Future-Ready Technology',
                                textStyle: TextStyle(
                                  foreground: Paint()
                                    ..shader = LinearGradient(
                                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                                    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                                ),
                                speed: Duration(milliseconds: 100),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 30),
                      
                      // Enhanced Subtitle
                      Container(
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
                      
                      SizedBox(height: 50),
                      
                      // Simplified CTA Buttons
                      Wrap(
                        spacing: 25,
                        runSpacing: 25,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildOptimizedHeroButton(
                            'Explore Products',
                            Icons.rocket_launch,
                            [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                            () => Navigator.pushNamed(context, '/products'),
                            true,
                          ),
                          _buildOptimizedHeroButton(
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

  Widget _buildOptimizedHeroButton(String text, IconData icon, List<Color> colors, VoidCallback onPressed, bool filled) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.3),
              blurRadius: 15, // Reduced blur
              spreadRadius: 2,
              offset: Offset(0, 8),
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

  // Optimized Featured Products Section
  Widget _buildOptimizedFeaturedProducts() {
    return RepaintBoundary(
      child: Container(
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
            
            // Using FutureBuilder instead of StreamBuilder for better performance
            FutureBuilder<QuerySnapshot>(
              future: _firestore
                  .collection('products')
                  .where('isPopular', isEqualTo: true)
                  .limit(3)
                  .get(),
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
                      return _buildOptimizedProductCard(data);
                    }).toList(),
                  ),
                );
              },
            ),
            
            SizedBox(height: 35),
            
            _buildViewAllButton('View All Products', '/products', Colors.orange),
          ],
        ),
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
                    color.withOpacity(0.3),
                    color.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
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

  // Optimized Product Card with cached network image
  Widget _buildOptimizedProductCard(Map<String, dynamic> data) {
    return RepaintBoundary(
      child: Container(
        width: isMobile(context) ? 290 : 330,
        margin: EdgeInsets.only(right: 25),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: OptimizedGlassmorphicCard(
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
                        image: DecorationImage(
                          image: NetworkImage(data['image'] ?? ''),
                          fit: BoxFit.cover,
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
                            Colors.black.withOpacity(0.4),
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

  // Optimized Services Section
  Widget _buildOptimizedServicesSection() {
    return RepaintBoundary(
      child: Container(
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
                return _buildOptimizedServiceCard(services[index], index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizedServiceCard(Service service, int index) {
    return RepaintBoundary(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: OptimizedGlassmorphicCard(
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

  // Optimized Payment Section
  Widget _buildOptimizedPaymentSection() {
    final paymentMethods = [
      {'name': 'bKash', 'color': Colors.pink, 'icon': FontAwesomeIcons.mobileAlt},
      {'name': 'Nagad', 'color': Colors.orange, 'icon': FontAwesomeIcons.wallet},
      {'name': 'Google Pay', 'color': Colors.blue, 'icon': FontAwesomeIcons.google},
      {'name': 'Stripe', 'color': Colors.purple, 'icon': FontAwesomeIcons.stripe},
    ];

    return RepaintBoundary(
      child: Container(
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
                  child: OptimizedGlassmorphicCard(
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
      ),
    );
  }

  // Optimized Testimonials Section
  Widget _buildOptimizedTestimonialsSection() {
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

    return RepaintBoundary(
      child: Container(
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
                autoPlayInterval: Duration(seconds: 5), // Increased interval
                enlargeCenterPage: true,
                viewportFraction: isMobile(context) ? 0.9 : 0.5,
                enableInfiniteScroll: true,
                height: isMobile(context) ? 320 : 350,
              ),
              items: testimonials.map((testimonial) {
                return OptimizedGlassmorphicCard(
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
                              Colors.purple.withOpacity(0.3),
                              Colors.purple.withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: isMobile(context) ? 35 : 40,
                          backgroundImage: NetworkImage(testimonial['image'] as String),
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
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Optimized Stats Section
  Widget _buildOptimizedStatsSection(BuildContext context) {
    return RepaintBoundary(
      child: Container(
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
                return _buildOptimizedStatCard(statMap);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizedStatCard(Map<String, dynamic> statMap) {
    return OptimizedGlassmorphicCard(
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
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
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
    );
  }

  // Optimized Footer
  Widget _buildOptimizedFooter() {
    return RepaintBoundary(
      child: Container(
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
              '© ${DateTime.now().year} AppTech Vibe. All rights reserved.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: isMobile(context) ? 12 : 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
      child: Container(
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