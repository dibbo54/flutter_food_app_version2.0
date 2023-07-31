import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';

class ProductController extends GetxController {
  final CollectionReference _productsRef =
  FirebaseFirestore.instance.collection("products");

  RxList<Product> products = <Product>[].obs;
  RxBool loading = false.obs; // New variable for loading state

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }
  Stream<List<Product>> get productsStream {
    return _productsRef.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>; // Explicitly cast to Map<String, dynamic>
        return Product.fromMap(data, doc.id);
      }).toList();
    });
  }


  Future<void> fetchProducts() async {
    try {
      loading.value = true; // Set loading to true before fetching data

      final querySnapshot = await _productsRef.get();
      final List<Product> loadedProducts = [];

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          if (data is Map<String, dynamic>) {
            final product = Product.fromMap(data, doc.id);
            loadedProducts.add(product);
          }
        }
      }

      products.value = loadedProducts;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching products: $e");
      }
    } finally {
      loading.value = false; // Set loading to false after fetching data
    }
  }
}
