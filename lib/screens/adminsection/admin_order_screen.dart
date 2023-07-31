import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../getxControllerFile/order_controller.dart';
import '../../utils/my_colors.dart';

enum OrderStatus {
  processing,
  received,
  onTheWay,
  done,
}

class AdminOrdersScreen extends StatelessWidget {

  final OrderController _orderController = Get.find<OrderController>();




  final CollectionReference<Map<String, dynamic>> ordersCollection = FirebaseFirestore.instance.collection('orders');

  AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Orders'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ordersCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching orders.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final orders = snapshot.data?.docs ?? [];

          if (orders.isEmpty) {
            return const Center(
              child: Text('No orders available.'),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderData = orders[index].data();
              final itemsList = (orderData['items'] ?? []) as List<dynamic>; // Adjust the data type to List<dynamic>
              final items = List<Map<String, dynamic>>.from(itemsList);


              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Card(
                  child: ListTile(
                    title: Text('Order ID: ${orders[index].id}'),
                    //subtitle: Text('Status: ${orderData['status']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var item in items)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Product Name: ${item['name']}'),
                              Text('Quantity: ${item['quantity']}'),
                              Text('Price: \$${item['price']}'),
                              const Divider(thickness: 2,color: MyColors.brandColor,),
                              const SizedBox(height: 8),
                            ],
                          ),
                        Text('Total Amount: \$${orderData['totalAmount'].toStringAsFixed(2)}'),

                      ],
                    ),
                    trailing: DropdownButton<OrderStatus>(
                      value: OrderStatus.values.firstWhere(
                            (status) => status.toString().split('.').last == orderData['status'],
                      ),
                      items: OrderStatus.values.map((status) {
                        return DropdownMenuItem<OrderStatus>(
                          value: status,
                          child: Text(status.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (newStatus) {
                        final orderId = orders[index].id;

                        // Update the order status
                        updateOrderStatus(orderId, newStatus!);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await ordersCollection.doc(orderId).update({'status': newStatus.toString().split('.').last});

    // Retrieve the order document
    DocumentSnapshot<Map<String, dynamic>> orderDoc = await ordersCollection.doc(orderId).get();

    // Get the device token from the order document
    String? deviceToken = orderDoc.data()?['deviceToken'];

    if (deviceToken != null) {
      // Send push notification
      if (kDebugMode) {
        print("my device token is: $deviceToken");
      }
      _orderController.sendPushNotification(
        'Your order status has been updated to ${newStatus.toString().split('.').last.toLowerCase()}.',
        deviceToken,
      );
    }
  }

}
