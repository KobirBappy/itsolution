import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize database with sample data
  static Future<void> initializeDatabase() async {
    try {
      // Check if data already exists
      final productsSnapshot = await _firestore.collection('products').limit(1).get();
      if (productsSnapshot.docs.isNotEmpty) {
        print('Database already initialized');
        return;
      }

      print('Initializing database with sample data...');

      // Create admin user if not exists
      try {
        await _auth.createUserWithEmailAndPassword(
          email: 'admin@apptechvibe.com',
          password: 'admin123',
        );
        
        // Store admin info in Firestore
        await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
          'email': 'admin@apptechvibe.com',
          'role': 'admin',
          'name': 'Admin User',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Admin user already exists or error: $e');
      }

      // Initialize Products
      final products = [
        {
          'name': 'Basic App Development',
          'category': 'Mobile Development',
          'description': 'Perfect starter package for small businesses. Includes basic mobile app with up to 5 screens, user authentication, and basic database integration.',
          'features': [
            'Up to 5 screens',
            'User authentication',
            'Basic database',
            'Push notifications',
            '1 month support'
          ],
          'price': 20,
          'originalPrice': 50,
          'discount': 60,
          'image': 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400',
          'badge': 'Best Seller',
          'badgeColor': 'orange',
          'duration': '2-3 weeks',
          'rating': 4.8,
          'reviewCount': 124,
          'isPopular': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Professional Website',
          'category': 'Web Development',
          'description': 'Modern, responsive website with CMS integration. Perfect for businesses looking to establish strong online presence.',
          'features': [
            'Responsive design',
            'CMS integration',
            'SEO optimized',
            'Contact forms',
            '3 months support'
          ],
          'price': 35,
          'originalPrice': 80,
          'discount': 56,
          'image': 'https://images.unsplash.com/photo-1467232004584-a241de8bcf5d?w=400',
          'badge': 'Popular',
          'badgeColor': 'blue',
          'duration': '3-4 weeks',
          'rating': 4.9,
          'reviewCount': 89,
          'isPopular': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'E-commerce Starter',
          'category': 'E-commerce',
          'description': 'Complete e-commerce solution with payment integration, inventory management, and admin dashboard.',
          'features': [
            'Product catalog',
            'Shopping cart',
            'Payment gateway',
            'Admin dashboard',
            '6 months support'
          ],
          'price': 50,
          'originalPrice': 120,
          'discount': 58,
          'image': 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400',
          'badge': 'Hot Deal',
          'badgeColor': 'red',
          'duration': '4-6 weeks',
          'rating': 4.7,
          'reviewCount': 156,
          'isPopular': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'IoT Smart Home Package',
          'category': 'IoT Solutions',
          'description': 'Transform your home with smart automation. Control lights, temperature, and security from your phone.',
          'features': [
            'Mobile app control',
            'Voice integration',
            'Automated schedules',
            'Energy monitoring',
            'Installation included'
          ],
          'price': 75,
          'originalPrice': 200,
          'discount': 62,
          'image': 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=400',
          'badge': 'New',
          'badgeColor': 'green',
          'duration': '1-2 weeks',
          'rating': 4.6,
          'reviewCount': 43,
          'isPopular': false,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Network Security Audit',
          'category': 'Security',
          'description': 'Comprehensive security assessment of your network infrastructure with detailed report and recommendations.',
          'features': [
            'Vulnerability scan',
            'Penetration testing',
            'Security report',
            'Risk assessment',
            'Remediation guide'
          ],
          'price': 40,
          'originalPrice': 100,
          'discount': 60,
          'image': 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=400',
          'badge': 'Professional',
          'badgeColor': 'purple',
          'duration': '1 week',
          'rating': 4.9,
          'reviewCount': 67,
          'isPopular': false,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Custom ERP Solution',
          'category': 'Enterprise',
          'description': 'Tailored ERP system for your business needs. Streamline operations with integrated modules.',
          'features': [
            'Custom modules',
            'Multi-branch support',
            'Real-time analytics',
            'Cloud deployment',
            '1 year support'
          ],
          'price': 150,
          'originalPrice': 400,
          'discount': 62,
          'image': 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=400',
          'badge': 'Enterprise',
          'badgeColor': 'indigo',
          'duration': '3-6 months',
          'rating': 4.8,
          'reviewCount': 28,
          'isPopular': false,
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      // Add products to Firestore
      for (var product in products) {
        await _firestore.collection('products').add(product);
      }

      // Initialize Services
      final services = [
        {
          'title': 'Mobile App Development',
          'category': 'Development',
          'description': 'Create powerful native and cross-platform mobile applications for iOS and Android.',
          'features': [
            'Native iOS & Android Development',
            'Cross-platform Solutions',
            'UI/UX Design',
            'App Store Deployment',
            'Performance Optimization'
          ],
          'pricing': 'Starting from \$5,000',
          'duration': '2-6 months',
          'imageUrl': 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=800',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Web Development',
          'category': 'Development',
          'description': 'Build responsive, modern websites and web applications tailored to your business needs.',
          'features': [
            'Responsive Design',
            'E-commerce Integration',
            'Content Management Systems',
            'Progressive Web Apps',
            'SEO Optimization'
          ],
          'pricing': 'Starting from \$3,000',
          'duration': '1-4 months',
          'imageUrl': 'https://images.unsplash.com/photo-1467232004584-a241de8bcf5d?w=800',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Networking Solutions',
          'category': 'Infrastructure',
          'description': 'Design and implement robust network infrastructure for your organization.',
          'features': [
            'Network Design',
            'Firewall Configuration',
            'VPN Setup',
            'Network Security Audits',
            'Wireless Solutions'
          ],
          'pricing': 'Starting from \$2,500',
          'duration': '1-2 months',
          'imageUrl': 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=800',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Ethical Hacking & Security',
          'category': 'Security',
          'description': 'Protect your digital assets with comprehensive security testing and solutions.',
          'features': [
            'Penetration Testing',
            'Vulnerability Assessment',
            'Security Audits',
            'Incident Response',
            'Security Training'
          ],
          'pricing': 'Starting from \$2,000',
          'duration': '2-4 weeks',
          'imageUrl': 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800',
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      // Add services to Firestore
      for (var service in services) {
        await _firestore.collection('services').add(service);
      }

      // Create Firestore indexes programmatically (Note: Some indexes need to be created manually in Firebase Console)
      // For compound queries, you'll need to create indexes in Firebase Console

      print('Database initialization complete!');
      
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  // Create sample user accounts
  static Future<void> createSampleUsers() async {
    try {
      // Create sample customer users
      final sampleUsers = [
        {
          'email': 'user1@example.com',
          'password': 'user123',
          'name': 'John Doe',
          'role': 'customer',
        },
        {
          'email': 'user2@example.com',
          'password': 'user123',
          'name': 'Jane Smith',
          'role': 'customer',
        },
      ];

      for (var userData in sampleUsers) {
        try {
          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: userData['email'] as String,
            password: userData['password'] as String,
          );

          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'email': userData['email'],
            'name': userData['name'],
            'role': userData['role'],
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          print('User ${userData['email']} might already exist: $e');
        }
      }
    } catch (e) {
      print('Error creating sample users: $e');
    }
  }
}