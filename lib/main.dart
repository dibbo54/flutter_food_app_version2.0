import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_food_app/screens/home_screen.dart';
import 'package:flutter_food_app/screens/login_screen.dart';
import 'package:flutter_food_app/utils/my_colors.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'firebase_options.dart';
import 'getxControllerFile/cart_controller.dart';
import 'getxControllerFile/order_controller.dart';
import 'getxControllerFile/product_controller.dart';
import 'getxControllerFile/product_search_controller.dart';
import 'getxControllerFile/user_auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialise app based on platform- web or mobile
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAL5t_IhSisGVI4eG-kRg3wPAvC5V-SG6g',
        appId: '1:758683111450:web:37e21ac7878e0629fe81a3',
        messagingSenderId: '758683111450',
        projectId: 'flutter-food-app-71f5d',
        authDomain: 'flutter-food-app-71f5d.firebaseapp.com',
        databaseURL:
            'https://flutter-food-app-71f5d-default-rtdb.asia-southeast1.firebasedatabase.app',
        storageBucket: 'flutter-food-app-71f5d.appspot.com',
        measurementId: 'G-HRJ0TT7CE5',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  requestPermission();
  runApp(const MyApp());
}

void requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true);
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    if (kDebugMode) {
      print("User granted");
    }
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    if (kDebugMode) {
      print("User permission granted provisional");
    }
  } else {
    if (kDebugMode) {
      print("User deynai permisssion");
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: MyColors.brandColor, // Set your desired color here
    ));
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: AppBindings(),
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme:
              const AppBarTheme(elevation: 0, color: MyColors.brandColor)),
      home: FutureBuilder(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading screen if the authentication state is still loading
            return const CircularProgressIndicator();
          } else {
            // Check if the user is logged in
            if (snapshot.hasData) {
              // User is already logged in, navigate to the home screen
              return const HomeScreen();
            } else {
              // User is not logged in, navigate to the login screen
              return const LoginScreen();
            }
          }
        },
      ),
    );
  }
}

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.put<UserAuthController>(UserAuthController());
    Get.put<ProductController>(ProductController());
    Get.put<CartController>(CartController());
    Get.put<OrderController>(OrderController());
    Get.put<ProductSearchController>(ProductSearchController());
  }
}
