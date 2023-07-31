import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'adminsection/admin_screen.dart';

class ProductUpdatePage extends StatefulWidget {
  final String productId;

  const ProductUpdatePage({super.key, required this.productId});

  @override
  _ProductUpdatePageState createState() => _ProductUpdatePageState();
}

class _ProductUpdatePageState extends State<ProductUpdatePage> {
  TextEditingController? _nameController;
  TextEditingController? _priceController;
  TextEditingController? _descriptionController;

  Future<DocumentSnapshot<Map<String, dynamic>>> getProduct(String productId) {
    return FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();
  }

  @override
  void initState() {
    super.initState();
    getProduct(widget.productId).then((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        setState(() {
          _nameController = TextEditingController(text: data['name']);
          _priceController = TextEditingController(text: data['price'].toString());
          _descriptionController = TextEditingController(text: data['description']);
        });

      } else {
        // Handle case when product does not exist
        // For example, show an error message or navigate back
      }
    });
  }


  void _updateProduct() {
    final String updatedName = _nameController?.text ??"";
    final double updatedPrice = double.parse(_priceController?.text ??"");
    final String updatedDescription = _descriptionController?.text??"";

    // Perform the necessary logic to update the product details in Firestore
    FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .update({
      'name': updatedName,
      'price': updatedPrice,
      'description': updatedDescription,
    })
        .then((_) {
      // Handle the successful update
      // For example, show a success message or navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );
      Get.to(const AdminScreen());

    })
        .catchError((error) {
      // Handle errors during update
      // For example, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update product')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Product Price',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Product Description',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateProduct,
              child: const Text('Update Product'),
            ),
          ],
        ),
      ),
    );
  }
}
