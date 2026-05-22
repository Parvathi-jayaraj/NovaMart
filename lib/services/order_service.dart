import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> placeOrder({
    required String sellerId,
    required String productId,
    required String productName,
    required String productImage,
    required double price,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      final orderRef = _firestore.collection('orders').doc();

      OrderModel order = OrderModel(
        orderId: orderRef.id,
        buyerId: user.uid,
        sellerId: sellerId,
        productId: productId,
        productName: productName,
        productImage: productImage,
        price: price,
        quantity: 1,
        status: 'pending',
      );

      await orderRef.set(order.toMap());
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  Future<void> updateOrderStatus({
  required String orderId,
  required String status,
}) async {

  await _firestore
      .collection('orders')
      .doc(orderId)
      .update({

    'status': status,

  });
}
}