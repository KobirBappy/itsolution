// Updated floating_chat_widget.dart - Fixed for both guest and authenticated users

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class FloatingChatWidget extends StatefulWidget {
  @override
  _FloatingChatWidgetState createState() => _FloatingChatWidgetState();
}

class _FloatingChatWidgetState extends State<FloatingChatWidget> 
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isExpanded = false;
  bool _isLoading = false;
  bool _hasNewMessages = false;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String? _chatId;
  String? _guestId;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
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
      curve: Curves.easeInOut,
    ));
    
    // Generate guest ID for non-authenticated users
    if (_auth.currentUser == null) {
      _guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    }
    
    _checkForNewMessages();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _checkForNewMessages() async {
    try {
      if (_auth.currentUser != null) {
        // For authenticated users
        final userChats = await _firestore
            .collection('support_chats')
            .where('userId', isEqualTo: _auth.currentUser!.uid)
            .where('hasUnreadMessages', isEqualTo: true)
            .limit(1)
            .get();
        
        if (userChats.docs.isNotEmpty) {
          setState(() {
            _hasNewMessages = true;
          });
        }
      }
    } catch (e) {
      print('Error checking for new messages: $e');
    }
  }
  
  Future<String> _getOrCreateChatId() async {
    if (_chatId != null) return _chatId!;
    
    try {
      if (_auth.currentUser != null) {
        // For authenticated users
        final userId = _auth.currentUser!.uid;
        final existingChat = await _firestore
            .collection('support_chats')
            .where('userId', isEqualTo: userId)
            .where('status', isEqualTo: 'active')
            .limit(1)
            .get();
        
        if (existingChat.docs.isNotEmpty) {
          _chatId = existingChat.docs.first.id;
        } else {
          // Create new chat for authenticated user
          final newChat = await _firestore.collection('support_chats').add({
            'userId': userId,
            'userEmail': _auth.currentUser!.email,
            'userName': _auth.currentUser!.displayName ?? _auth.currentUser!.email?.split('@')[0] ?? 'User',
            'isGuestChat': false,
            'status': 'active',
            'createdAt': FieldValue.serverTimestamp(),
            'lastMessageAt': FieldValue.serverTimestamp(),
            'hasUnreadMessages': false,
          });
          _chatId = newChat.id;
        }
      } else {
        // For guest users - create session-based chat
        final newChat = await _firestore.collection('support_chats').add({
          'guestId': _guestId,
          'userEmail': 'guest@temp.com',
          'userName': 'Guest User',
          'isGuestChat': true,
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessageAt': FieldValue.serverTimestamp(),
          'hasUnreadMessages': false,
        });
        _chatId = newChat.id;
      }
    } catch (e) {
      print('Error creating chat: $e');
      // Fallback: create a temporary chat ID
      _chatId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    }
    
    return _chatId!;
  }
  
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      final chatId = await _getOrCreateChatId();
      final message = _messageController.text.trim();
      
      // Add message to chat
      await _firestore
          .collection('support_chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'message': message,
        'senderId': _auth.currentUser?.uid ?? _guestId ?? 'guest',
        'senderName': _auth.currentUser?.displayName ?? 'Guest User',
        'senderType': 'user',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
      
      // Update chat last message
      await _firestore.collection('support_chats').doc(chatId).update({
        'lastMessage': message,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'hasUnreadMessages': true,
      });
      
      _messageController.clear();
      _scrollToBottom();
      
      // Auto-reply for demo
      _sendAutoReply(chatId);
      
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _sendAutoReply(String chatId) async {
    await Future.delayed(Duration(seconds: 2));
    
    try {
      final autoReplies = [
        "Thank you for contacting AppTech Vibe! We'll get back to you shortly.",
        "Hi! How can we help you today?",
        "Thanks for reaching out! Our team will respond within 24 hours.",
        "Hello! We're here to help with any questions about our services.",
      ];
      
      final reply = autoReplies[DateTime.now().millisecondsSinceEpoch % autoReplies.length];
      
      await _firestore
          .collection('support_chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'message': reply,
        'senderId': 'system',
        'senderName': 'AppTech Support',
        'senderType': 'admin',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
      
      await _firestore.collection('support_chats').doc(chatId).update({
        'lastMessage': reply,
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending auto-reply: $e');
    }
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _toggleChat() {
    setState(() {
      _isExpanded = !_isExpanded;
      _hasNewMessages = false;
    });
    
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Chat Window
          if (_isExpanded)
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: MediaQuery.of(context).size.width > 600 ? 350 : MediaQuery.of(context).size.width - 40,
                height: MediaQuery.of(context).size.height > 600 ? 500 : MediaQuery.of(context).size.height - 200,
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade700, Colors.blue.shade500],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.support_agent,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AppTech Support',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'We\'re online',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
                            onPressed: _toggleChat,
                          ),
                        ],
                      ),
                    ),
                    
                    // Messages
                    Expanded(
                      child: _buildMessagesArea(),
                    ),
                    
                    // Input Area
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'Type your message...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: null,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade700,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: _isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(Icons.send, color: Colors.white),
                              onPressed: _isLoading ? null : _sendMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Chat Button
          FloatingActionButton(
            onPressed: _toggleChat,
            backgroundColor: Colors.blue.shade700,
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    _isExpanded ? Icons.close : Icons.chat,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                if (_hasNewMessages && !_isExpanded)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessagesArea() {
    if (_chatId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 16),
            Text(
              'Start a conversation',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We\'re here to help!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            if (_auth.currentUser == null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You\'re chatting as a guest. Login for better support.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }
    
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('support_chats')
          .doc(_chatId)
          .collection('messages')
          .orderBy('timestamp')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
                SizedBox(height: 16),
                Text(
                  'Error loading messages',
                  style: TextStyle(color: Colors.red.shade600),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _chatId = null;
                    });
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        final messages = snapshot.data?.docs ?? [];
        
        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 60,
                  color: Colors.grey.shade300,
                ),
                SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Send a message to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }
        
        // Auto-scroll to bottom when new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
        
        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index].data() as Map<String, dynamic>;
            return _buildMessageBubble(message);
          },
        );
      },
    );
  }
  
  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['senderType'] == 'user';
    final timestamp = message['timestamp'] as Timestamp?;
    final time = timestamp != null 
        ? DateFormat('HH:mm').format(timestamp.toDate())
        : '';
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isUser ? 50 : 0,
          right: isUser ? 0 : 50,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue.shade700 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: isUser ? Radius.circular(4) : Radius.circular(18),
            bottomLeft: isUser ? Radius.circular(18) : Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['message'] ?? '',
              style: TextStyle(
                color: isUser ? Colors.white : Colors.grey.shade800,
                fontSize: 14,
              ),
            ),
            if (time.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: isUser ? Colors.white70 : Colors.grey.shade500,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}