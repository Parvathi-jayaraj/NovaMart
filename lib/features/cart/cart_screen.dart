
import '../../services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/cart_model.dart';
import '../../services/cart_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  final CartService _cartService = CartService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double calculateTotal(List<CartModel> items) {
    double total = 0;

    for (var item in items) {
      total += item.productPrice * item.quantity;
    }

    return total;
  }

  // ✅ FIXED CHECKOUT (FLAT ORDER STRUCTURE)
  Future<void> checkoutCart(
    List<CartModel> cartItems,
    String buyerId,
    BuildContext context,
  ) async {
    try {
      // CREATE ONE ORDER PER CART ITEM (NO NESTING)
      // for (var item in cartItems) {
      //   await FirebaseFirestore.instance.collection('orders').add({
      //     'buyerId': buyerId,
      //     'sellerId': item.sellerId,
      //     'productId': item.productId,
      //     'productName': item.productName,
      //     'productImage': item.productImage,
      //     'price': item.productPrice,
      //     'quantity': item.quantity,
      //     'totalAmount': item.productPrice * item.quantity,
      //     'status': 'pending',
      //     'createdAt': Timestamp.now(),
      //   });
      // }
      final orderService = OrderService();

for (var item in cartItems) {
  await orderService.placeOrder(
    sellerId: item.sellerId,
    productId: item.productId,
    productName: item.productName,
    productImage: item.productImage,
    price: item.productPrice,
    quantity: item.quantity,
  );
}

      // CLEAR CART
      for (var item in cartItems) {
        await FirebaseFirestore.instance
            .collection('cart')
            .doc(item.cartId)
            .delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Checkout failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
      ),

      body: user == null
          ? const Center(child: Text("Please login"))
          : StreamBuilder<List<CartModel>>(
              stream: _cartService.getCartItems(user.uid),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Your cart is empty"));
                }

                final cartItems = snapshot.data!;

                return Column(
                  children: [
                    
                    // CART LIST
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];

                          return Card(
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              leading: Image.network(
                                item.productImage,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),

                              title: Text(item.productName),

                              subtitle: Text(
                                "₹${item.productPrice} x ${item.quantity}",
                              ),

                              trailing: SizedBox(
                                width: 160,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    
                                    // MINUS
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () async {
                                        if (item.quantity > 1) {
                                          await _cartService.updateQuantity(
                                            cartId: item.cartId,
                                            quantity: item.quantity - 1,
                                          );
                                        }
                                      },
                                    ),

                                    Text(
                                      item.quantity.toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    // PLUS
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () async {
                                        await _cartService.updateQuantity(
                                          cartId: item.cartId,
                                          quantity: item.quantity + 1,
                                        );
                                      },
                                    ),

                                    // DELETE
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        final confirm = await showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("Remove Item"),
                                            content: const Text(
                                              "Do you want to remove this item from cart?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context, false),
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context, true),
                                                child: const Text(
                                                  "Delete",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          await _cartService
                                              .deleteCartItem(item.cartId);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // TOTAL + CHECKOUT
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            color: Colors.black12,
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          
                          // TOTAL
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total:",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                "₹${calculateTotal(cartItems).toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // CHECKOUT
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                await checkoutCart(
                                  cartItems,
                                  user.uid,
                                  context,
                                );
                              },
                              child: const Text("Proceed to Checkout"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}