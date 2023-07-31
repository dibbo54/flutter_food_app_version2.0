import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../utils/my_colors.dart';
import '../utils/my_text_style.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    TextEditingController _emailController = TextEditingController();

    @override
    void dispose() {
      _emailController.dispose();
      super.dispose();
    }

    Future passwordReset() async {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _emailController.text.trim());

        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text('Password reset link sent! Check your email pls'),
              backgroundColor: Colors.white,
            );
          },
        );
      } on FirebaseAuthException catch (e) {
        Get.snackbar(
          backgroundColor: Colors.white,
          "Invalid Email",
          e.message.toString(),
          duration: const Duration(seconds: 3),
        );
      }
    }

    return Scaffold(
      backgroundColor: MyColors.brandColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.emoji_food_beverage_outlined,
                    size: 120,
                    color: Colors.white,
                  ),
                  Text(
                    "Enter your register email address, we'll sent reset link to your email address",
                    style: MyStyle.mySubTitleTextStyle(Colors.white),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  AppTextField(
                    validator: (value) {
                      return null;
                    },
                    isobs: false,
                    controller: _emailController,
                    hintText: 'Email Address',
                    textInputType: TextInputType.emailAddress,
                    prefixIcon: Icons.email,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: AppButton(
                      //onTap: () {},
                      buttonTextColor: Colors.black,
                      backgroundColor: Colors.white,
                      buttonText: 'Reset Password',
                      onTap: passwordReset,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text(
                      "Already Have an account? Login Now",
                      style: MyStyle.mySubTitleTextStyle(Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
