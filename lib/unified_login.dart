import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPopupModal {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LoginModalContent(),
    );
  }
}

class LoginModalContent extends StatefulWidget {
  @override
  _LoginModalContentState createState() => _LoginModalContentState();
}

class _LoginModalContentState extends State<LoginModalContent> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  // User Login Controllers
  final _userEmailController = TextEditingController();
  final _userPasswordController = TextEditingController();
  
  // User Registration Controllers
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();
  
  // Admin Login Controllers
  final _adminEmailController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  
  final _userLoginFormKey = GlobalKey<FormState>();
  final _userRegFormKey = GlobalKey<FormState>();
  final _adminFormKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'customer'; // 'customer' or 'admin'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _userEmailController.dispose();
    _userPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;

  Future<void> _userLogin() async {
    if (_userLoginFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _userEmailController.text.trim(),
          password: _userPasswordController.text,
        );
        
        if (userCredential.user != null) {
          // Check user role
          final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
          
          if (userDoc.exists && userDoc.data()?['role'] == 'customer') {
            Navigator.pop(context); // Close modal
            Navigator.pushReplacementNamed(context, '/user-dashboard');
          } else {
            // Not a customer account
            await _auth.signOut();
            _showErrorSnackBar('This is not a customer account. Please use admin login.');
          }
        }
      } on FirebaseAuthException catch (e) {
        _handleAuthError(e);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _userRegister() async {
    if (_userRegFormKey.currentState!.validate()) {
      if (_regPasswordController.text != _regConfirmPasswordController.text) {
        _showErrorSnackBar('Passwords do not match');
        return;
      }
      
      setState(() => _isLoading = true);
      
      try {
        final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _regEmailController.text.trim(),
          password: _regPasswordController.text,
        );
        
        if (userCredential.user != null) {
          // Update display name
          await userCredential.user!.updateDisplayName(_regNameController.text.trim());
          
          // Save user info to Firestore
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'email': _regEmailController.text.trim(),
            'name': _regNameController.text.trim(),
            'role': 'customer',
            'createdAt': FieldValue.serverTimestamp(),
          });
          
          Navigator.pop(context); // Close modal
          Navigator.pushReplacementNamed(context, '/user-dashboard');
        }
      } on FirebaseAuthException catch (e) {
        _handleAuthError(e);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _adminLogin() async {
    if (_adminFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _adminEmailController.text.trim(),
          password: _adminPasswordController.text,
        );
        
        if (userCredential.user != null) {
          // Check if user is admin
          final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
          
          if (userDoc.exists && userDoc.data()?['role'] == 'admin') {
            Navigator.pop(context); // Close modal
            Navigator.pushReplacementNamed(context, '/admin');
          } else {
            // Not an admin account
            await _auth.signOut();
            _showErrorSnackBar('This is not an admin account. Please use customer login.');
          }
        }
      } on FirebaseAuthException catch (e) {
        _handleAuthError(e);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    String errorMessage = 'An error occurred';
    
    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'No user found with this email';
        break;
      case 'wrong-password':
        errorMessage = 'Wrong password';
        break;
      case 'invalid-email':
        errorMessage = 'Invalid email address';
        break;
      case 'user-disabled':
        errorMessage = 'This account has been disabled';
        break;
      case 'email-already-in-use':
        errorMessage = 'Email already in use';
        break;
      case 'weak-password':
        errorMessage = 'Password is too weak';
        break;
    }
    
    _showErrorSnackBar(errorMessage);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 0,
              offset: Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      // Header with close button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 40),
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  FontAwesomeIcons.code,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              Text(
                                'Sign in to continue',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
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
                      
                      SizedBox(height: 30),
                      
                      // Role Selection with enhanced design
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey.shade100, Colors.grey.shade200],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedRole = 'customer'),
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: _selectedRole == 'customer' 
                                        ? LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade400])
                                        : null,
                                    color: _selectedRole == 'customer' 
                                        ? null 
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: _selectedRole == 'customer'
                                        ? [
                                            BoxShadow(
                                              color: Colors.blue.withOpacity(0.3),
                                              blurRadius: 10,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person,
                                        color: _selectedRole == 'customer' 
                                            ? Colors.white 
                                            : Colors.grey.shade600,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Customer',
                                        style: TextStyle(
                                          color: _selectedRole == 'customer' 
                                              ? Colors.white 
                                              : Colors.grey.shade600,
                                          fontWeight: _selectedRole == 'customer' 
                                              ? FontWeight.bold 
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedRole = 'admin'),
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: _selectedRole == 'admin' 
                                        ? LinearGradient(colors: [Colors.purple.shade600, Colors.purple.shade400])
                                        : null,
                                    color: _selectedRole == 'admin' 
                                        ? null 
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: _selectedRole == 'admin'
                                        ? [
                                            BoxShadow(
                                              color: Colors.purple.withOpacity(0.3),
                                              blurRadius: 10,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.admin_panel_settings,
                                        color: _selectedRole == 'admin' 
                                            ? Colors.white 
                                            : Colors.grey.shade600,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Admin',
                                        style: TextStyle(
                                          color: _selectedRole == 'admin' 
                                              ? Colors.white 
                                              : Colors.grey.shade600,
                                          fontWeight: _selectedRole == 'admin' 
                                              ? FontWeight.bold 
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 30),
                      
                      // Forms
                      _selectedRole == 'customer' 
                          ? _buildCustomerForm() 
                          : _buildAdminForm(),
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

  Widget _buildCustomerForm() {
    return Column(
      children: [
        // Tab Bar with enhanced design
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade400]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade600,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Login'),
              Tab(text: 'Register'),
            ],
          ),
        ),
        SizedBox(height: 24),
        
        // Tab Views
        SizedBox(
          height: 420,
          child: TabBarView(
            controller: _tabController,
            children: [
              // Login Tab
              _buildLoginForm(),
              
              // Register Tab
              _buildRegisterForm(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _userLoginFormKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _userEmailController,
            label: 'Email',
            hint: 'your@email.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          _buildTextField(
            controller: _userPasswordController,
            label: 'Password',
            hint: '••••••••',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Implement forgot password
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          _buildGradientButton(
            text: 'Login',
            colors: [Colors.blue.shade600, Colors.blue.shade400],
            onPressed: _isLoading ? null : _userLogin,
          ),
          SizedBox(height: 20),
          _buildDemoCredentials(
            'Demo Customer Account',
            'Email: user1@example.com\nPassword: user123',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _userRegFormKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildTextField(
              controller: _regNameController,
              label: 'Full Name',
              hint: 'John Doe',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _regEmailController,
              label: 'Email',
              hint: 'your@email.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _regPasswordController,
              label: 'Password',
              hint: '••••••••',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _regConfirmPasswordController,
              label: 'Confirm Password',
              hint: '••••••••',
              icon: Icons.lock_outline,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _regPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            SizedBox(height: 24),
            _buildGradientButton(
              text: 'Create Account',
              colors: [Colors.blue.shade600, Colors.blue.shade400],
              onPressed: _isLoading ? null : _userRegister,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminForm() {
    return Form(
      key: _adminFormKey,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade50, Colors.purple.shade100],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.purple.shade700, size: 24),
                SizedBox(width: 12),
                Text(
                  'Admin Access',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          _buildTextField(
            controller: _adminEmailController,
            label: 'Admin Email',
            hint: 'admin@apptechvibe.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            color: Colors.purple,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter admin email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          _buildTextField(
            controller: _adminPasswordController,
            label: 'Password',
            hint: '••••••••',
            icon: Icons.lock_outline,
            color: Colors.purple,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 30),
          _buildGradientButton(
            text: 'Login as Admin',
            colors: [Colors.purple.shade600, Colors.purple.shade400],
            onPressed: _isLoading ? null : _adminLogin,
          ),
          SizedBox(height: 20),
          _buildDemoCredentials(
            'Admin Credentials',
            'Email: admin@apptechvibe.com\nPassword: admin123',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    Color color = Colors.blue,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: color is MaterialColor ? color.shade700 : color,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: color is MaterialColor ? color.shade700 : color,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: validator,
    );
  }

  Widget _buildGradientButton({
    required String text,
    required List<Color> colors,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildDemoCredentials(String title, String credentials, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: (color is MaterialColor)
              ? [color.shade50, color.shade100]
              : [color.withOpacity(0.1), color.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (color is MaterialColor) ? color.shade200 : color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: (color is MaterialColor) ? color.shade700 : color,
              ),
              SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: (color is MaterialColor) ? color.shade700 : color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            credentials,
            style: TextStyle(
              fontSize: 11,
            color: (color is MaterialColor) ? color.shade700 : color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}