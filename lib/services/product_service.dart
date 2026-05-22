import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  Future<void> uploadProduct(ProductModel product) async {
    await firestore
        .collection('products')
        .doc(product.id)
        .set(product.toMap());
  }
}