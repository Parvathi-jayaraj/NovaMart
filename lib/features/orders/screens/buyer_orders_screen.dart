


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/widgets/order_status_badge.dart';
import '../../../core/utils/order_status_utils.dart';
import '../../../core/constants/order_status.dart';

class BuyerOrdersScreen extends StatelessWidget {
  const BuyerOrdersScreen({super.key});

//tracking step method
Widget buildTrackingStep({
  required String title,
  required bool completed,
  required bool active,
}) {

  Color color;

  if (completed) {
    color = Colors.green;
  } else if (active) {
    color = Colors.orange;
  } else {
    color = Colors.grey.shade400;
  }

  return Row(
    crossAxisAlignment:
        CrossAxisAlignment.start,

    children: [

      // CIRCLE + LINE
      Column(
        children: [

          Container(
            width: 22,
            height: 22,

            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),

            child: Icon(
              completed
                  ? Icons.check
                  : Icons.circle,

              color: Colors.white,
              size: 14,
            ),
          ),

          // Container(
          //   width: 3,
          //   height: 35,
          //   color: color,
          // ),
          // HIDE LINE AFTER LAST STEP
title == "Order Delivered"
    ? const SizedBox()
    : Container(
        width: 3,
        height: 35,
        color: color,
      ),
        ],
      ),

      const SizedBox(width: 12),

      // TITLE
      Padding(
        padding: const EdgeInsets.only(
          top: 2,
        ),

        child: Text(
          title,

          style: TextStyle(
            color: color,
            fontWeight: active || completed
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    ],
  );
}

//timeline builder
Widget buildTrackingTimeline(
  String status,
) {

  return Column(
    children: [

      // ================= PLACED =================
      buildTrackingStep(
        title: "Order Placed",

        completed: true,

        active:
            status == OrderStatus.pending,
      ),

      // ================= CONFIRMED =================
      buildTrackingStep(
        title: "Order Confirmed",

        completed:
            status == OrderStatus.confirmed ||
            status == OrderStatus.shipped ||
            status == OrderStatus.delivered,

        active:
            status == OrderStatus.confirmed,
      ),

      // ================= SHIPPED =================
      buildTrackingStep(
        title: "Order Shipped",

        completed:
            status == OrderStatus.shipped ||
            status == OrderStatus.delivered,

        active:
            status == OrderStatus.shipped,
      ),

      // ================= DELIVERED =================
      buildTrackingStep(
        title: "Order Delivered",

        completed:
            status == OrderStatus.delivered,

        active:
            status == OrderStatus.delivered,
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(

      appBar: AppBar(
        title: const Text("My Orders"),
      ),

      body: StreamBuilder(

        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('buyerId', isEqualTo: user!.uid)
            .snapshots(),

        builder: (context, snapshot) {

          // ================= LOADING =================
          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ================= EMPTY =================
          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {

            return const Center(
              child: Text("No Orders Yet"),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(

            itemCount: orders.length,

            itemBuilder: (context, index) {

              final doc = orders[index];

              final data =
                  doc.data() as Map<String, dynamic>;

              final image =
                  data['productImage'] ?? '';

              final name =
                  data['productName'] ?? 'No Name';

              final status =
                  data['status'] ??
                      OrderStatus.pending;

              final price =
                  data['price'] ?? 0;

              final quantity =
                  data['quantity'] ?? 1;

              final Color statusColor =
                  OrderStatusUtils.getColor(
                status,
              );

              return Card(

                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),

                elevation: 3,

                child: Padding(
                  padding:
                      const EdgeInsets.all(12),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // ================= TOP ROW =================
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          // PRODUCT IMAGE
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),

                            child: image.isNotEmpty
                                ? Image.network(
                                    image,
                                    width: 65,
                                    height: 65,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.image,
                                    size: 60,
                                  ),
                          ),

                          const SizedBox(width: 12),

                          // PRODUCT DETAILS
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(
                                  name,

                                  style:
                                      const TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 5,
                                ),

                                Text(
                                  "₹$price",

                                  style:
                                      const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(
                                  height: 6,
                                ),

                                Text(
                                  "Qty: $quantity",

                                  style:
                                      const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // STATUS BADGE
                          OrderStatusBadge(
                            status: status,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ================= STATUS BAR =================
                      Container(
                        height: 5,
                        width: double.infinity,

                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),

                          color: statusColor,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ================= STATUS MESSAGE =================
                      Row(
                        children: [

                          Icon(
                            status ==
                                    OrderStatus
                                        .delivered
                                ? Icons.check_circle
                                : status ==
                                        OrderStatus
                                            .shipped
                                    ? Icons
                                        .local_shipping
                                    : status ==
                                            OrderStatus
                                                .confirmed
                                        ? Icons
                                            .inventory
                                        : status ==
                                                OrderStatus
                                                    .rejected
                                            ? Icons
                                                .cancel
                                            : Icons
                                                .access_time,

                            color: statusColor,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(

                              status ==
                                      OrderStatus
                                          .pending

                                  ? "Seller has not confirmed your order yet."

                                  : status ==
                                          OrderStatus
                                              .confirmed

                                      ? "Your order has been confirmed."

                                      : status ==
                                              OrderStatus
                                                  .shipped

                                          ? "Your order is on the way."

                                          : status ==
                                                  OrderStatus
                                                      .delivered

                                              ? "Order delivered successfully."

                                              : "Order was rejected by seller.",

                              style: TextStyle(
                                color: statusColor,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

// ================= TRACKING TIMELINE =================
if (status != OrderStatus.rejected)
  buildTrackingTimeline(status),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}