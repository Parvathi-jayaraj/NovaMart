import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
  final String cartId;
  final String buyerId;
  final String productId;
  final String sellerId;
  final String productName;
  final String productImage;
  final double productPrice;
  final int quantity;
  final Timestamp createdAt;

  CartModel({
    required this.cartId,
    required this.buyerId,
    required this.productId,
    required this.sellerId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.quantity,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'cartId': cartId,
      'buyerId': buyerId,
      'productId': productId,
      'sellerId': sellerId,
      'productName': productName,
      'productImage': productImage,
      'productPrice': productPrice,
      'quantity': quantity,
      'createdAt': createdAt,
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      cartId: map['cartId'] ?? '',
      buyerId: map['buyerId'] ?? '',
      productId: map['productId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      productPrice: (map['productPrice'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}