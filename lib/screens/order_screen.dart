import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/my_colors.dart';


class OrderScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  OrderScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      // If no user is logged in, display a message or redirect to login
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view orders.'),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('userId', isEqualTo: user!.uid)
              .snapshots(),
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

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No orders available.'),
              );
            }
            final orders = snapshot.data!.docs.map((doc) {
              final data = doc.data();
              final itemsList = (data['items'] ?? []) as List<dynamic>; // Adjust the data type to List<dynamic>
              final items = List<Map<String, dynamic>>.from(itemsList);
              return Order(
                orderId: doc.id,
                userId: data['userId'].toString(), // Convert to string
                orderDate: (data['orderDate'] as Timestamp).toDate(),
                totalAmount: (data['totalAmount'] as num).toDouble(),
                items: items,
                status: OrderStatus.values.firstWhere(
                      (status) => status.toString().split('.').last == data['status'].toString(), // Convert to string
                ),
              );
            }).toList();

            if (orders.isEmpty) {
              return const Center(
                child: Text('No orders available.'),
              );
            }
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final Order order = orders[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Card(
                    child: ListTile(
                      title: Text('Order ID: ${order.orderId}'),
                      trailing: Text('Status: ${order.status.toString().split('.').last}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var item in order.items)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Product Name: ${item['name'].toString()}'),
                                Text('Quantity: ${item['quantity'].toString()}'),
                                Text('Price: \$${item['price'].toStringAsFixed(2)}'),
                                const Divider(thickness: 2,color: MyColors.brandColor,)
                              ],
                            ),
                          Text('Total Amount: \$${order.totalAmount.toStringAsFixed(2)}'),
                          //Text('Status: ${order.status.toString().split('.').last}'),
                        ],
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
  }
}

class Order {
  final String orderId;
  final String userId;
  final DateTime orderDate;
  final double totalAmount;
  final List<Map<String, dynamic>> items;
  final OrderStatus status;

  Order({
    required this.orderId,
    required this.userId,
    required this.orderDate,
    required this.totalAmount,
    required this.items,
    required this.status,
  });
}

enum OrderStatus {
  processing,
  received,
  onTheWay,
  done,
}
