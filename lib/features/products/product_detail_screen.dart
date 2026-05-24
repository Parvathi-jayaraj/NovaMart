
import 'package:flutter/material.dart';
import '../../../services/order_service.dart';
import '../../models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../chat/chat_screen.dart';
import '../../models/cart_model.dart';
import '../../services/cart_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  ProductDetailScreen({
    super.key,
    required this.product,
  });

  final CartService _cartService = CartService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // Product Image
            SizedBox(
              height: 320,
              width: double.infinity,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.image, size: 80),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // Product Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Price
                  Text(
                    "₹${product.price}",
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Seller
                  Row(
                    children: [
                      const Icon(Icons.store),
                      const SizedBox(width: 8),
                      Text(
                        product.sellerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description Title
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Product Description
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Buttons Row (UPDATED)
                  Row(
                    children: [
                      
                      // Chat Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            final currentUser =
                                FirebaseAuth.instance.currentUser;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  receiverName: product.sellerName,
                                  buyerId: currentUser!.uid,
                                  sellerId: product.sellerId,
                                  productId: product.id,
                                ),
                              ),
                            );
                          },
                          child: const Text("Chat Seller"),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // BUY NOW Button (UNCHANGED)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              
                              await OrderService().placeOrder(
  sellerId: product.sellerId,
  productId: product.id,
  productName: product.name,
  productImage: product.imageUrl,
  price: product.price,
  quantity: 1, // ✅ REQUIRED FIX
);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Order placed successfully"),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                ),
                              );
                            }
                          },
                          child: const Text("Buy Now"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ADD TO CART BUTTON (NEW FEATURE)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text("Add to Cart"),

                      onPressed: () async {
                        final user =
                            FirebaseAuth.instance.currentUser;

                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please login first"),
                            ),
                          );
                          return;
                        }

                        final cartItem = CartModel(
                          cartId: DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(),
                          buyerId: user.uid,
                          productId: product.id,
                          sellerId: product.sellerId,
                          productName: product.name,
                          productImage: product.imageUrl,
                          productPrice: product.price,
                          quantity: 1,
                          createdAt: Timestamp.now(),
                        );

                        await _cartService.addToCart(
                          cartItem: cartItem,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Added to cart"),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}