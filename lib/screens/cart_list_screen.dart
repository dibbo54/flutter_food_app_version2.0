import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../getxControllerFile/cart_controller.dart';
import '../getxControllerFile/order_controller.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartListScreen extends StatelessWidget {
  CartListScreen({Key? key}) : super(key: key);

  final CartController cartController = Get.find<CartController>();
  final OrderController orderController = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Expanded widget takes available space and contains a StreamBuilder
            Expanded(
              child: StreamBuilder<Map<String, dynamic>>(
                stream: cartController.cartStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // Retrieve cart data from the snapshot
                    final cartData = snapshot.data!;
                    final List<dynamic> cartItems = cartData['items'] ?? [];
                    // Build a ListView.builder to display cart items
                    return ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        // Convert item to a Product model
                        final Product product =
                        Product.fromMap(item, item['id']);
                        final CartItem? cartItem =
                        cartController.getCartItem(product);
                        // Build a Card widget with ListTile to display product details
                        return Card(
                          child: ListTile(
                            title: Text(product.name),
                            subtitle: Text(
                                '\$${product.price.toStringAsFixed(2)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      cartController.decreaseQuantity(product),
                                  icon: const Icon(Icons.remove),
                                ),
                                if (cartItem != null)
                                  Text('${cartItem.quantity}'),
                                IconButton(
                                  onPressed: () =>
                                      cartController.increaseQuantity(product),
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return const Text("No Item Found");
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GetBuilder<CartController>(
                    builder: (cartController) {
                      return Text(
                        'Total: \$${cartController.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'Select Payment Method',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                ListTile(
                                  leading:
                                  const Icon(Icons.monetization_on),
                                  title: const Text('Cash on Delivery'),
                                  onTap: () {
                                    // Place the order with cash on delivery payment method
                                    orderController.placeOrder(
                                        'Cash on Delivery',cartController.totalPrice);
                                    Navigator.pop(context); // Close the bottom sheet
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.payment),
                                  title: const Text('Online Payment'),
                                  onTap: () {
                                    // Place the order with online payment method
                                    orderController.placeOrder(
                                        'Online Payment',cartController.totalPrice);
                                    Navigator.pop(context); // Close the bottom sheet
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: const Text('Checkout'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
