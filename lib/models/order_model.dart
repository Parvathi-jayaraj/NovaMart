
import 'package:cloud_firestore/cloud_firestore.dart';
class OrderModel {
  final String orderId;
  final String buyerId;
  final String sellerId;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final String paymentMethod;
final String customerName;
final String phoneNumber;
final String address;

  OrderModel({
    required this.orderId,
    required this.buyerId,
    required this.sellerId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.paymentMethod,
  required this.customerName,
  required this.phoneNumber,
  required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'sellerId': sellerId,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt,
      'paymentMethod': paymentMethod,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'address': address,
    };
  }

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      orderId: id,
      buyerId: map['buyerId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      paymentMethod: map['paymentMethod'] ?? '',
      customerName: map['customerName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
    );
  }
}