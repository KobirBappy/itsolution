import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;
import 'dart:ui';

// ==================== MODEL CLASSES ====================

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

// ==================== ANIMATED BACKGROUND ====================

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({Key? key, required this.child}) : super(key: key);

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      6,
      (index) => AnimationController(
        duration: Duration(seconds: 8 + index * 2),
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
        // Enhanced Gradient Background
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
        // Floating Tech Icons
        ...List.generate(6, (index) {
          final icons = [
            FontAwesomeIcons.code,
            FontAwesomeIcons.mobile,
            FontAwesomeIcons.server,
            FontAwesomeIcons.shield,
            FontAwesomeIcons.globe,
            FontAwesomeIcons.microchip,
          ];

          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Positioned(
                left: (index * 180.0) % MediaQuery.of(context).size.width +
                    math.sin(_animations[index].value) * 60,
                top: 80 +
                    index * 120.0 +
                    math.cos(_animations[index].value) * 40,
                child: Opacity(
                  opacity: 0.08,
                  child: Transform.rotate(
                    angle: _animations[index].value * 0.5,
                    child: Icon(
                      icons[index],
                      size: 80 + (index * 15.0),
                      color: [
                        Colors.blue,
                        Colors.purple,
                        Colors.orange,
                        Colors.teal,
                        Colors.indigo,
                        Colors.red
                      ][index].withOpacity(0.4),
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

// ==================== GLASSMORPHIC CARD ====================

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final List<Color>? gradientColors;

  const GlassmorphicCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.blur = 15,
    this.opacity = 0.1,
    this.borderRadius,
    this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                colors: gradientColors ??
                    [
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
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ==================== RESPONSIVE HELPERS ====================

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1200 &&
      MediaQuery.of(context).size.width >= 600;
  
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static EdgeInsets getResponsivePadding(BuildContext context,
      {bool compact = false}) {
    final multiplier = compact ? 0.5 : 1.0;
    if (isMobile(context))
      return EdgeInsets.symmetric(
          horizontal: 20, vertical: (35 * multiplier));
    if (isTablet(context))
      return EdgeInsets.symmetric(
          horizontal: 40, vertical: (45 * multiplier));
    return EdgeInsets.symmetric(
        horizontal: 80, vertical: (55 * multiplier));
  }
}

// ==================== CUSTOM BACK BUTTON ====================

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;
  final bool showLabel;
  
  const CustomBackButton({
    Key? key,
    this.onPressed,
    this.color,
    this.size = 24,
    this.showLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed ?? () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: showLabel ? 16 : 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back,
                color: color ?? Colors.grey.shade800,
                size: size,
              ),
              if (showLabel) ...[
                SizedBox(width: 8),
                Text(
                  'Back',
                  style: TextStyle(
                    color: color ?? Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== FLOATING BACK BUTTON ====================

class FloatingBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  
  const FloatingBackButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 10,
      child: CustomBackButton(
        onPressed: onPressed,
        showLabel: false,
      ),
    );
  }
}