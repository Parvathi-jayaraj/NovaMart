
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/order_status.dart';
import '../../../services/order_service.dart';
import '../../../core/widgets/order_status_badge.dart';
import '../../../core/utils/order_status_utils.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() =>
      _SellerOrdersScreenState();
}

class _SellerOrdersScreenState
    extends State<SellerOrdersScreen> {

  // ================= FILTER STATE =================
  String selectedFilter = 'all';

  String searchQuery = '';

  final TextEditingController searchController =
      TextEditingController();

//ADDED JUST NOW
final FocusNode searchFocusNode = FocusNode();
  // ================= DISPOSE =================
  @override
  void dispose() {
    searchController.dispose();
    //ADDED JUST NOW
    searchFocusNode.dispose();
    super.dispose();
  }

  // ================= DELIVERED EARNINGS =================
  double calculateDeliveredEarnings(
    List<QueryDocumentSnapshot> orders,
  ) {

    double total = 0;

    for (var doc in orders) {

      final data =
          doc.data() as Map<String, dynamic>;

      final status = data['status'];

      final totalAmount =
          (data['totalAmount'] ?? 0)
              .toDouble();

      if (status == OrderStatus.delivered) {
        total += totalAmount;
      }
    }

    return total;
  }

  // ================= PENDING EARNINGS =================
  double calculatePendingEarnings(
    List<QueryDocumentSnapshot> orders,
  ) {

    double total = 0;

    for (var doc in orders) {

      final data =
          doc.data() as Map<String, dynamic>;

      final status = data['status'];

      final totalAmount =
          (data['totalAmount'] ?? 0)
              .toDouble();

      if (status == OrderStatus.pending ||
          status == OrderStatus.confirmed ||
          status == OrderStatus.shipped) {

        total += totalAmount;
      }
    }

    return total;
  }

  // ================= FILTER LOGIC =================
  List<QueryDocumentSnapshot> filterOrders(
    List<QueryDocumentSnapshot> orders,
  ) {

    // ================= SEARCH FILTER =================
    List<QueryDocumentSnapshot> filteredOrders =
        orders.where((doc) {

      final data =
          doc.data() as Map<String, dynamic>;

      final productName =
          (data['productName'] ?? '')
              .toString()
              .toLowerCase();

      return productName.contains(
        searchQuery.toLowerCase(),
      );

    }).toList();

    // ================= STATUS FILTER =================
    if (selectedFilter == 'all') {
      return filteredOrders;
    }

    if (selectedFilter ==
        OrderStatus.pending) {

      return filteredOrders.where((doc) {

        final data =
            doc.data() as Map<String, dynamic>;

        return data['status'] ==
            OrderStatus.pending;

      }).toList();
    }

    if (selectedFilter == 'active') {

      return filteredOrders.where((doc) {

        final data =
            doc.data() as Map<String, dynamic>;

        return data['status'] ==
                OrderStatus.confirmed ||
            data['status'] ==
                OrderStatus.shipped;

      }).toList();
    }

    if (selectedFilter ==
        OrderStatus.delivered) {

      return filteredOrders.where((doc) {

        final data =
            doc.data() as Map<String, dynamic>;

        return data['status'] ==
            OrderStatus.delivered;

      }).toList();
    }

    if (selectedFilter ==
        OrderStatus.rejected) {

      return filteredOrders.where((doc) {

        final data =
            doc.data() as Map<String, dynamic>;

        return data['status'] ==
            OrderStatus.rejected;

      }).toList();
    }

    return filteredOrders;
  }

  // ================= FILTER CHIP =================
  Widget buildFilterChip(
    String value,
    String label,
  ) {

    final isSelected =
        selectedFilter == value;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
      ),

      child: ChoiceChip(
        label: Text(label),

        selected: isSelected,

        onSelected: (_) {
          setState(() {
            selectedFilter = value;
          });
        },
      ),
    );
  }

  // ================= ACTION BUTTONS =================
  Widget buildActionButtons({
    required BuildContext context,
    required String status,
    required String orderId,
  }) {

    Future<void> updateStatus(
      String newStatus,
    ) async {

      try {

        await OrderService()
            .updateOrderStatus(
          orderId: orderId,
          currentStatus: status,
          newStatus: newStatus,
        );

      } catch (e) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    // ================= PENDING =================
    if (status == OrderStatus.pending) {

      return Row(
        children: [

          Expanded(
            child: ElevatedButton(
              onPressed: () => updateStatus(
                OrderStatus.confirmed,
              ),

              child:
                  const Text("Accept Order"),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: ElevatedButton(
              onPressed: () => updateStatus(
                OrderStatus.rejected,
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),

              child: const Text("Reject"),
            ),
          ),
        ],
      );
    }

    // ================= CONFIRMED =================
    if (status ==
        OrderStatus.confirmed) {

      return SizedBox(
        width: double.infinity,

        child: ElevatedButton(
          onPressed: () => updateStatus(
            OrderStatus.shipped,
          ),

          child:
              const Text("Mark as Shipped"),
        ),
      );
    }

    // ================= SHIPPED =================
    if (status == OrderStatus.shipped) {

      return SizedBox(
        width: double.infinity,

        child: ElevatedButton(
          onPressed: () => updateStatus(
            OrderStatus.delivered,
          ),

          style:
              ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),

          child: const Text(
            "Mark as Delivered",
          ),
        ),
      );
    }

    // ================= DELIVERED =================
    if (status ==
        OrderStatus.delivered) {

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color:
              Colors.green.withOpacity(0.1),

          borderRadius:
              BorderRadius.circular(10),
        ),

        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              Icons.check_circle,
              color: Colors.green,
            ),

            SizedBox(width: 8),

            Text(
              "Order Completed",
              style: TextStyle(
                color: Colors.green,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // ================= REJECTED =================
    if (status ==
        OrderStatus.rejected) {

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color:
              Colors.red.withOpacity(0.1),

          borderRadius:
              BorderRadius.circular(10),
        ),

        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              Icons.cancel,
              color: Colors.red,
            ),

            SizedBox(width: 8),

            Text(
              "Order Rejected",
              style: TextStyle(
                color: Colors.red,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // ================= FALLBACK =================
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {

    final user =
        FirebaseAuth.instance.currentUser;

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Seller Orders",
        ),
      ),

      body: StreamBuilder(
//ADDED JUST NOW
stream: FirebaseFirestore.instance
    .collection('orders')
    .where(
      'sellerId',
      isEqualTo: user!.uid,
    )
    .snapshots(includeMetadataChanges: false),
        

        builder: (context, snapshot) {

          // ================= LOADING =================
          
          if (!snapshot.hasData) {

  return const Center(
    child:
        CircularProgressIndicator(),
  );
}

          // ================= EMPTY =================
          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {

            return const Center(
              child: Text("No Orders Yet"),
            );
          }

          final allOrders =
              snapshot.data!.docs;

          // ================= EARNINGS =================
          final deliveredEarnings =
              calculateDeliveredEarnings(
            allOrders,
          );

          final pendingEarnings =
              calculatePendingEarnings(
            allOrders,
          );

          // ================= FILTERED ORDERS =================
          final orders =
              filterOrders(allOrders);

          return Column(
            children: [

              // ================= SEARCH BAR =================
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                ),

                child: TextField(
                  //ADDED JUST NOW
                  focusNode: searchFocusNode,
                  controller:
                      searchController,

                  textInputAction:
                      TextInputAction.search,

                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),

                  cursorColor: Colors.black,

                  decoration: InputDecoration(
                    hintText:
                        "Search orders...",

                    hintStyle:
                        const TextStyle(
                      color: Colors.grey,
                    ),

                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),

                      borderSide:
                          BorderSide.none,
                    ),

                    contentPadding:
                        const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 10,
                    ),
                  ),
//ADDED JUST NOW
                  onChanged: (value) {

  searchQuery = value.toLowerCase();

  Future.microtask(() {
    if (mounted) {
      setState(() {});
    }
  });
},
                  
                ),
              ),

              const SizedBox(height: 10),

              // ================= EARNINGS CARDS =================
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                ),

                child: Row(
                  children: [

                    // ================= DELIVERED =================
                    Expanded(
                      child: Container(
                        padding:
                            const EdgeInsets.all(
                          14,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.green
                              .withOpacity(0.1),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            const Text(
                              "Delivered Earnings",

                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    Colors.grey,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              "₹${deliveredEarnings.toStringAsFixed(0)}",

                              style:
                                  const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight
                                        .bold,

                                color:
                                    Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // ================= PENDING =================
                    Expanded(
                      child: Container(
                        padding:
                            const EdgeInsets.all(
                          14,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.orange
                              .withOpacity(0.1),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            const Text(
                              "Pending Earnings",

                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    Colors.grey,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              "₹${pendingEarnings.toStringAsFixed(0)}",

                              style:
                                  const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight
                                        .bold,

                                color:
                                    Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ================= FILTER CHIPS =================
              SizedBox(
                height: 50,

                child: ListView(
                  scrollDirection:
                      Axis.horizontal,

                  children: [

                    buildFilterChip(
                      'all',
                      'All',
                    ),

                    buildFilterChip(
                      OrderStatus.pending,
                      'Pending',
                    ),

                    buildFilterChip(
                      'active',
                      'Active',
                    ),

                    buildFilterChip(
                      OrderStatus.delivered,
                      'Delivered',
                    ),

                    buildFilterChip(
                      OrderStatus.rejected,
                      'Rejected',
                    ),
                  ],
                ),
              ),

              // ================= ORDER LIST =================
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,

                  itemBuilder:
                      (context, index) {

                    final doc = orders[index];

                    final data = doc.data()
                        as Map<String, dynamic>;

                    final orderId = doc.id;

                    final image =
                        data['productImage'] ??
                            '';

                    final name =
                        data['productName'] ??
                            'No Name';

                    final status =
                        data['status'] ??
                            OrderStatus.pending;

                    final price =
                        data['price'] ?? 0;

                    final quantity =
                        data['quantity'] ?? 1;

                    final buyerId =
                        data['buyerId'] ??
                            'Unknown';
                    
                    final paymentMethod =
    data['paymentMethod'] ?? 'N/A';

final customerName =
    data['customerName'] ?? 'N/A';

final phoneNumber =
    data['phoneNumber'] ?? 'N/A';

final address =
    data['address'] ?? 'N/A';


                    final Color statusColor =
                        OrderStatusUtils
                            .getColor(status);

                    return Card(

                      margin:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),

                      elevation: 3,

                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                          12,
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            // ================= TOP ROW =================
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                // IMAGE
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    10,
                                  ),

                                  child:
                                      image.isNotEmpty
                                          ? Image.network(
                                              image,
                                              width:
                                                  65,
                                              height:
                                                  65,
                                              fit: BoxFit
                                                  .cover,
                                            )
                                          : const Icon(
                                              Icons
                                                  .image,
                                              size: 60,
                                            ),
                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                // DETAILS
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                        children: [

  /// 📦 PRODUCT NAME
  Text(
    name,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  ),

  const SizedBox(height: 5),

  /// 💰 PRICE
  Text(
    "₹$price",
    style: const TextStyle(
      color: Colors.grey,
    ),
  ),

  const SizedBox(height: 6),

  /// 🔢 QUANTITY
  Text(
    "Qty: $quantity",
    style: const TextStyle(
      fontSize: 13,
    ),
  ),

  const SizedBox(height: 10),

  /// 💳 PAYMENT METHOD
  Row(
    children: [
      const Icon(Icons.payment, size: 16),

      const SizedBox(width: 5),

      Expanded(
        child: Text(
          paymentMethod,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  ),

  const SizedBox(height: 6),

  /// 👤 CUSTOMER NAME
  Text(
    "Customer: $customerName",
    style: const TextStyle(
      fontWeight: FontWeight.w600,
    ),
  ),

  const SizedBox(height: 4),

  /// 📞 PHONE NUMBER
  Text(
    "Phone: $phoneNumber",
  ),

  const SizedBox(height: 4),

  /// 📍 ADDRESS
  Text(
    "Address: $address",
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  ),
],
                                    
                                  ),
                                ),

                                // STATUS
                                OrderStatusBadge(
                                  status: status,
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            // ================= BUYER =================
                            Text(
                              "Buyer ID: $buyerId",

                              style:
                                  const TextStyle(
                                fontSize: 12,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            // ================= STATUS BAR =================
                            Container(
                              height: 5,
                              width:
                                  double.infinity,

                              decoration:
                                  BoxDecoration(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  10,
                                ),

                                color: statusColor,
                              ),
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            // ================= ACTION BUTTONS =================
                            buildActionButtons(
                              context: context,
                              status: status,
                              orderId: orderId,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}