class OrderModel {
  final String orderId;
  final String buyerId;
  final String sellerId;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String status;

  OrderModel({
    required this.orderId,
    required this.buyerId,
    required this.sellerId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'status': status,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'],
      buyerId: map['buyerId'],
      sellerId: map['sellerId'],
      productId: map['productId'],
      productName: map['productName'],
      productImage: map['productImage'],
      price: map['price'].toDouble(),
      quantity: map['quantity'],
      status: map['status'],
    );
  }
}