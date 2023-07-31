import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../getxControllerFile/cart_controller.dart';
import '../models/product_model.dart';
import 'package:get/get.dart';

import '../utils/my_colors.dart';
import '../utils/my_text_style.dart';
import '../widgets/app_button.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final CartController _cartController = Get.find<CartController>();
  int cartItem = 1;
  int favItem = 0;
  bool isInCart = false;
  bool isInFav = false;

  @override
  void initState() {
    super.initState();
    // Check if the product is already in the cart
    isInCart = _cartController.isProductInCart(widget.product);
    if (isInCart) {
      // If the product is in the cart, get the quantity
      final cartItem = _cartController.getCartItem(widget.product);
      if (cartItem != null) {
        this.cartItem = cartItem.quantity;
      }
    }

    isInFav = _cartController.isProductInFav(widget.product);
    if (isInFav) {
      // If the product is in the cart, get the quantity
      final favItem = _cartController.getCartItem(widget.product);
      if (favItem != null) {
        this.favItem = favItem.quantity;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CarouselSlider(
                    items: widget.product.imageUrls.map((image) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(image),
                            fit: BoxFit.cover,
                          ),
                        ),
                        width: double.infinity,
                        height: 250,
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 250,
                      autoPlay: true,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.8,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: true,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (cartItem > 0) {
                              cartItem--;
                            }
                          });
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text(cartItem.toString()),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            cartItem++;
                          });
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      if (isInFav) {
                        // Remove the product from the cart
                        _cartController.removeFromFav(widget.product);
                      } else {
                        // Add the product to the cart
                        _cartController.addToFav(widget.product);
                      }
                      setState(() {
                        isInFav = !isInFav;
                      });
                    },
                    icon: Icon(
                      isInFav ? Icons.favorite : Icons.favorite_border,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16,),
              Text(
                widget.product.name,
                style: MyStyle.myTitleTextStyle(Colors.black),
              ),
              const SizedBox(height: 8,),
              Text(
                widget.product.price.toStringAsFixed(2),
                style: MyStyle.mySubTitleTextStyle(MyColors.brandColor),
              ),
              const SizedBox(height: 8.0,),
              Text(widget.product.description),
              const SizedBox(height: 8.0,),
            ],
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: SizedBox(
          width: double.infinity,
          child: AppButton(
            backgroundColor: MyColors.brandColor,
            buttonText: isInCart ? "Remove from cart" : "Add to cart",
            onTap: () {
              if (isInCart) {
                // Remove the product from the cart
                _cartController.removeFromCart(widget.product);
              } else {
                // Add the product to the cart
                _cartController.addToCart(widget.product, cartItem);
              }
              setState(() {
                isInCart = !isInCart;
              });
            },
          ),
        ),
      ),
    );
  }
}
