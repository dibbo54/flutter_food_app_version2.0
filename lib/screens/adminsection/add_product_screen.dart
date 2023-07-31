import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:uuid/uuid.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  bool _showLoading = false;

  double _loadingProgress = 0.0;

  List<File> selectedImages = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController discountController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    discountController.dispose();
    super.dispose();
  }

  Future<void> selectImages() async {
    final pickedImages = await ImagePicker().pickMultiImage();
    List<File> images = [];
    for (final pickedImage in pickedImages) {
      final image = File(pickedImage.path);
      images.add(image);
    }
    setState(() {
      selectedImages = images;
    });
  }

  void removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  Future<void> addProductToFirestore(
    String name,
    double price,
    double discount,
    String description,
    List<File> images,
  ) async {
    setState(() {
      _showLoading = true;
      _loadingProgress = 0.0;
    });

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference productsRef = firestore.collection('products');

    List<String> imageUrls = [];

    for (int i = 0; i < images.length; i++) {
      File image = images[i];
      String filename = const Uuid().v4();
      Reference storageRef =
          FirebaseStorage.instance.ref().child('product_images/$filename.jpg');

      UploadTask uploadTask = storageRef.putFile(image);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _loadingProgress =
              snapshot.bytesTransferred / snapshot.totalBytes * 100;
        });
      });

      String imageUrl = await (await uploadTask).ref.getDownloadURL();
      imageUrls.add(imageUrl);
    }

    DocumentReference newProductRef = productsRef.doc();
    Map<String, dynamic> productData = {
      'name': name,
      'price': price,
      'discount': discount,
      'description': description,
      'imageUrls': imageUrls,
    };

    newProductRef.set(productData).then((value) {
      setState(() {
        _showLoading = false;
        _loadingProgress = 0.0;
      });
      if (kDebugMode) {
        print('Product added to Firestore with ID: ${newProductRef.id}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully')),
      );
    }).catchError((error) {
      setState(() {
        _showLoading = false;
        _loadingProgress = 0.0;
      });
      if (kDebugMode) {
        print('Failed to add product to Firestore: $error');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add product')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: selectImages,
                  child: const Text('Select Images'),
                ),
                const SizedBox(height: 16.0),
                selectedImages.isNotEmpty
                    ? SizedBox(
                        height: 200.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: selectedImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  width: 200.0,
                                  margin: const EdgeInsets.only(right: 16.0),
                                  child: Image.file(
                                    selectedImages[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8.0,
                                  right: 8.0,
                                  child: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => removeImage(index),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    : const Placeholder(fallbackHeight: 200.0),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: discountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Discount'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text;
                    final price = double.tryParse(priceController.text) ?? 0.0;
                    final description = descriptionController.text;
                    final discount =
                        double.tryParse(discountController.text) ?? 0.0;

                    addProductToFirestore(
                        name, price, discount, description, selectedImages);

                    nameController.clear();
                    priceController.clear();
                    descriptionController.clear();
                    discountController.clear();
                    setState(() {
                      selectedImages = [];
                    });
                  },
                  child: const Text('Add Product'),
                ),
              ],
            ),
          ),
          if (_showLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Uploading...',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      '${_loadingProgress.toStringAsFixed(1)}%',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
