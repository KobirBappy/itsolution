import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui';
import 'common_appbar.dart';

class PrivacyPolicyPage extends StatefulWidget {
  final String? appName; // Optional: for different apps
  
  const PrivacyPolicyPage({Key? key, this.appName}) : super(key: key);

  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  
  // Configuration for different apps
  String get appName => widget.appName ?? 'AppTech Vibe';
  // String get companyName => 'AppTech Vibe Ltd.';
  String get contactEmail => 'kobir.hosanpro@gmail.com';
  String get lastUpdated => 'January 21, 2026';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _controller.forward();
    
    _scrollController.addListener(() {
      setState(() {
        _showScrollToTop = _scrollController.offset > 300;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  bool isTablet(BuildContext context) => MediaQuery.of(context).size.width < 1200 && MediaQuery.of(context).size.width >= 600;

  double getResponsiveFontSize(BuildContext context, {required double mobile, required double tablet, required double desktop}) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return EdgeInsets.symmetric(horizontal: 20, vertical: 30);
    if (isTablet(context)) return EdgeInsets.symmetric(horizontal: 60, vertical: 40);
    return EdgeInsets.symmetric(horizontal: 120, vertical: 50);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        type: AppBarType.other,
        title: 'Privacy Policy',
      ),
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildHeader(),
                  _buildContent(),
                  _buildFooter(),
                ],
              ),
            ),
          ),
          if (_showScrollToTop) _buildScrollToTopButton(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
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
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
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
      ),
      child: Column(
        children: [
          Icon(
            FontAwesomeIcons.shieldAlt,
            size: isMobile(context) ? 50 : 70,
            color: Colors.white,
          ),
          SizedBox(height: 20),
          Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: getResponsiveFontSize(context,
                mobile: 32, tablet: 40, desktop: 48),
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          Text(
            'Last Updated: $lastUpdated',
            style: TextStyle(
              fontSize: getResponsiveFontSize(context,
                mobile: 14, tablet: 16, desktop: 18),
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              appName,
              style: TextStyle(
                fontSize: getResponsiveFontSize(context,
                  mobile: 16, tablet: 18, desktop: 20),
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
  return Container(
    padding: getResponsivePadding(context),
    constraints: const BoxConstraints(maxWidth: 1000),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIntroSection(),
        const SizedBox(height: 40),

        _buildSection(
          icon: FontAwesomeIcons.database,
          title: '1. Information We Collect',
          color: Colors.blue,
          content: [
            _buildParagraph(
              '$appName does NOT collect, store, or transmit any personal information.',
            ),
            _buildBulletPoint('No account or login is required'),
            _buildBulletPoint('No name, email, or phone number is collected'),
            _buildBulletPoint('No analytics or tracking is used'),
            _buildBulletPoint('No data is sent to any server'),
          ],
        ),

        _buildSection(
          icon: FontAwesomeIcons.mobileAlt,
          title: '2. Local Data Storage',
          color: Colors.green,
          content: [
            _buildParagraph(
              'All notes and checklist data are stored locally on your device only.',
            ),
            _buildBulletPoint('Data never leaves your device'),
            _buildBulletPoint('Data is deleted automatically if you uninstall the app'),
            _buildBulletPoint('We cannot access your notes'),
          ],
        ),

        _buildSection(
          icon: FontAwesomeIcons.shareAlt,
          title: '3. Information Sharing',
          color: Colors.orange,
          content: [
            _buildParagraph(
              'We do not share any data because no data is collected.',
            ),
            _buildBulletPoint('No third-party services are used'),
            _buildBulletPoint('No advertising SDKs are integrated'),
            _buildBulletPoint('No cloud synchronization exists'),
          ],
        ),

        _buildSection(
          icon: FontAwesomeIcons.lock,
          title: '4. Data Security',
          color: Colors.red,
          content: [
            _buildParagraph(
              'Your data remains secure because it is stored only on your device.',
            ),
            _buildBulletPoint('No internet access is required'),
            _buildBulletPoint('No remote access to your data'),
            _buildBulletPoint('Device-level security protects your notes'),
          ],
        ),

        _buildSection(
          icon: FontAwesomeIcons.userShield,
          title: '5. Your Privacy Rights',
          color: Colors.teal,
          content: [
            _buildParagraph(
              'Since no personal data is collected, there is no personal data to access, export, or delete remotely.',
            ),
            _buildBulletPoint('You control all your data'),
            _buildBulletPoint('Uninstalling the app removes all stored data'),
          ],
        ),

        _buildSection(
          icon: FontAwesomeIcons.child,
          title: '6. Children’s Privacy',
          color: Colors.pink,
          content: [
            _buildParagraph(
              '$appName is safe for all ages and does not collect any information from children.',
            ),
          ],
        ),

        _buildSection(
          icon: FontAwesomeIcons.sync,
          title: '7. Changes to This Policy',
          color: Colors.deepOrange,
          content: [
            _buildParagraph(
              'We may update this privacy policy if the app functionality changes. Any updates will be reflected within the app.',
            ),
          ],
        ),

        _buildSection(
          icon: FontAwesomeIcons.envelope,
          title: '8. Contact Us',
          color: Colors.blueGrey,
          content: [
            _buildParagraph(
              'If you have any questions about this privacy policy, please contact us:',
            ),
            _buildContactInfo('Email:', contactEmail),
            // _buildContactInfo('Company:', companyName),
            _buildContactInfo('Location:', 'Bangladesh'),
          ],
        ),
      ],
    ),
  );
}


  // Widget _buildContent() {
  //   return Container(
  //     padding: getResponsivePadding(context),
  //     constraints: BoxConstraints(
  //       maxWidth: 1000, // Limit content width for readability
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         _buildIntroSection(),
  //         SizedBox(height: 40),
  //         _buildSection(
  //           icon: FontAwesomeIcons.database,
  //           title: '1. Information We Collect',
  //           color: Colors.blue,
  //           content: [
  //             _buildSubSection('Personal Information:', [
  //               'Name, email address, and contact details',
  //               'Account credentials and authentication data',
  //               'Billing and payment information',
  //               'Profile information and preferences',
  //             ]),
  //             _buildSubSection('Technical Information:', [
  //               'IP address and device information',
  //               'Browser type and operating system',
  //               'Cookies and similar tracking technologies',
  //               'Usage data and analytics',
  //             ]),
  //             _buildSubSection('Transaction Data:', [
  //               'Purchase history and order details',
  //               'Payment method information (encrypted)',
  //               'Shipping and delivery information',
  //             ]),
  //           ],
  //         ),
  //         _buildSection(
  //           icon: FontAwesomeIcons.cogs,
  //           title: '2. How We Use Your Information',
  //           color: Colors.green,
  //           content: [
  //             _buildBulletPoint('To provide and maintain our services'),
  //             _buildBulletPoint('To process transactions and send order confirmations'),
  //             _buildBulletPoint('To communicate with you about updates and promotions'),
  //             _buildBulletPoint('To improve our services and user experience'),
  //             _buildBulletPoint('To detect and prevent fraud or security issues'),
  //             _buildBulletPoint('To comply with legal obligations'),
  //           ],
  //         ),
  //         _buildSection(
  //           icon: FontAwesomeIcons.shareAlt,
  //           title: '3. Information Sharing',
  //           color: Colors.orange,
  //           content: [
  //             _buildParagraph(
  //               'We do not sell your personal information. We may share your data with:',
  //             ),
  //             _buildSubSection('Service Providers:', [
  //               'Payment processors (bKash, Nagad, Stripe, Google Pay)',
  //               'Cloud hosting services (Firebase, Google Cloud)',
  //               'Analytics services for usage statistics',
  //               'Email and communication services',
  //             ]),
  //             _buildSubSection('Legal Requirements:', [
  //               'When required by law or legal process',
  //               'To protect our rights and property',
  //               'In connection with business transfers or mergers',
  //             ]),
  //           ],
  //         ),
  //         _buildSection(
  //           icon: FontAwesomeIcons.lock,
  //           title: '4. Data Security',
  //           color: Colors.red,
  //           content: [
  //             _buildParagraph(
  //               'We implement industry-standard security measures to protect your information:',
  //             ),
  //             _buildBulletPoint('SSL/TLS encryption for data transmission'),
  //             _buildBulletPoint('Encrypted storage of sensitive information'),
  //             _buildBulletPoint('Regular security audits and updates'),
  //             _buildBulletPoint('Access controls and authentication mechanisms'),
  //             _buildBulletPoint('Secure payment processing through certified gateways'),
  //           ],
  //         ),
  //         _buildSection(
  //           icon: FontAwesomeIcons.cookie,
  //           title: '5. Cookies and Tracking',
  //           color: Colors.purple,
  //           content: [
  //             _buildParagraph(
  //               'We use cookies and similar technologies for:',
  //             ),
  //             _buildBulletPoint('Essential functionality and authentication'),
  //             _buildBulletPoint('Analytics and performance monitoring'),
  //             _buildBulletPoint('Personalization and preferences'),
  //             _buildBulletPoint('Marketing and advertising'),
  //             _buildParagraph(
  //               'You can control cookies through your browser settings. Note that disabling cookies may affect functionality.',
  //             ),
  //           ],
  //         ),
  //         _buildSection(
  //           icon: FontAwesomeIcons.userShield,
  //           title: '6. Your Rights',
  //           color: Colors.teal,
  //           content: [
  //             _buildParagraph('You have the right to:'),
  //             _buildBulletPoint('Access your personal data'),
  //             _buildBulletPoint('Correct inaccurate information'),
  //             _buildBulletPoint('Request deletion of your data'),
  //             _buildBulletPoint('Object to data processing'),
  //             _buildBulletPoint('Export your data'),
  //             _buildBulletPoint('Withdraw consent'),
  //             _buildParagraph(
  //               'To exercise these rights, contact us at $contactEmail',
  //             ),
  //           ],
  //         ),
  //         _buildSection(
  //           icon: FontAwesomeIcons.creditCard,
  //           title: '7. Payment Information',
  //           color: Colors.indigo,
  //           content: [
  //             _buildParagraph(
  //               'Payment processing is handled by secure third-party providers:',
  //             ),
  //             _buildBulletPoint('bKash - for mobile wallet payments'),
  //             _buildBulletPoint('Nagad - for mobile financial services'),
  //             _buildBulletPoint('Stripe - for international card payments'),
  //             _buildBulletPoint('Google Pay - for digital wallet transactions'),
  //             _buildParagraph(
  //               'We do not store complete payment card details on our servers. All payment data is encrypted and processed securely.',
  //             ),
  //           ],
  //         ),
  //         _buildSection(
  //           icon: FontAwesomeIcons.child,
  //           title: '8. Children\'s Privacy',
  //           color: Colors.pink,
  //           content: [
  //             _buildParagraph(
  //               'Our services are not intended for children under 13. We do not knowingly collect information from children. If you believe we have collected data from a child, please contact us immediately.',
  //             ),
  //           ],
  //         ),
  //         _buildSection(
  //           icon: FontAwesomeIcons.globeAsia,
  //           title: '9. International Data Transfers',
  //           color: Colors.cyan,
  //           content: [
  //             _buildParagraph(
  //               'Your data may be transferred and processed in countries outside your residence. We ensure appropriate safeguards are in place for international transfers.',
  //             ),
  //           ],
  //         ),
  //         _buildSection(
  //           icon: FontAwesomeIcons.clock,
  //           title: '10. Data Retention',
  //           color: Colors.amber,
  //           content: [
  //             _buildParagraph(
  //               'We retain your information for as long as necessary to:',
  //             ),
  //             _buildBulletPoint('Provide our services'),
  //             _buildBulletPoint('Comply with legal obligations'),
  //             _buildBulletPoint('Resolve disputes'),
  //             _buildBulletPoint('Enforce our agreements'),
  //             _buildParagraph(
  //               'You may request deletion of your account and data at any time.',
  //             ),
  //           ],
  //         ),
  //         _buildSection(
  //           icon: FontAwesomeIcons.sync,
  //           title: '11. Changes to This Policy',
  //           color: Colors.deepOrange,
  //           content: [
  //             _buildParagraph(
  //               'We may update this privacy policy periodically. We will notify you of significant changes via email or prominent notice on our platform. Your continued use after changes constitutes acceptance.',
  //             ),
  //           ],
  //         ),
  //         _buildSection(
  //           icon: FontAwesomeIcons.envelope,
  //           title: '12. Contact Us',
  //           color: Colors.blueGrey,
  //           content: [
  //             _buildParagraph(
  //               'If you have questions or concerns about this privacy policy:',
  //             ),
  //             _buildContactInfo('Email:', contactEmail),
  //             _buildContactInfo('Company:', companyName),
  //             _buildContactInfo('Address:', 'Dhaka, Bangladesh'),
  //             _buildParagraph(
  //               'We will respond to your inquiry within 48 hours.',
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildIntroSection() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.infoCircle, color: Colors.blue, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Introduction',
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(context,
                      mobile: 20, tablet: 22, desktop: 24),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            'At $appName, we are committed to protecting your privacy and personal information. This privacy policy explains how we collect, use, share, and safeguard your data when you use our services.',
            style: TextStyle(
              fontSize: getResponsiveFontSize(context,
                mobile: 14, tablet: 15, desktop: 16),
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'By using our services, you agree to the collection and use of information in accordance with this policy.',
            style: TextStyle(
              fontSize: getResponsiveFontSize(context,
                mobile: 14, tablet: 15, desktop: 16),
              color: Colors.grey.shade700,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGlassCard(
          borderColor: color.withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(context,
                          mobile: 18, tablet: 20, desktop: 22),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ...content,
            ],
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSubSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: getResponsiveFontSize(context,
              mobile: 15, tablet: 16, desktop: 17),
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 10),
        ...items.map((item) => _buildBulletPoint(item)).toList(),
        SizedBox(height: 15),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 15, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: getResponsiveFontSize(context,
                  mobile: 14, tablet: 15, desktop: 16),
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: getResponsiveFontSize(context,
            mobile: 14, tablet: 15, desktop: 16),
          color: Colors.grey.shade700,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildContactInfo(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: getResponsiveFontSize(context,
                mobile: 14, tablet: 15, desktop: 16),
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: getResponsiveFontSize(context,
                  mobile: 14, tablet: 15, desktop: 16),
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, Color? borderColor}) {
    return Container(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(isMobile(context) ? 20 : 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor ?? Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(30),
      margin: EdgeInsets.only(top: 40),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(FontAwesomeIcons.shieldAlt, color: Colors.grey.shade600, size: 30),
            SizedBox(height: 15),
            Text(
              'Your privacy is our priority',
              style: TextStyle(
                fontSize: getResponsiveFontSize(context,
                  mobile: 16, tablet: 18, desktop: 20),
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 10),
            // Text(
            //   '© ${DateTime.now().year} $companyName. All rights reserved.',
            //   style: TextStyle(
            //     fontSize: getResponsiveFontSize(context,
            //       mobile: 12, tablet: 14, desktop: 14),
            //     color: Colors.grey.shade600,
            //   ),
            //   textAlign: TextAlign.center,
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollToTopButton() {
    return Positioned(
      right: 20,
      bottom: 20,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            _scrollController.animateTo(
              0,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.4),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_upward,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}