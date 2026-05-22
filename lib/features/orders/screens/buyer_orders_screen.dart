import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BuyerOrdersScreen extends StatelessWidget {
  const BuyerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(

      appBar: AppBar(
        title: const Text("My Orders"),
      ),

      body: StreamBuilder(

        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('buyerId', isEqualTo: user!.uid)
            .snapshots(),

        builder: (context, snapshot) {

          // Loading
          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // No Orders
          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {

            return const Center(
              child: Text("No Orders Yet"),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(

            itemCount: orders.length,

            itemBuilder: (context, index) {

              final order = orders[index];

              return Card(

                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),

                child: ListTile(

                  leading: Image.network(
                    order['productImage'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),

                  title: Text(
                    order['productName'],
                  ),

                  subtitle: Text(
                    "Status: ${order['status']}",
                  ),

                  trailing: Text(
                    "₹${order['price']}",
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