import 'package:novamart/features/seller/edit_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:novamart/services/seller_dashboard_service.dart';

class MyProductsScreen extends StatelessWidget {
  MyProductsScreen({super.key});

  final service = SellerDashboardService();

  final sellerId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Products"),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: service.streamSellerProducts(sellerId),

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
                "No Products Added Yet",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final products = snapshot.data!.docs;

          return ListView.builder(

            padding: const EdgeInsets.all(12),

            itemCount: products.length,

            itemBuilder: (context, index) {

              final product = products[index];

              return Card(

                margin: const EdgeInsets.only(
                  bottom: 12,
                ),

                child: ListTile(

                  onTap: () {

  Navigator.push(

    context,

    MaterialPageRoute(

      builder: (_) => EditProductScreen(

        // product: product.data()
        //     as Map<String, dynamic>,

        product: {
  ...(product.data()
      as Map<String, dynamic>),

  'id': product.id,
},
      ),
    ),
  );
},

                  contentPadding:
                      const EdgeInsets.all(10),

                  leading: ClipRRect(

                    borderRadius:
                        BorderRadius.circular(8),

                    child: Image.network(
                      product['imageUrl'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),

                  title: Text(
                    product['name'],
                  ),

                  subtitle: Text(
                    "₹${product['price']}",
                  ),

                  trailing: IconButton(

  icon: const Icon(
    Icons.delete,
    color: Colors.red,
  ),

  onPressed: () async {

    await service.deleteProduct(
      product.id,
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        content: Text(
          "Product Deleted",
        ),
      ),
    );
  },
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