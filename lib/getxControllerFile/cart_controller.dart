import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:get/get.dart';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartController extends GetxController {
  final CollectionReference _cartRef =
  FirebaseFirestore.instance.collection("carts");

  final CollectionReference _favRef =
  FirebaseFirestore.instance.collection("favorite");

  final RxMap<String, dynamic> _cartItems = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> _favItems = <String, dynamic>{}.obs;

  Map<String, dynamic> get cartItems => _cartItems;
  Map<String, dynamic> get favItems => _favItems;



  Stream<Map<String, dynamic>> get cartStream => _cartRef
      .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
      .snapshots()
      .map((snapshot) => snapshot.data() as Map<String, dynamic>);


  void addToCart(Product product, int quantity) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? "";
    final cartData = _cartItems[userId];

    if (cartData != null && cartData['items'] != null) {
      //final List<dynamic> items = List.from(cartData['items']);
      final List<dynamic> items = cartData['items'];
      final index = items.indexWhere((item) => item['id'] == product.id);
      if (index != -1) {
        items[index]['quantity'] += quantity;
      } else {
        items.add({
          'id': product.id,
          'name': product.name,
          'price': product.price,
          'quantity': quantity,
        });
      }

      _cartItems[userId]['items'] = items;
    } else {
      _cartItems[userId] = {
        'items': [
          {
            'id': product.id,
            'name': product.name,
            'price': product.price,
            'quantity': quantity,
          }
        ]
      };
    }

    await _cartRef.doc(userId).set(_cartItems[userId]); // Set the document in Firestore

    update();
  }
  void addToFav(Product product) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? "";
    final favData = _favItems[userId];

    if (favData != null && favData['items'] != null) {
     final List<dynamic> items = favData['items'];
      //final List<dynamic> items = List.from(favData['items']);
      final index = items.indexWhere((item) => item['id'] == product.id);
      if (index != -1) {
        items[index]['quantity']++;
      } else {
        items.add({
          'id': product.id,
          'name': product.name,
          'price': product.price,
          'quantity': 1,
          'image': product.imageUrls[0],
          'description':product.description
        });
      }
      update();
    } else {
      _favItems[userId] = {
        'items': [
          {
            'id': product.id,
            'name': product.name,
            'price': product.price,
            'quantity': 1,
            'image': product.imageUrls[0],
            'description':product.description
          }
        ]
      };
    }

    await _favRef.doc(userId).set(_favItems[userId]);
    update();
  }


  void removeFromCart(Product product) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? "";
    final cartData = _cartItems[userId];

    if (cartData != null && cartData['items'] != null) {
      final List<dynamic> items = cartData['items'];
      final index = items.indexWhere((item) => item['id'] == product.id);

      if (index != -1) {
        final int newQuantity = items[index]['quantity'] - 1;

        if (newQuantity > 0) {
          items[index]['quantity'] = newQuantity;
        } else {
          items.removeAt(index);
        }
      }
    }

    await _cartRef.doc(userId).update(_cartItems[userId]); // Update the document in Firestore

    update();
  }


  void removeFromFav(Product product) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? "";
    final cartData = _favItems[userId];

    if (cartData != null && cartData['items'] != null) {
      final List<dynamic> items = cartData['items'];
      final index = items.indexWhere((item) => item['id'] == product.id);

      if (index != -1) {
        final int newQuantity = items[index]['quantity'] - 1;

        if (newQuantity > 0) {
          items[index]['quantity'] = newQuantity;
        } else {
          items.removeAt(index);
        }
      }
    }

    await _favRef.doc(userId).update(_favItems[userId]); // Update the document in Firestore

    update();
  }

  void increaseQuantity(Product product) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? "";
    final cartData = _cartItems[userId];

    if (cartData != null && cartData['items'] != null) {
      final List<dynamic> items = cartData['items'];
      final index = items.indexWhere((item) => item['id'] == product.id);

      if (index != -1) {
        items[index]['quantity']++;
      }
    }

    await _cartRef.doc(userId).update(_cartItems[userId]); // Update the document in Firestore

    update();
  }

  void decreaseQuantity(Product product) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? "";
    final cartData = _cartItems[userId];

    if (cartData != null && cartData['items'] != null) {
      final List<dynamic> items = cartData['items'];
      final index = items.indexWhere((item) => item['id'] == product.id);

      if (index != -1) {
        final int newQuantity = items[index]['quantity'] - 1;

        if (newQuantity > 0) {
          items[index]['quantity'] = newQuantity;
        } else {
          items.removeAt(index);
        }
      }
    }

    await _cartRef.doc(userId).update(_cartItems[userId]); // Update the document in Firestore

    update();
  }

  CartItem? getCartItem(Product product) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? "";
    final cartData = _cartItems[userId];

    if (cartData != null && cartData['items'] != null) {
      final List<dynamic> items = cartData['items'];
      final index = items.indexWhere((item) => item['id'] == product.id);

      if (index != -1) {
        final itemData = items[index];
        return CartItem.fromMap(itemData);
      }
    }

    return null;
  }


  double get totalPrice {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? "";
    final cartData = _cartItems[userId];

    double total = 0;

    if (cartData != null && cartData['items'] != null) {
      final List<dynamic> items = cartData['items'];

      for (var item in items) {
        final Product product = Product.fromMap(item, item['id']);
        final double price = product.price;
        final int quantity = item['quantity'];

        total += price * quantity;
      }
    }

    return total;
  }

  List<dynamic> getFavoriteItems(){
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid??"";

    final favData = _favItems[userId];

    if(favData !=null && favData['items'] != null){
      return List<dynamic>.from(favData['items']);
    }else{
      return [];
    }
  }


  bool isProductInCart(Product product) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? "";
    final cartData = _cartItems[userId];

    if (cartData != null && cartData['items'] != null) {
      final List<dynamic> items = cartData['items'];
      final index = items.indexWhere((item) => item['id'] == product.id);
      return index != -1;
    }

    return false;
  }
  bool isProductInFav(Product product) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? "";
    final cartData = _favItems[userId];

    if (cartData != null && cartData['items'] != null) {
      final List<dynamic> items = cartData['items'];
      final index = items.indexWhere((item) => item['id'] == product.id);
      return index != -1;
    }

    return false;
  }


  void placeOrder(String paymentMethod) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? "";
    final cartData = _cartItems[userId];

    if (cartData != null && cartData['items'] != null) {
      // Get the list of items from the cart data
      final List<dynamic> items = cartData['items'];

      // Perform any necessary operations for order placement
      // (e.g., saving to Firestore, updating order status, etc.)
      final orderId = await saveOrderToFirestore(userId, items, paymentMethod);

      // Clear the cart items after placing the order
      clearCart(userId);

      if (kDebugMode) {
        print('Order placed with payment method: $paymentMethod');
      }
      if (kDebugMode) {
        //print('Order ID: ${orderId.toString()}');
      }
    } else {
      if (kDebugMode) {
        print('No items in the cart.');
      }
    }
  }

  Future<void> saveOrderToFirestore(String userId, List<dynamic> items,
      String paymentMethod) async {
    String? deviceToken = await FirebaseMessaging.instance.getToken();
    final orderData = {
      'userId': userId,
      'items': items,
      'paymentMethod': paymentMethod,
      'status': 'pending',
      'orderDate': DateTime.now(),
      'deviceToken': deviceToken,
      // Add any other necessary order details
    };

    final orderRef = FirebaseFirestore.instance.collection('orders');
    final newOrderDoc = await orderRef.add(orderData);
    final orderId = newOrderDoc.id;

    // Save the order ID to the user's document
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    await userRef.update({'orderId': orderId});
  }

  void clearCart(String userId) async {
    _cartItems[userId] = null;
    totalPrice == 0.0;
    await _cartRef.doc(userId).delete();
    update();
  }
}