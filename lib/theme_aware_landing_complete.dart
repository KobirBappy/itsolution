// lib/theme_aware_landing_complete.dart
import 'package:flutter/material.dart';
import 'package:itapp/main.dart';
import 'package:provider/provider.dart';
import 'theme_manager_complete.dart';

// Import your actual landing page file - UPDATE THIS PATH TO YOUR ACTUAL FILE
// Replace 'main.dart' with your actual landing page file name
// For example: 'landing_page.dart', 'home_page.dart', etc.


// Option 2: If you want to use the placeholder modern theme (temporary)
import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Temporary Modern Theme (replace with your actual modern theme)
class ModernEnhancedLandingPage extends StatefulWidget {
  @override
  _ModernEnhancedLandingPageState createState() => _ModernEnhancedLandingPageState();
}

class _ModernEnhancedLandingPageState extends State<ModernEnhancedLandingPage> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                  Color(0xFFf093fb),
                  Color(0xFFf5576c),
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
          
          // Floating particles effect
          ...List.generate(20, (index) {
            return Positioned(
              left: (index * 50.0) % MediaQuery.of(context).size.width,
              top: (index * 80.0) % MediaQuery.of(context).size.height,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      30 * (0.5 - _animationController.value),
                      50 * (0.5 - _animationController.value),
                    ),
                    child: Opacity(
                      opacity: 0.1 + (0.2 * _animationController.value),
                      child: Container(
                        width: 4 + (index % 3) * 2.0,
                        height: 4 + (index % 3) * 2.0,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          
          // Main Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glassmorphism card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Animated icon
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 0.8 + (0.2 * _animationController.value),
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.3),
                                          Colors.white.withOpacity(0.1),
                                        ],
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 30),
                            
                            // Title
                            Text(
                              'Modern Glass Theme',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            
                            // Subtitle
                            Text(
                              'Experience the future of web design with\nglassmorphism effects and smooth animations',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 40),
                            
                            // Action buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildGlassButton(
                                  'Explore Products',
                                  Icons.shopping_bag,
                                  () => Navigator.pushNamed(context, '/products'),
                                  true,
                                ),
                                SizedBox(width: 20),
                                _buildGlassButton(
                                  'Our Services',
                                  Icons.design_services,
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
                  
                  SizedBox(height: 50),
                  
                  // Feature indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeatureIndicator('Glassmorphism', Icons.blur_on),
                      SizedBox(width: 30),
                      _buildFeatureIndicator('Animations', Icons.animation),
                      SizedBox(width: 30),
                      _buildFeatureIndicator('Modern Design', Icons.auto_awesome),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGlassButton(String text, IconData icon, VoidCallback onPressed, bool filled) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: filled 
                ? Colors.white.withOpacity(0.2) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(25),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      text,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureIndicator(String text, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Theme-aware landing page that switches between different UIs
class ThemeAwareLandingPage extends StatefulWidget {
  @override
  _ThemeAwareLandingPageState createState() => _ThemeAwareLandingPageState();
}

class _ThemeAwareLandingPageState extends State<ThemeAwareLandingPage> {
  @override
  void initState() {
    super.initState();
    // Listen to theme changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeManager = Provider.of<ThemeManager>(context, listen: false);
      themeManager.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        switch (themeManager.currentTheme) {
          case UITheme.classic:
            // OPTION 1: Use your actual landing page widget name directly
            // Replace 'EnhancedLandingPage' with your actual widget name
            return EnhancedLandingPage();
            
            // OPTION 2: If your landing page is in a different file, uncomment and update:
            // return YourActualLandingPageWidget();
            
          case UITheme.modern:
            // Use the modern glassmorphism theme
            return ModernEnhancedLandingPage();
            
          default:
            // Fallback to classic theme
            return EnhancedLandingPage();
        }
      },
    );
  }
}