import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

import '../buyer/buyer_home_screen.dart';
import '../seller/seller_dashboard_screen.dart';

import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(

      // Listen to login/logout changes
      stream: AuthService().authStateChanges,

      builder: (context, snapshot) {

        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User NOT logged in
        if (!snapshot.hasData) {

          return const LoginScreen();
        }

        // User logged in
        return FutureBuilder(

          // Fetch Firestore user data
          future: AuthService().getUserData(),

          builder: (context, userSnapshot) {

            // Loading state
            if (userSnapshot.connectionState ==
                ConnectionState.waiting) {

              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // No user data
            if (!userSnapshot.hasData ||
                userSnapshot.data == null) {

              return const LoginScreen();
            }

            // Extract role
            final userData =
                userSnapshot.data as Map<String, dynamic>;

            final role = userData['role'];

            // Navigate based on role
            if (role == 'buyer') {

              return const BuyerHomeScreen();

            } else if (role == 'seller') {

              return  SellerDashboardScreen();
            }

            // Invalid role fallback
            return const LoginScreen();
          },
        );
      },
    );
  }
}