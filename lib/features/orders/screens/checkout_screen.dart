import '../../../models/cart_model.dart';
import 'package:flutter/material.dart';
import '../../../services/order_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class CheckoutScreen extends StatefulWidget {
  final String? productName;
final String? productImage;
final int? quantity;
final double? totalAmount;
final String? sellerId;
final String? productId;
final List<CartModel>? cartItems;

  const CheckoutScreen({
  super.key,

  this.productName,
  this.productImage,
  this.quantity,
  this.totalAmount,
 this.sellerId,
  this.productId,
  this.cartItems,
});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // 🧠 CONTROLLERS
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  // 💳 PAYMENT METHOD
  String selectedPaymentMethod = "Cash on Delivery";

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // 🚀 STEP 8.5 — PAY NOW LOGIC
  Future<void> _handlePayment() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();

    // 1. VALIDATION
    if (name.isEmpty || phone.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all address fields")),
      );
      return;
    }

    try {
      // 2. CREATE ORDER
      // await OrderService().placeOrder(
      //   sellerId: "unknown", // we improve in cart/multi-item step
      //   productId: "single_product",
      //   productName: widget.productName ?? '',
      //   productImage:widget.productImage ?? '',
      //   price: widget.totalAmount ?? 0,
      //   quantity: widget.quantity ?? 1,

      //   // ✅ NEW FIELDS (must exist in OrderService)
      //   paymentMethod: selectedPaymentMethod,
      //   customerName: name,
      //   phoneNumber: phone,
      //   address: address,
      // );
      /// 🛒 CART CHECKOUT
if (widget.cartItems != null &&
    widget.cartItems!.isNotEmpty) {

  for (var item in widget.cartItems!) {

    await OrderService().placeOrder(
      sellerId: item.sellerId,
      productId: item.productId,
      productName: item.productName,
      productImage: item.productImage,
      price: item.productPrice,
      quantity: item.quantity,

      paymentMethod: selectedPaymentMethod,
      customerName: name,
      phoneNumber: phone,
      address: address,
    );
  }
  /// 🧹 CLEAR CART AFTER SUCCESSFUL CHECKOUT
for (var item in widget.cartItems!) {

  await FirebaseFirestore.instance
      .collection('cart')
      .doc(item.cartId)
      .delete();
}

}

/// ⚡ BUY NOW CHECKOUT
else {

  await OrderService().placeOrder(
    sellerId:  widget.sellerId ?? '',
    productId: widget.productId ?? '',
    productName: widget.productName ?? '',
    productImage: widget.productImage ?? '',
    price: widget.totalAmount ?? 0,
    quantity: widget.quantity ?? 1,

    paymentMethod: selectedPaymentMethod,
    customerName: name,
    phoneNumber: phone,
    address: address,
  );
}

      // 3. SUCCESS MESSAGE
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully")),
      );

      // 4. NAVIGATE BACK TO HOME
      Navigator.popUntil(context, (route) => route.isFirst);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Order failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🧾 ORDER SUMMARY
            /// /// 🧾 ORDER SUMMARY
const Text(
  "Order Summary",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 12),

// 🛒 MULTI-CART MODE
if (widget.cartItems != null && widget.cartItems!.isNotEmpty)

  Column(
    children: widget.cartItems!.map((item) {

      return Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Row(
            children: [

              /// PRODUCT IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.productImage,
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 12),

              /// DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      item.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Qty: ${item.quantity}",
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "₹${item.productPrice}",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              /// ITEM TOTAL
              Text(
                "₹${(item.productPrice * item.quantity).toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );

    }).toList(),
  )

// ⚡ SINGLE PRODUCT MODE
else

  Card(
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),

    child: Padding(
      padding: const EdgeInsets.all(12),

      child: Row(
        children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              widget.productImage ?? '',
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  widget.productName ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Quantity: ${widget.quantity ?? 1}",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 6),

                Text(
                  "Price per item: ₹${((widget.totalAmount ?? 0) / (widget.quantity ?? 1)).toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          Text(
            "₹${widget.totalAmount ?? 0}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    ),
  ),
            // Card(
            //   elevation: 3,
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Padding(
            //     padding: const EdgeInsets.all(12),
            //     child: Row(
            //       children: [

            //         ClipRRect(
            //           borderRadius: BorderRadius.circular(10),
            //           child: Image.network(
            //             widget.productImage,
            //             height: 80,
            //             width: 80,
            //             fit: BoxFit.cover,
            //           ),
            //         ),

            //         const SizedBox(width: 12),

            //         Expanded(
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [

            //               Text(
            //                 widget.productName,
            //                 style: const TextStyle(
            //                   fontSize: 16,
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               ),

            //               const SizedBox(height: 6),

            //               Text(
            //                 "Quantity: ${widget.quantity}",
            //                 style: const TextStyle(color: Colors.grey),
            //               ),

            //               const SizedBox(height: 6),

            //               Text(
            //                 "Price per item: ₹${(widget.totalAmount / widget.quantity).toStringAsFixed(2)}",
            //                 style: const TextStyle(color: Colors.grey),
            //               ),
            //             ],
            //           ),
            //         ),

            //         Text(
            //           "₹${widget.totalAmount}",
            //           style: const TextStyle(
            //             fontSize: 16,
            //             fontWeight: FontWeight.bold,
            //             color: Colors.green,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            const SizedBox(height: 20),

            /// 📍 ADDRESS SECTION
            const Text(
              "Delivery Address",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            /// 💳 PAYMENT METHOD
            const Text(
              "Payment Method",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            RadioListTile(
              title: const Text("Cash on Delivery"),
              value: "Cash on Delivery",
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value.toString();
                });
              },
            ),

            RadioListTile(
              title: const Text("UPI Payment"),
              value: "UPI",
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value.toString();
                });
              },
            ),

            RadioListTile(
              title: const Text("Card Payment"),
              value: "Card",
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value.toString();
                });
              },
            ),

            const SizedBox(height: 30),

            /// 🚀 PAY NOW BUTTON (FINAL)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handlePayment,
                child: const Text("Pay Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}