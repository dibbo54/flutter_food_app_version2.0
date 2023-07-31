import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '../../getxControllerFile/product_controller.dart';
import '../../getxControllerFile/product_search_controller.dart';
import '../../models/product_model.dart';
import '../../widgets/app_text_field.dart';
import '../product_update_screen.dart';


class ProductUpdateSearch extends StatefulWidget {
  const ProductUpdateSearch({Key? key}) : super(key: key);

  @override
  State<ProductUpdateSearch> createState() => _ProductUpdateSearchState();
}

class _ProductUpdateSearchState extends State<ProductUpdateSearch> {
  final ProductController _productController = Get.find<ProductController>();
  final ProductSearchController _productSearchController = Get.put(ProductSearchController());
  final TextEditingController _searchController = TextEditingController();
  late FocusNode _searchFocusNode;


  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _productSearchController.setProducts(_productController.products); // Set the initial list of products
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
            child: AppTextField(
              isobs: false,
              focusNode: _searchFocusNode,
              hintText: 'Search hear......',
              textInputType: TextInputType.text,
              prefixIcon: Icons.search,
              controller: _searchController,
              onChange: (query){
                _productSearchController.searchProduct(query!);
              },
              validator: (value) {
                return null;
              },
            ),
          ),

        ),

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Product>>(
          stream: _productController.productsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show loading indicator
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Show message when no products are found
              return const Center(child: Text("No products found"));
            } else {
              return GridView.builder(
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                ),
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (context, index) {
                  Product product = snapshot.data![index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(ProductUpdatePage(productId: product.id,));
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
                                  borderRadius: BorderRadius.circular(
                                      10), // Adjust the radius as needed
                                  image: DecorationImage(
                                    image: NetworkImage(product.imageUrls[0]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                width: double.infinity,
                                //height: 250,
                              )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                    "\$${product.price.toStringAsFixed(2)}"),
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
