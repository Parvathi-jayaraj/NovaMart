import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/buyer/buyer_home_screen.dart';
import 'features/seller/seller_dashboard_screen.dart';
import 'features/auth/auth_wrapper.dart';
import 'features/seller/add_product_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const NovaMartApp());
}

class NovaMartApp extends StatelessWidget {
  const NovaMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NovaMart',
      home: const AuthWrapper(),
      routes: {
    '/login': (context) => const LoginScreen(),
    '/signup': (context) => const SignupScreen(),
    '/buyer-home': (context) => const BuyerHomeScreen(),
    '/seller-dashboard': (context) =>
        const SellerDashboardScreen(),
  },
    );
  }
}