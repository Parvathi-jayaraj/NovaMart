import 'package:cloud_firestore/cloud_firestore.dart';

class SellerDashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getTotalProducts(String sellerId) async {
    final snapshot = await _firestore
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .get();

    return snapshot.docs.length;
  }

  Future<int> getPendingOrders(String sellerId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .where('status', isEqualTo: 'pending')
        .get();

    return snapshot.docs.length;
  }

  Future<int> getCompletedOrders(String sellerId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .where('status', isEqualTo: 'delivered')
        .get();

    return snapshot.docs.length;
  }

  Future<double> getEarnings(String sellerId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .where('status', isEqualTo: 'delivered')
        .get();

    double total = 0;

    for (var doc in snapshot.docs) {
      total += (doc['price'] ?? 0);
    }

    return total;
  }
}