import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ADD TO CART
  Future<void> addToCart({
    required CartModel cartItem,
  }) async {
    try {
      // CHECK IF PRODUCT ALREADY EXISTS IN CART
      final query = await _firestore
          .collection('cart')
          .where('buyerId', isEqualTo: cartItem.buyerId)
          .where('productId', isEqualTo: cartItem.productId)
          .get();

      // IF PRODUCT ALREADY EXISTS
      if (query.docs.isNotEmpty) {
        final existingDoc = query.docs.first;

        int currentQuantity = existingDoc['quantity'];

        await existingDoc.reference.update({
          'quantity': currentQuantity + 1,
        });
      }

      // IF PRODUCT DOES NOT EXIST
      else {
        await _firestore
            .collection('cart')
            .doc(cartItem.cartId)
            .set(cartItem.toMap());
      }
    } catch (e) {
      print('Add to cart error: $e');
    }
  }

  // GET CART ITEMS
  Stream<List<CartModel>> getCartItems(String buyerId) {
    return _firestore
        .collection('cart')
        .where('buyerId', isEqualTo: buyerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CartModel.fromMap(doc.data());
      }).toList();
    });
  }

  Future<void> updateQuantity({
  required String cartId,
  required int quantity,
}) async {
  try {
    await _firestore.collection('cart').doc(cartId).update({
      'quantity': quantity,
    });
  } catch (e) {
    print("Update quantity error: $e");
  }
}

Future<void> deleteCartItem(String cartId) async {
  try {
    await _firestore.collection('cart').doc(cartId).delete();
  } catch (e) {
    print("Delete cart item error: $e");
  }
}
}