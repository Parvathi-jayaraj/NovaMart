

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/order_service.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Seller Orders"),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('sellerId', isEqualTo: user!.uid)
            .snapshots(),

        builder: (context, snapshot) {
          
          // LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // EMPTY STATE
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Orders Yet"));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,

            itemBuilder: (context, index) {
              final doc = orders[index];

              // ✅ SAFE DATA PARSING (IMPORTANT FIX)
              final data = doc.data() as Map<String, dynamic>;

              final orderId = doc.id;
              final image = data['productImage'] ?? '';
              final name = data['productName'] ?? 'No Name';
              final status = data['status'] ?? 'pending';
              final price = data['price'] ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),

                child: ListTile(
                  leading: image.isNotEmpty
                      ? Image.network(
                          image,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image, size: 50),

                  title: Text(name),

                  subtitle: Text("Status: $status"),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      
                      // PRICE
                      Text("₹$price"),

                      const SizedBox(width: 10),

                      // STATUS MENU
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          await OrderService().updateOrderStatus(
                            orderId: orderId,
                            status: value,
                          );
                        },

                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'confirmed',
                            child: Text('Confirm'),
                          ),
                          PopupMenuItem(
                            value: 'shipped',
                            child: Text('Shipped'),
                          ),
                          PopupMenuItem(
                            value: 'delivered',
                            child: Text('Delivered'),
                          ),
                        ],
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