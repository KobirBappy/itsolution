import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  late TabController _tabController;
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  
  // Profile controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  
  // Password controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Address controllers
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  
  String? _profileImageUrl;
  Uint8List? _imageData;
  
  List<Map<String, dynamic>> _addresses = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }
  
  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 768;
  
  Future<void> _loadUserData() async {
    if (_auth.currentUser == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data()!;
        _nameController.text = data['name'] ?? _auth.currentUser!.displayName ?? '';
        _emailController.text = _auth.currentUser!.email ?? '';
        _phoneController.text = data['phone'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _profileImageUrl = data['profileImage'];
        
        // Load addresses
        final addressesSnapshot = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('addresses')
            .get();
        
        _addresses = addressesSnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageData = bytes;
      });
    }
  }
  
  Future<String?> _uploadImage() async {
    if (_imageData == null) return _profileImageUrl;
    
    try {
      final ref = _storage
          .ref()
          .child('users')
          .child(_auth.currentUser!.uid)
          .child('profile.jpg');
      
      final uploadTask = ref.putData(_imageData!);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
  
  Future<void> _updateProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Upload image if changed
      final imageUrl = await _uploadImage();
      
      // Update display name
      await _auth.currentUser!.updateDisplayName(_nameController.text.trim());
      
      // Update Firestore
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'bio': _bioController.text.trim(),
        'profileImage': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: _auth.currentUser!.email!,
        password: _currentPasswordController.text,
      );
      
      await _auth.currentUser!.reauthenticateWithCredential(credential);
      
      // Update password
      await _auth.currentUser!.updatePassword(_newPasswordController.text);
      
      // Clear fields
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password changed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Error changing password';
      if (e.code == 'wrong-password') {
        message = 'Current password is incorrect';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _saveAddress({String? addressId}) async {
    if (!_addressFormKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final addressData = {
        'addressLine1': _addressLine1Controller.text.trim(),
        'addressLine2': _addressLine2Controller.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zip': _zipController.text.trim(),
        'country': _countryController.text.trim(),
        'isDefault': _addresses.isEmpty,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (addressId != null) {
        // Update existing address
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('addresses')
            .doc(addressId)
            .update(addressData);
      } else {
        // Add new address
        addressData['createdAt'] = FieldValue.serverTimestamp();
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('addresses')
            .add(addressData);
      }
      
      // Reload addresses
      await _loadUserData();
      
      // Clear form
      _clearAddressForm();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(addressId != null ? 'Address updated' : 'Address added'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving address'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _clearAddressForm() {
    _addressLine1Controller.clear();
    _addressLine2Controller.clear();
    _cityController.clear();
    _stateController.clear();
    _zipController.clear();
    _countryController.clear();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile Settings',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue.shade700,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.blue.shade700,
          tabs: [
            Tab(text: 'Profile', icon: Icon(Icons.person)),
            Tab(text: 'Security', icon: Icon(Icons.lock)),
            Tab(text: 'Addresses', icon: Icon(Icons.location_on)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
          _buildSecurityTab(),
          _buildAddressesTab(),
        ],
      ),
    );
  }
  
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _profileFormKey,
        child: Column(
          children: [
            // Profile Image
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _imageData != null
                        ? MemoryImage(_imageData!)
                        : _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!) as ImageProvider
                            : null,
                    child: (_imageData == null && _profileImageUrl == null)
                        ? Icon(Icons.person, size: 60, color: Colors.grey.shade400)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            
            // Email Field (Read-only)
            TextFormField(
              controller: _emailController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            SizedBox(height: 20),
            
            // Phone Field
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            
            // Bio Field
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Bio',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.info),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber.shade700),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Use a strong password with at least 8 characters, including uppercase, lowercase, numbers, and symbols.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          
          Form(
            key: _passwordFormKey,
            child: Column(
              children: [
                // Current Password
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                
                // New Password
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                
                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                
                // Change Password Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                            'Change Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 40),
          
          // Two-Factor Authentication Section
          Text(
            'Two-Factor Authentication',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.security, color: Colors.grey.shade600),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2FA Not Enabled',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Add an extra layer of security',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Implement 2FA setup
                  },
                  child: Text('Enable'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddressesTab() {
    return Column(
      children: [
        // Add Address Button
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showAddressDialog(),
              icon: Icon(Icons.add),
              label: Text('Add New Address'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        
        // Addresses List
        Expanded(
          child: _addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 60,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No addresses saved',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add an address for faster checkout',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    return _buildAddressCard(address);
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildAddressCard(Map<String, dynamic> address) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: address['isDefault'] == true
              ? Colors.blue.shade200
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          if (address['isDefault'] == true)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
              ),
              child: Center(
                child: Text(
                  'Default Address',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, color: Colors.grey.shade600),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address['addressLine1'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (address['addressLine2']?.isNotEmpty ?? false)
                            Text(
                              address['addressLine2'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          SizedBox(height: 4),
                          Text(
                            '${address['city']}, ${address['state']} ${address['zip']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            address['country'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    if (address['isDefault'] != true)
                      TextButton(
                        onPressed: () async {
                          // Set as default
                          await _firestore
                              .collection('users')
                              .doc(_auth.currentUser!.uid)
                              .collection('addresses')
                              .get()
                              .then((snapshot) {
                            for (var doc in snapshot.docs) {
                              doc.reference.update({'isDefault': false});
                            }
                          });
                          
                          await _firestore
                              .collection('users')
                              .doc(_auth.currentUser!.uid)
                              .collection('addresses')
                              .doc(address['id'])
                              .update({'isDefault': true});
                          
                          await _loadUserData();
                        },
                        child: Text('Set as Default'),
                      ),
                    if (address['isDefault'] != true) SizedBox(width: 16),
                    TextButton(
                      onPressed: () => _showAddressDialog(address: address),
                      child: Text('Edit'),
                    ),
                    SizedBox(width: 16),
                    TextButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Address'),
                            content: Text('Are you sure you want to delete this address?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirm == true) {
                          await _firestore
                              .collection('users')
                              .doc(_auth.currentUser!.uid)
                              .collection('addresses')
                              .doc(address['id'])
                              .delete();
                          
                          await _loadUserData();
                        }
                      },
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAddressDialog({Map<String, dynamic>? address}) {
    if (address != null) {
      _addressLine1Controller.text = address['addressLine1'] ?? '';
      _addressLine2Controller.text = address['addressLine2'] ?? '';
      _cityController.text = address['city'] ?? '';
      _stateController.text = address['state'] ?? '';
      _zipController.text = address['zip'] ?? '';
      _countryController.text = address['country'] ?? '';
    } else {
      _clearAddressForm();
    }
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _addressFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address != null ? 'Edit Address' : 'Add New Address',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),
                  TextFormField(
                    controller: _addressLine1Controller,
                    decoration: InputDecoration(
                      labelText: 'Address Line 1',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _addressLine2Controller,
                    decoration: InputDecoration(
                      labelText: 'Address Line 2 (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _stateController,
                          decoration: InputDecoration(
                            labelText: 'State',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _zipController,
                          decoration: InputDecoration(
                            labelText: 'ZIP Code',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _countryController,
                          decoration: InputDecoration(
                            labelText: 'Country',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_addressFormKey.currentState!.validate()) {
                                  Navigator.pop(context);
                                  await _saveAddress(
                                    addressId: address?['id'],
                                  );
                                }
                              },
                        child: Text(address != null ? 'Update' : 'Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}