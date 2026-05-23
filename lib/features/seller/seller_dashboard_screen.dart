// import '../../services/auth_service.dart';
// import 'package:flutter/material.dart';
// import 'add_product_screen.dart';
// import '../orders/screens/seller_orders_screen.dart';
// import '../chat/chat_list_screen.dart';
// import 'seller_profile_screen.dart';

// class SellerDashboardScreen extends StatelessWidget {
//   const SellerDashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Seller Dashboard'),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,

//          actions: [



// //orders
// IconButton(
//   onPressed: () {

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) =>
//             const SellerOrdersScreen(),
//       ),
//     );

//   },

//   icon: const Icon(Icons.receipt_long),
// ),

//     // Profile
//     IconButton(
//       icon: const Icon(Icons.person),
//       onPressed: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => const SellerProfileScreen(),
//           ),
//         );
//       },
//     ),


//   ],
//       ),

// floatingActionButton: FloatingActionButton(
//   onPressed: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) =>  ChatListScreen(),
//       ),
//     );
//   },
//   backgroundColor: Colors.blue,
//   child: const Icon(Icons.chat),
// ),

      
//       body: Center(
//   child: Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [

//       const Text(
//         'Seller Dashboard',
//         style: TextStyle(
//           fontSize: 22,
//           fontWeight: FontWeight.bold,
//         ),
//       ),

//       const SizedBox(height: 30),

//       ElevatedButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => const AddProductScreen(),
//             ),
//           );
//         },
//         child: const Text("Go To Add Product"),
//       ),
//     ],
//   ),
// ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:novamart/features/orders/screens/seller_orders_screen.dart';
import 'package:novamart/features/chat/chat_list_screen.dart';
import 'package:novamart/features/seller/seller_profile_screen.dart';
import 'package:novamart/features/seller/add_product_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:novamart/services/seller_dashboard_service.dart';

class SellerDashboardScreen extends StatelessWidget {
   SellerDashboardScreen({super.key});

  // =====================
  // DUMMY DASHBOARD DATA
  // =====================
  // final int totalProducts = 12;
  // final int pendingOrders = 3;
  // final int completedOrders = 25;
  // final double earnings = 12450;

  final service = SellerDashboardService();
final sellerId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // =====================
      // APPBAR
      // =====================
      appBar: AppBar(
        title: const Text("Seller Dashboard"),
        actions: [
  IconButton(
    icon: const Icon(Icons.person),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SellerProfileScreen(),
        ),
      );
    },
  ),

  // IconButton(
  //   icon: const Icon(Icons.receipt_long),
  //   onPressed: () {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => const SellerOrdersScreen(),
  //       ),
  //     );
  //   },
  // ),
],
      ),

      // =====================
      // BODY
      // =====================
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // =====================
              // STATS SECTION
              // =====================
const Text(
  "📊 Stats Overview",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 12),

FutureBuilder(
  future: Future.wait([
    service.getTotalProducts(sellerId),
    service.getPendingOrders(sellerId),
    service.getCompletedOrders(sellerId),
    service.getEarnings(sellerId),
  ]),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData) {
      return const Center(child: Text("No data found"));
    }

    final data = snapshot.data as List;

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      children: [
        _buildStatCard(
          "Total Products",
          "${data[0]}",
          Icons.inventory,
          Colors.blue,
        ),
        _buildStatCard(
          "Pending Orders",
          "${data[1]}",
          Icons.pending_actions,
          Colors.orange,
        ),
        _buildStatCard(
          "Completed Orders",
          "${data[2]}",
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          "Earnings",
          "₹${data[3]}",
          Icons.currency_rupee,
          Colors.purple,
        ),
      ],
    );
  },
),

const SizedBox(height: 25),


//               const Text(
//                 "📊 Stats Overview",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),

//               const SizedBox(height: 12),

//               GridView(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate:
//                     const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   childAspectRatio: 1.3,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                 ),
//                 children: [
//                   // _buildStatCard(
//                   //   "Total Products",
//                   //   "$totalProducts",
//                   //   Icons.inventory,
//                   //   Colors.blue,
//                   // ),
//                   // _buildStatCard(
//                   //   "Pending Orders",
//                   //   "$pendingOrders",
//                   //   Icons.pending_actions,
//                   //   Colors.orange,
//                   // ),
//                   // _buildStatCard(
//                   //   "Completed Orders",
//                   //   "$completedOrders",
//                   //   Icons.check_circle,
//                   //   Colors.green,
//                   // ),
//                   // _buildStatCard(
//                   //   "Earnings",
//                   //   "₹$earnings",
//                   //   Icons.currency_rupee,
//                   //   Colors.purple,
//                   // ),
//                   _buildStatCard(
//   "Total Products",
//   "${data[0]}",
//   Icons.inventory,
//   Colors.blue,
// ),

// _buildStatCard(
//   "Pending Orders",
//   "${data[1]}",
//   Icons.pending_actions,
//   Colors.orange,
// ),

// _buildStatCard(
//   "Completed Orders",
//   "${data[2]}",
//   Icons.check_circle,
//   Colors.green,
// ),

// _buildStatCard(
//   "Earnings",
//   "₹${data[3]}",
//   Icons.currency_rupee,
//   Colors.purple,
// ),
//                 ],
//               ),

//               const SizedBox(height: 25),

              // =====================
              // QUICK ACTIONS
              // =====================
              const Text(
                "⚡ Quick Actions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                children: [
                 
                  _buildActionCard("Add\nProduct", Icons.add, () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AddProductScreen()),
  );
}),

_buildActionCard("My\nProducts", Icons.inventory_2, () {}),

_buildActionCard("Orders", Icons.list_alt, () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SellerOrdersScreen()),
  );
}),

_buildActionCard("Chats", Icons.chat, () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) =>  ChatListScreen()),
  );
}),

_buildActionCard("Stats", Icons.bar_chart, () {}),

_buildActionCard("Settings", Icons.settings, () {}),
                ],
              ),

              const SizedBox(height: 25),

              // =====================
              // RECENT PRODUCTS
              // =====================
              const Text(
                "📦 Recent Products",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildProductCard("Shoes", "₹999"),
                    _buildProductCard("Watch", "₹1499"),
                    _buildProductCard("Bag", "₹799"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // =====================
      // FLOATING CHAT BUTTON
      // =====================
      floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>  ChatListScreen(),
      ),
    );
  },
  child: const Icon(Icons.chat),
),
    );
  }

  // =====================
  // STATS CARD WIDGET
  // =====================
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  // =====================
  // QUICK ACTION CARD
  // =====================
  Widget _buildActionCard(
  String title,
  IconData icon,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
  // Widget _buildActionCard(String title, IconData icon) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.grey.shade100,
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(icon, size: 28),
  //         const SizedBox(height: 8),
  //         Text(
  //           title,
  //           textAlign: TextAlign.center,
  //           style: const TextStyle(fontSize: 12),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // =====================
  // PRODUCT CARD
  // =====================
  Widget _buildProductCard(String name, String price) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image, size: 40),
          const SizedBox(height: 10),
          Text(name),
          Text(
            price,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}