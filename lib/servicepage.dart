import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ServicesPage extends StatefulWidget {
  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<AnimationController> _cardControllers;
  String selectedCategory = 'All';
  
  final List<ServiceDetail> services = [
    ServiceDetail(
      icon: FontAwesomeIcons.mobileAlt,
      title: 'Mobile App Development',
      category: 'Development',
      description: 'Create powerful native and cross-platform mobile applications for iOS and Android.',
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
      color: Colors.blue,
      image: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=800',
    ),
    ServiceDetail(
      icon: FontAwesomeIcons.globe,
      title: 'Web Development',
      category: 'Development',
      description: 'Build responsive, modern websites and web applications tailored to your business needs.',
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
      color: Colors.purple,
      image: 'https://images.unsplash.com/photo-1467232004584-a241de8bcf5d?w=800',
    ),
    ServiceDetail(
      icon: FontAwesomeIcons.networkWired,
      title: 'Networking Solutions',
      category: 'Infrastructure',
      description: 'Design and implement robust network infrastructure for your organization.',
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
      color: Colors.green,
      image: 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=800',
    ),
    ServiceDetail(
      icon: FontAwesomeIcons.server,
      title: 'cPanel & Server Management',
      category: 'Infrastructure',
      description: 'Professional server management and optimization services for peak performance.',
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
      color: Colors.orange,
      image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
    ),
    ServiceDetail(
      icon: FontAwesomeIcons.microchip,
      title: 'IoT Solutions',
      category: 'Emerging Tech',
      description: 'Connect and automate your devices with cutting-edge Internet of Things technology.',
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
      color: Colors.teal,
      image: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800',
    ),
    ServiceDetail(
      icon: FontAwesomeIcons.shieldAlt,
      title: 'Ethical Hacking & Security',
      category: 'Security',
      description: 'Protect your digital assets with comprehensive security testing and solutions.',
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
      color: Colors.red,
      image: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800',
    ),
    ServiceDetail(
      icon: FontAwesomeIcons.shoppingCart,
      title: 'E-commerce Solutions',
      category: 'Development',
      description: 'Launch your online store with secure payment processing and inventory management.',
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
      color: Colors.indigo,
      image: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800',
    ),
    ServiceDetail(
      icon: FontAwesomeIcons.building,
      title: 'ERP Solutions',
      category: 'Enterprise',
      description: 'Streamline your business operations with integrated enterprise resource planning.',
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
      color: Colors.brown,
      image: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=800',
    ),
  ];

  final List<String> categories = ['All', 'Development', 'Infrastructure', 'Security', 'Emerging Tech', 'Enterprise'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _cardControllers = List.generate(
      services.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    
    _controller.forward();
    _animateCards();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Our Services',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!isMobile(context))
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/contact'),
                icon: Icon(Icons.chat),
                label: Text('Get Quote'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Hero Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.purple.shade50,
                ],
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Professional IT Services',
                  style: TextStyle(
                    fontSize: isMobile(context) ? 28 : 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Choose from our comprehensive range of IT solutions',
                  style: TextStyle(
                    fontSize: isMobile(context) ? 16 : 18,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Category Filter
          Container(
            height: 50,
            margin: EdgeInsets.symmetric(vertical: 20),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;
                
                return Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    selectedColor: Colors.blue.shade700,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Services Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile(context) ? 1 : isTablet(context) ? 2 : 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: isMobile(context) ? 0.75 : 0.7,
              ),
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                return _buildServiceCard(filteredServices[index], index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isMobile(context)
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/contact'),
              icon: Icon(Icons.chat),
              label: Text('Get Quote'),
              backgroundColor: Colors.blue.shade700,
            )
          : null,
    );
  }

  Widget _buildServiceCard(ServiceDetail service, int index) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _cardControllers[index % _cardControllers.length],
        curve: Curves.elasticOut,
      )),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _showServiceDetails(service),
          child: Container(
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
                // Image Section
                Stack(
                  children: [
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        image: DecorationImage(
                          image: NetworkImage(service.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 15,
                      right: 15,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: service.color,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          service.category,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 15,
                      left: 15,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          service.icon,
                          color: service.color,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Content Section
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: Text(
                            service.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Starting from',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                Text(
                                  service.pricing.split('from ')[1],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: service.color,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => _showServiceDetails(service),
                              child: Row(
                                children: [
                                  Text('Details'),
                                  SizedBox(width: 5),
                                  Icon(Icons.arrow_forward, size: 16),
                                ],
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
    );
  }

  void _showServiceDetails(ServiceDetail service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceDetailModal(service: service),
    );
  }
}

class ServiceDetailModal extends StatelessWidget {
  final ServiceDetail service;

  const ServiceDetailModal({Key? key, required this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: service.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          service.icon,
                          color: service.color,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            Text(
                              service.category,
                              style: TextStyle(
                                fontSize: 14,
                                color: service.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Description
                  Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    service.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  
                  SizedBox(height: 25),
                  
                  // Features
                  Text(
                    'What\'s Included',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 15),
                  ...service.features.map((feature) => Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                  
                  SizedBox(height: 25),
                  
                  // Pricing & Duration
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pricing',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                service.pricing,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Duration',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                service.duration,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 25),
                  
                  // CTA Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/contact');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: service.color,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
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
                      SizedBox(width: 15),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/contact');
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: service.color, width: 2),
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Contact Us',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: service.color,
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
  });
}