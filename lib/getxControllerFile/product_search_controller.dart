import 'package:get/get.dart';
import '../models/product_model.dart';
import 'dart:async';

class ProductSearchController extends GetxController {
  final RxList<Product> _filteredProducts = RxList<Product>([]);
  List<Product> get filteredProducts => _filteredProducts.value;
  List<Product> _products = []; // List of all products

  final StreamController<List<Product>> _productsStreamController = StreamController<List<Product>>.broadcast();
  Stream<List<Product>> get productsStream => _productsStreamController.stream;

  void setProducts(List<Product> products) {
    _products = products;
    _productsStreamController.add(products);
  }

  void searchProduct(String query) {
    if (query.isEmpty) {
      // If the query is empty, show all products
      _filteredProducts.value = _products;
    } else {
      // Otherwise, filter the products based on the query
      _filteredProducts.value = _products.where(
            (product) => product.name.toLowerCase().contains(query.toLowerCase()),
      ).toList();
    }
  }

  @override
  void dispose() {
    _productsStreamController.close();
    super.dispose();
  }
}
