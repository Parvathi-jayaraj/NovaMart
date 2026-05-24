

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ CREATE ORDER (USED BY BUY NOW + CART)
  Future<void> placeOrder({
    required String sellerId,
    required String productId,
    required String productName,
    required String productImage,
    required double price,
    required int quantity,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      final orderRef = _firestore.collection('orders').doc();

      double totalAmount = price * quantity;

      OrderModel order = OrderModel(
        orderId: orderRef.id,
        buyerId: user.uid,
        sellerId: sellerId,
        productId: productId,
        productName: productName,
        productImage: productImage,
        price: price,
        quantity: quantity,
        totalAmount: totalAmount,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await orderRef.set(order.toMap());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ✅ UPDATE ORDER STATUS
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