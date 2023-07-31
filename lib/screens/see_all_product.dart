import 'package:flutter/material.dart';
import 'package:flutter_food_app/screens/product_details_page.dart';

import 'package:get/get.dart';
import '../getxControllerFile/product_controller.dart';
import '../getxControllerFile/product_search_controller.dart';
import '../models/product_model.dart';
import '../widgets/app_text_field.dart';

class SeeAllProductScreen extends StatefulWidget {
  const SeeAllProductScreen({Key? key}) : super(key: key);

  @override
  State<SeeAllProductScreen> createState() => _SeeAllProductScreenState();
}

class _SeeAllProductScreenState extends State<SeeAllProductScreen> {
  final ProductController _productController = Get.find<ProductController>();
  final ProductSearchController _productSearchController =
      Get.put(ProductSearchController());
  final TextEditingController _searchController = TextEditingController();
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _productSearchController.setProducts(
        _productController.products); // Set the initial list of products
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    //_productSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Products"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Get.to(const SeeAllProductScreen());
              },
              child: AppTextField(

                isobs: false,
                focusNode: _searchFocusNode,
                hintText: 'Search here......',
                textInputType: TextInputType.text,
                prefixIcon: Icons.search,
                controller: _searchController,
                onChange: (query) {
                  _productSearchController.searchProduct(query!);
                },
                validator: (value) {},
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () {
            final filteredProducts = _productSearchController.filteredProducts;
            if (_searchController.text.isEmpty) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                ),
                itemCount: _productController.products.length,
                itemBuilder: (context, index) {
                  Product product = _productController.products[index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(ProductDetailsScreen(product: product));
                      // Handle product tap event
                    },
                    child: Card(
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: NetworkImage(product.imageUrls[0]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "\$${product.price.toStringAsFixed(2)}",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (filteredProducts.isEmpty) {
              return const Center(child: Text("No products found"));
            } else {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  Product product = filteredProducts[index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(ProductDetailsScreen(product: product));
                      // Handle product tap event
                    },
                    child: Card(
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: NetworkImage(product.imageUrls[0]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "\$${product.price.toStringAsFixed(2)}",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
