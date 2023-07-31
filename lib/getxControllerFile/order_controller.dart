import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

enum OrderStatus {
  processing,
  pending,
  done,
  cancelled,
}

class Order {
  final String orderId;
  final String userId;
  final DateTime orderDate;
  final double totalAmount;
  final List<String> items;
  OrderStatus status;

  Order({
    required this.orderId,
    required this.userId,
    required this.orderDate,
    required this.totalAmount,
    required this.items,
    this.status = OrderStatus.pending,
  });
}

class OrderController extends GetxController {
  List<Order> orders = [];
  CollectionReference<Map<String, dynamic>> ordersCollection =
  FirebaseFirestore.instance.collection('orders');

  @override
  void onInit() {
    fetchOrders(); // Fetch orders when the controller initializes
    super.onInit();
  }

  Future<void> fetchOrders() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final querySnapshot = await ordersCollection
          .where('userId', isEqualTo: userId)
          .get();

      orders = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final items = data['items'];

        List<String> itemsList;
        if (items is String) {
          itemsList = [items];
        } else if (items is List) {
          itemsList = List<String>.from(items);
        } else {
          itemsList = [];
        }

        return Order(
          orderId: doc.id,
          userId: data['userId'],
          orderDate: (data['orderDate'] as Timestamp).toDate(),
          totalAmount: data['totalAmount'],
          items: itemsList,
          status: OrderStatus.values.firstWhere(
                (status) => status.toString().split('.').last == data['status'],
          ),
        );
      }).toList();

      update(); // Notify GetBuilder to rebuild the UI
    }
  }

  Future<void> placeOrder(
      String paymentMethod, double totalAmount) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? "";

    final cartDataSnapshot = await FirebaseFirestore.instance
        .collection('carts')
        .doc(userId)
        .get();
    final Map<String, dynamic>? cartData = cartDataSnapshot.data();

    if (cartData != null && cartData['items'] != null) {
      // Get the list of items from the cart data
      final List<dynamic> items = cartData['items'];

      // Perform any necessary operations for order placement
      // (e.g., saving to Firestore, updating order status, etc.)
      final orderId = await saveOrderToFirestore(
          userId, items, paymentMethod, totalAmount);

      // Clear the cart items after placing the order
      clearCart(userId);

      if (kDebugMode) {
        print('Order placed with payment method: $paymentMethod');
        print('Order ID: $orderId');
      }

      fetchOrders(); // Fetch the updated list of orders
    } else {
      if (kDebugMode) {
        print('No items in the cart.');
      }
    }
  }

  Future<String> saveOrderToFirestore(String userId, List<dynamic> items,
      String paymentMethod, double totalAmount) async {
    String? deviceToken = await FirebaseMessaging.instance.getToken();

    final orderData = {
      'userId': userId,
      'items': items,
      'paymentMethod': paymentMethod,
      'status': 'processing',
      'orderDate': Timestamp.now(),
      'totalAmount': totalAmount,
      'deviceToken': deviceToken,
      // Add any other necessary order details
    };

    final newOrderDoc = await ordersCollection.add(orderData);

    return newOrderDoc.id;
  }

  void clearCart(String userId) async {
    final cartRef = FirebaseFirestore.instance.collection('carts');
    final cartDataSnapshot =
    await FirebaseFirestore.instance.collection('carts').doc(userId).get();
    final Map<String, dynamic>? cartData = cartDataSnapshot.data();

    if (cartData != null) {
      cartData['items'] = null;
      await cartRef.doc(userId).update({'items': null});
    }
  }

  void sendPushNotification(String body, String token) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=AAAAAgeCKYA:APA91bFG5ZgITytWAUm9kLAvrBzUhkK_K2Zm8u6qVQSND9y9xA4zsXLG-olkvDJPaN2sff36QtzCZsf5TcXTA3wNPWFK2ifwCZ5LqH7FMwcPFdItu_ss8q3YjJZUG3Z25IV6SM2OmzSt',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': 'Order Status Updated',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': body,
            },
            'to': token,
          },
        ),
      );
      if (kDebugMode) {
        print('Push notification sent');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending push notification: $e');
      }
    }
  }

}
