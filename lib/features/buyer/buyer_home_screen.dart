

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../cart/cart_screen.dart';
import '../orders/screens/buyer_orders_screen.dart';
import '../../models/product_model.dart';
import '../../services/auth_service.dart';
import '../products/product_detail_screen.dart';
import '../chat/chat_list_screen.dart';
import 'buyer_profile_screen.dart';

class BuyerHomeScreen extends StatelessWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NovaMart'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,

        actions: [

//cart icon
 IconButton(
    icon: const Icon(Icons.shopping_cart),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CartScreen(),
        ),
      );
    },
  ),


          // Orders icon
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BuyerOrdersScreen(),
                ),
              );
            },
            icon: const Icon(Icons.shopping_bag),
          ),


          // Profile icon
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const BuyerProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),

      // ✅ FLOATING CHAT BUTTON (PROFESSIONAL UX)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>  ChatListScreen(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.chat),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

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
                    borderRadius:
                        BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Colors.black
                            .withOpacity(0.1),
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
                        padding:
                            const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

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

                            Text(
                              product.sellerName,
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    Colors.grey.shade600,
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