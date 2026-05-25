

// import '../core/constants/order_status.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import '../models/order_model.dart';

// class OrderService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // ✅ CREATE ORDER (BUY NOW + CART)
//   Future<void> placeOrder({
//     required String sellerId,
//     required String productId,
//     required String productName,
//     required String productImage,
//     required double price,
//     required int quantity,
//      required String paymentMethod,
//   required String customerName,
//   required String phoneNumber,
//   required String address,
//   }) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;

//       if (user == null) {
//         throw Exception("User not logged in");
//       }

//       final orderRef = _firestore.collection('orders').doc();

//       double totalAmount = price * quantity;

//       OrderModel order = OrderModel(
//         orderId: orderRef.id,
//         buyerId: user.uid,
//         sellerId: sellerId,
//         productId: productId,
//         productName: productName,
//         productImage: productImage,
//         price: price,
//         quantity: quantity,
//         totalAmount: totalAmount,
//         //status: 'pending',
//         status: OrderStatus.pending,
//         createdAt: DateTime.now(),
        
//       );

//       await orderRef.set(order.toMap());
//     } catch (e) {
//       throw Exception(e.toString());
//     }
//   }

//   // 🔥 STEP 7.2 — SAFE STATUS UPDATE (STATE MACHINE)
//   Future<void> updateOrderStatus({
//     required String orderId,
//     required String currentStatus,
//     required String newStatus,
//   }) async {

//     // 🧠 Allowed transitions (CORE LOGIC)
//     final Map<String, List<String>> allowedTransitions = {
//       //'pending': ['confirmed', 'rejected'],
//       OrderStatus.pending: [
//   OrderStatus.confirmed,
//   OrderStatus.rejected,
// ],
//       //'confirmed': ['shipped'],
//        OrderStatus.confirmed: [
//     OrderStatus.shipped,
//   ],
//       // 'shipped': ['delivered'],
//       // 'delivered': [],
//       // 'rejected': [],
//        OrderStatus.shipped: [
//     OrderStatus.delivered,
//   ],

//   OrderStatus.delivered: [],

//   OrderStatus.rejected: [],
//     };

//     final allowedNext = allowedTransitions[currentStatus] ?? [];

//     // ❌ BLOCK INVALID MOVES
//     if (!allowedNext.contains(newStatus)) {
//       throw Exception(
//         "Invalid status transition: $currentStatus → $newStatus",
//       );
//     }

//     await _firestore.collection('orders').doc(orderId).update({
//       'status': newStatus,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   }
// }
import '../core/constants/order_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ CREATE ORDER (BUY NOW + CHECKOUT)
  Future<void> placeOrder({
    required String sellerId,
    required String productId,
    required String productName,
    required String productImage,
    required double price,
    required int quantity,

    // 🆕 CHECKOUT FIELDS
    required String paymentMethod,
    required String customerName,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      final orderRef = _firestore.collection('orders').doc();

      double totalAmount = price * quantity;

      // ✅ COMPLETE ORDER MODEL
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
        status: OrderStatus.pending,
        createdAt: DateTime.now(),

        // 🆕 NEW CHECKOUT DATA
        paymentMethod: paymentMethod,
        customerName: customerName,
        phoneNumber: phoneNumber,
        address: address,
      );

      await orderRef.set(order.toMap());

    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // 🚀 STEP 7 — SAFE STATUS UPDATE
  Future<void> updateOrderStatus({
    required String orderId,
    required String currentStatus,
    required String newStatus,
  }) async {

    // ✅ ALLOWED STATUS FLOW
    final Map<String, List<String>> allowedTransitions = {

      OrderStatus.pending: [
        OrderStatus.confirmed,
        OrderStatus.rejected,
      ],

      OrderStatus.confirmed: [
        OrderStatus.shipped,
      ],

      OrderStatus.shipped: [
        OrderStatus.delivered,
      ],

      OrderStatus.delivered: [],

      OrderStatus.rejected: [],
    };

    final allowedNext = allowedTransitions[currentStatus] ?? [];

    // ❌ BLOCK INVALID STATUS CHANGES
    if (!allowedNext.contains(newStatus)) {
      throw Exception(
        "Invalid status transition: $currentStatus → $newStatus",
      );
    }

    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}