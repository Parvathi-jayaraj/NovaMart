// import '../../services/auth_service.dart';
// import 'package:flutter/material.dart';



// class BuyerHomeScreen extends StatelessWidget {
//   const BuyerHomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//   title: const Text('NovaMart Buyer'),
//   backgroundColor: Colors.blue,
//   foregroundColor: Colors.white,

//   actions: [

//     IconButton(
//       icon: const Icon(Icons.logout),

//       onPressed: () async {

//         // Logout from Firebase
//         await AuthService().logout();

//         // Prevent widget issues
//         if (!context.mounted) return;

//         // Navigate back to login
//         Navigator.pushNamedAndRemoveUntil(
//           context,
//           '/login',
//           (route) => false,
//         );
//       },
//     ),
//   ],
// ),

//       body: const Center(
//         child: Text(
//           'Buyer Home Screen',
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../orders/screens/buyer_orders_screen.dart';
import '../../models/product_model.dart';
import '../../services/auth_service.dart';
import '../products/product_detail_screen.dart';
import '../chat/chat_list_screen.dart';

class BuyerHomeScreen extends StatelessWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NovaMart Buyer'),
        backgroundColor: Colors.blue,
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


          //cart logo
          IconButton(
      onPressed: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const BuyerOrdersScreen(),
          ),
        );

      },

      icon: const Icon(Icons.shopping_bag),
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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {

          // Loading State
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // No Products Found
          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Products Found",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          final products = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(12),

            itemCount: products.length,

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),

            itemBuilder: (context, index) {

              final productData =
                  products[index].data()
                      as Map<String, dynamic>;

              final product =
                  ProductModel.fromMap(productData);

              //return Container(
              return GestureDetector(

  onTap: () {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) => ProductDetailScreen(
          product: product,
        ),
      ),
    );
  },

  child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),

                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // Product Image
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),

                        child: Image.network(
                          product.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,

                          errorBuilder:
                              (context, error, stackTrace) {

                            return const Center(
                              child: Icon(
                                Icons.image,
                                size: 50,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(10),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          // Product Name
                          Text(
                            product.name,

                            maxLines: 1,

                            overflow:
                                TextOverflow.ellipsis,

                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Product Price
                          Text(
                            "₹${product.price}",

                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.green,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Seller Name
                          Text(
                            product.sellerName,

                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
  ),
              );
            },
          );
        },
      ),
    );
  }
}