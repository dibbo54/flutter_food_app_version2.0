import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_food_app/screens/product_details_page.dart';
import 'package:flutter_food_app/screens/profile_update_screen.dart';
import 'package:flutter_food_app/screens/see_all_product.dart';

import 'package:get/get.dart';

import '../getxControllerFile/product_controller.dart';
import '../getxControllerFile/user_auth_controller.dart';
import '../models/product_model.dart';
import '../utils/my_colors.dart';
import '../utils/my_text_style.dart';
import '../widgets/app_text_field.dart';
import 'adminsection/admin_screen.dart';
import 'cart_list_screen.dart';
import 'favorite_screen.dart';
import 'login_screen.dart';
import 'order_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "";
  String userEmail = "";
  String imageUrl = '';
  String searchName = "";

  final UserAuthController _userAuthController = Get.find<UserAuthController>();
  final ProductController _productController = Get.find<ProductController>();

  final List<String> sliderImages = [
    'img1.jpg',
    'img2.jpeg',
    'img3.jpg',
    'img5.jpg',
    'img6.jpg',
  ];

  Future<void> checkUserData() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get()
          .then((snapshot) {
        final profileData = snapshot.data();
        userName = profileData?['name'] ?? "User Name";
        userEmail = profileData?['email'] ?? "user email";
        imageUrl = profileData?['profileImage'] ?? "";
        setState(() {});
        if (profileData == null ||
            profileData['name'] == null ||
            profileData['email'] == null) {
          Get.to(const ProfileScreen());
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUserData();
    _productController.products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(FavoriteScreen());
              },
              icon: const Icon(Icons.favorite_border)),
          IconButton(
              onPressed: () {
                Get.to(CartListScreen());
              },
              icon: const Icon(Icons.shopping_cart)),
        ],
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
                textFieldEnable: false,
                hintText: 'Search here......',
                textInputType: TextInputType.text,
                prefixIcon: Icons.search,
                controller: TextEditingController(),
                validator: (value) {
                  if (value == "") {
                    const AlertDialog(
                      content: Text('Pls Enter something'),
                      backgroundColor: Colors.white,
                    );
                  }
                },
                onChange: (value) {
                  searchName = value!;
                },
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              items: sliderImages.map((image) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        10), // Adjust the radius as needed
                    image: DecorationImage(
                      image: AssetImage('images/$image'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  width: double.infinity,
                  height: 200,
                );
              }).toList(),
              options: CarouselOptions(
                height: 200,
                autoPlay: true,
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "All Foods",
                  style: MyStyle.myTitleTextStyle(Colors.black),
                ),
                TextButton(
                    onPressed: () {
                      Get.to(const SeeAllProductScreen());
                    },
                    child: const Text('See all'))
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
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
                                      borderRadius: BorderRadius.circular(
                                          10), // Adjust the radius as needed
                                      image: DecorationImage(
                                        image:
                                            NetworkImage(product.imageUrls[0]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    width: double.infinity,
                                    //height: 250,
                                  ),
                                ),
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
          ],
        ),
      ),
      drawer: Drawer(
        //backgroundColor: MyColors.brandColor,
        child: ListView(
          children: [
            DrawerHeader(
                padding: EdgeInsets.zero,
                child: UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: MyColors.brandColor),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                  accountName: Text(
                    userName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  accountEmail: Text(userEmail),
                )),
            const ListTile(
              title: Text("Refund account"),
              subtitle: Text("Blance and payment methods"),
              trailing: Text("0"),
            ),
            const Divider(
              thickness: 1,
              color: Colors.black12,
            ),
            ListTile(
              leading: const Icon(
                Icons.sync,
                color: MyColors.brandColor,
              ),
              title: const Text("Switch to admin mode"),
              onTap: () {
                Get.offAll(const AdminScreen());
              },
            ),
            const ListTile(
              title: Text('Become a pandapro'),
              leading: Icon(
                Icons.star,
                color: MyColors.brandColor,
              ),
            ),
            const ListTile(
              title: Text('Voucher & Offers'),
              leading: Icon(
                Icons.gif,
                color: MyColors.brandColor,
              ),
            ),
            ListTile(
              onTap: () {
                Get.to(FavoriteScreen());
              },
              title: const Text('Favourites'),
              leading: const Icon(
                Icons.favorite_border,
                color: MyColors.brandColor,
              ),
            ),
            ListTile(
              onTap: () {
                Get.to(OrderScreen());
              },
              title: const Text('Orders & reordering'),
              leading: const Icon(
                Icons.list_alt,
                color: MyColors.brandColor,
              ),
            ),
            ListTile(
              onTap: () {
                Get.to(const ProfileScreen());
              },
              title: const Text('Profile'),
              leading: const Icon(
                Icons.person,
                color: MyColors.brandColor,
              ),
            ),
            const ListTile(
              title: Text('Help Center'),
              leading: Icon(
                Icons.error,
                color: MyColors.brandColor,
              ),
            ),
            const ListTile(
              title: Text('Invite friends'),
              leading: Icon(
                Icons.card_giftcard,
                color: MyColors.brandColor,
              ),
            ),
            const Divider(
              thickness: 2,
              color: Colors.black12,
            ),
            ListTile(
              onTap: () {
                Get.to(const ProfileScreen());
              },
              title: const Text('Settings'),
            ),
            ListTile(
              onTap: () {},
              title: const Text('Terms & Conditions / privacy'),
            ),
            ListTile(
              onTap: () {
                _userAuthController.signOut().then((value) {
                  Get.offAll(const LoginScreen());
                });
              },
              title: const Text('Log out'),
            ),
            // ListTile(
            //   onTap: () {
            //     Get.to(const AddProductScreen());
            //   },
            //   title: const Text('Add Product'),
            // ),ListTile(
            //   onTap: () {
            //     Get.to( AdminOrdersScreen());
            //   },
            //   title: const Text('Admin orders'),
            // ),
          ],
        ),
      ),
    );
  }
}
