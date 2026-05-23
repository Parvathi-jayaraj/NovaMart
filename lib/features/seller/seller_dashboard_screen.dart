import '../../services/auth_service.dart';
import 'package:flutter/material.dart';
import 'add_product_screen.dart';
import '../orders/screens/seller_orders_screen.dart';
import '../chat/chat_list_screen.dart';


class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,

         actions: [

          //chat
           IconButton(
    icon: const Icon(Icons.chat),

    onPressed: () {
      Navigator.push(
        context,

        MaterialPageRoute(
          builder: (_) => ChatListScreen(),
        ),
      );
    },
  ),
//orders
IconButton(
  onPressed: () {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const SellerOrdersScreen(),
      ),
    );

  },

  icon: const Icon(Icons.receipt_long),
),

//logout logo
    IconButton(
      icon: const Icon(Icons.logout),

      onPressed: () async {

        // Logout from Firebase
        await AuthService().logout();

        // Prevent widget issues
        if (!context.mounted) return;

        // Navigate back to login
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      },
    ),
  ],
      ),

      // body: const Center(
      //   child: Text(
      //     'Seller Dashboard Screen',
      //     style: TextStyle(
      //       fontSize: 22,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      // ),
      body: Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [

      const Text(
        'Seller Dashboard Screen',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 30),

      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductScreen(),
            ),
          );
        },
        child: const Text("Go To Add Product"),
      ),
    ],
  ),
),
    );
  }
}