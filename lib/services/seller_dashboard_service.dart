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

  Future<void> deleteProduct(
  String productId,
) async {

  await _firestore
      .collection('products')
      .doc(productId)
      .delete();
}



Future<void> updateProduct({

  required String productId,

  required String name,

  required String description,

  required double price,

  required String imageUrl,

}) async {

  await _firestore
      .collection('products')
      .doc(productId)
      .update({

    'name': name,
    'description': description,
    'price': price,
    'imageUrl': imageUrl,
  });
}

    // REALTIME TOTAL PRODUCTS
  Stream<int> streamTotalProducts(String sellerId) {
    return _firestore
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // REALTIME PENDING ORDERS
  Stream<int> streamPendingOrders(String sellerId) {
    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // REALTIME COMPLETED ORDERS
  Stream<int> streamCompletedOrders(String sellerId) {
    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .where('status', isEqualTo: 'delivered')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // REALTIME EARNINGS
  Stream<double> streamEarnings(String sellerId) {
    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .where('status', isEqualTo: 'delivered')
        .snapshots()
        .map((snapshot) {

      double total = 0;

      for (var doc in snapshot.docs) {
        total += (doc['price'] ?? 0);
      }

      return total;
    });
  }

  Stream<QuerySnapshot> streamRecentProducts(
  String sellerId,
) {
  return _firestore
      .collection('products')
      .where('sellerId', isEqualTo: sellerId)
      .orderBy('createdAt', descending: true)
      .limit(5)
      .snapshots();
}

Stream<QuerySnapshot> streamSellerProducts(
  String sellerId,
) {
  return _firestore
      .collection('products')
      .where('sellerId', isEqualTo: sellerId)
      .orderBy('createdAt', descending: true)
      .snapshots();
}
}