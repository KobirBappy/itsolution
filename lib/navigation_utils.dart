import 'package:flutter/material.dart';

import 'unified_login.dart';


class NavigationUtils {
  /// Show login popup instead of navigating to login page
  static void showLogin(BuildContext context) {
    LoginPopupModal.show(context);
  }
  
  /// Helper method to handle login navigation
  /// Use this to replace any Navigator.pushNamed(context, '/unified-login') calls
  static void navigateToLogin(BuildContext context) {
    LoginPopupModal.show(context);
  }
  
  /// Handle navigation with login check
  static void navigateWithLoginCheck(BuildContext context, String route, {bool requiresLogin = false}) {
    if (requiresLogin) {
      // Show login popup first
      LoginPopupModal.show(context);
    } else {
      Navigator.pushNamed(context, route);
    }
  }
}