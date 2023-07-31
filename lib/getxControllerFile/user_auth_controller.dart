import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class UserAuthController extends GetxController {


  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Rx<User?> currentUser = Rx<User?>(null);
  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      currentUser.value = user;
    });
  }

  RxBool isLoading = RxBool(false);
  @override
  void onClose() {
    // TODO: implement onClose
    _authSubscription?.cancel();
    super.onClose();
  }
  Future<void> saveUserDeviceToken() async {
    try {
      // Get the device token
      final String? deviceToken = await _firebaseMessaging.getToken();

      // Save the device token to the user's document in Firestore
      // Assuming you have a 'users' collection with documents containing user information
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'deviceToken': deviceToken});

      // Device token saved successfully
      if (kDebugMode) {
        print('Device token saved successfully');
      }
    } catch (e) {
      // Error occurred while saving the device token
      if (kDebugMode) {
        print('Error saving device token: $e');
      }
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      saveUserDeviceToken();
      isLoading.value = false; //
    } catch (e) {
      isLoading.value = false; //
      Get.snackbar("Login Error", e.toString(),
          duration: const Duration(seconds: 3));
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Get the current user
      final User? user = _auth.currentUser;

      if (user != null) {
        // Save the email address in Firestore
        saveUserDeviceToken();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'email': email, 'uid': user.uid});
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("SingUp Error", e.toString(),
          duration: const Duration(seconds: 3));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(
        email: email,
      );
      isLoading.value = true;
    } catch (e) {
      isLoading.value = true;
      Get.snackbar("Reset password error", e.toString(),
          duration: const Duration(seconds: 3));
    }
  }

  Future<void> updateProfileData(

      String? name, String? mobile, String? address, String profileImage) async {
    isLoading.value = true;
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentReference documentRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await documentRef.update(
          {'name': name, 'mobile': mobile, 'address': address, 'profileImage':profileImage});

      isLoading.value = false;
      // Optionally, you can update the user object locally
      user.updateDisplayName(name);
    }else{
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userData =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return userData.data() as Map<String, dynamic>;
    }
    return {};
  }



}
