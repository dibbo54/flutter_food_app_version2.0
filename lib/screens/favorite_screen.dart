import 'package:flutter/material.dart';
import 'package:flutter_food_app/screens/product_details_page.dart';

import 'package:get/get.dart';

import '../getxControllerFile/cart_controller.dart';
import '../models/product_model.dart';


class FavoriteScreen extends StatelessWidget {
  final CartController cartController = Get.find<CartController>();

  FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorite"),
      ),
      body: GetBuilder<CartController>(
        builder: (controller) {
          final favoriteItems = controller.getFavoriteItems();

          if (favoriteItems.isEmpty) {
            return const Center(child: Text("No favorite items"));
          }
          return ListView.builder(
            itemCount: favoriteItems.length,
            itemBuilder: (context, index) {
              final item = favoriteItems[index];
              final Product product = Product.fromMap(item, item['id']);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    trailing: const Text("View"),
                    title: Text(product.name),
                    subtitle: Text('Price: ${product.price.toStringAsFixed(2)}'),
                    onTap: () {
                      Get.to(
                        ProductDetailsScreen(
                          product: product,
                        ),
                      );
                    },
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
