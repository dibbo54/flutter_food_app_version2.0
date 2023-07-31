import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../getxControllerFile/user_auth_controller.dart';
import '../utils/my_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'adminsection/admin_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameET = TextEditingController();
  final TextEditingController emailET = TextEditingController();
  final TextEditingController mobileET = TextEditingController();
  final TextEditingController addressET = TextEditingController();
  File? _selectedImage;
  String? _imageURL;
  bool _isLoading = false;

  final UserAuthController _userAuthController = Get.find<UserAuthController>();

  Future<void> getUserInformation() async {
    // Replace 'userId' with the actual user ID
    final userData = await _userAuthController.fetchUserData();

    nameET.text = userData['name'] ?? '';
    emailET.text = userData['email'] ?? '';
    mobileET.text = userData['mobile'] ?? '';
    addressET.text = userData['address'] ?? '';
    _imageURL = userData['profileImage'] ?? "";
    setState(() {

    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await showDialog<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an image'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(await picker.pickImage(source: ImageSource.camera));
              },
              child: const Text('Camera'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(await picker.pickImage(source: ImageSource.gallery));
              },
              child: const Text('Gallery'),
            ),
          ],
        );
      },
    );

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }


  Future<void> _uploadImage() async {
    if (_selectedImage != null) {
      try {
        _isLoading = true;
        setState(() {

        });
        // Create a reference to the Firebase Storage bucket
        final Reference storageRef = FirebaseStorage.instance.ref().child('profile_images');

        // Upload the image to Firebase Storage
        TaskSnapshot snapshot = await storageRef.putFile(_selectedImage!);

        // Get the download URL of the uploaded image
        String downloadURL = await snapshot.ref.getDownloadURL();

        // Update the user's profile image URL in Firestore
        // Replace 'userId' with the actual user ID
        //await _usersCollection.doc('userId').update({'profileImage': downloadURL});
        await _userAuthController.updateProfileData(nameET.text, mobileET.text, addressET.text, downloadURL);

        setState(() {
          _imageURL = downloadURL;
        });

        Get.snackbar("Profile Info", "Image uploaded successfully");
        _isLoading = false;
        setState(() {

        });
      } catch (e) {
        _isLoading = false;
        setState(() {

        });
        Get.snackbar("Profile Info", "Image upload failed");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getUserInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Center(
              child: CircleAvatar(
                radius: 70,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : _imageURL != null
                    ? NetworkImage(_imageURL!) as ImageProvider<Object>?
                    : null,
                child: _selectedImage == null && _imageURL == null ? const Icon(Icons.person) : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            isobs: false,
            hintText: "Name",
            textInputType: TextInputType.text,
            prefixIcon: Icons.person,
            controller: nameET,
            validator: (value) {
              if (value!.isEmpty) {
                return "Please type your name";
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          AppTextField(
            isobs: false,
            textFieldEnable: false,
            hintText: "Email",
            textInputType: TextInputType.emailAddress,
            prefixIcon: Icons.email,
            controller: emailET,
            validator: (value) {
              if (value!.isEmpty) {
                return "Please type your email";
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          AppTextField(
            isobs: false,
            hintText: "Mobile",
            textInputType: TextInputType.phone,
            prefixIcon: Icons.call,
            controller: mobileET,
            validator: (value) {
              if (value!.isEmpty) {
                return "Please type your mobile no";
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          AppTextField(
            isobs: false,
            maxLine: 3,
            hintText: "Address",
            textInputType: TextInputType.text,
            prefixIcon: Icons.location_city,
            controller: addressET,
            validator: (value) {
              if (value!.isEmpty) {
                return "Please type your address";
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          _isLoading? const Center(child: CircularProgressIndicator(),):
          AppButton(
            backgroundColor: MyColors.brandColor,
            buttonText: "Update Profile",
            onTap: () {
              _uploadImage().then((value){
                _userAuthController.updateProfileData(nameET.text, mobileET.text, addressET.text, _imageURL.toString());
              }).then((value){
                Get.to(const HomeScreen());
                Get.snackbar("Profile Updated", "Successfully updated your profile information",snackPosition: SnackPosition.BOTTOM);
              });
            },
          ),

          AppButton(
              buttonText: 'Switch To Admin Mode', onTap: (){
            Get.offAll(const AdminScreen());
          }),
        ],
      ),
    );
  }
}
