import 'package:flutter/material.dart';

import '../getxControllerFile/user_auth_controller.dart';
import '../utils/my_colors.dart';
import '../utils/my_text_style.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'package:get/get.dart';

import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final UserAuthController _userAuthController = Get.find<UserAuthController>();

  TextEditingController emailET = TextEditingController();
  TextEditingController passwordET = TextEditingController();
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailET.dispose();
    passwordET.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.brandColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _globalKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.emoji_food_beverage_outlined,
                      size: 120,
                      color: Colors.white,
                    ),
                    Text(
                      "Join with us",
                      style: MyStyle.myTitleTextStyle(Colors.white),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    AppTextField(
                      isobs: false,
                      validator: (value) {
                        if (emailET.text.isEmpty) {
                          return "Please type your email address";
                        }
                        return null;
                      },
                      controller: emailET,
                      hintText: 'Email Address',
                      textInputType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    AppTextField(
                      isobs: true,
                      validator: (value) {
                        if (passwordET.text.isEmpty) {
                          return "Please type your password";
                        }
                        return null;
                      },
                      controller: passwordET,

                      hintText: 'Password',
                      textInputType: TextInputType.visiblePassword,
                      prefixIcon: Icons.password,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    AppTextField(
                      isobs: true,
                      validator: (value) {
                        if (value=="") {
                          return "Please confirm your password";
                        }
                        return null;
                      },
                      controller: TextEditingController(),
                      hintText: 'Confirm Password',

                      textInputType: TextInputType.visiblePassword,
                      prefixIcon: Icons.password,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Obx(() {
                      return _userAuthController.isLoading.value
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: AppButton(
                                buttonTextColor: Colors.black,
                                backgroundColor: Colors.white,
                                buttonText: 'Sign Up',
                                onTap: () {
                                  if (_globalKey.currentState!.validate()) {
                                    _userAuthController
                                        .signUp(emailET.text, passwordET.text)
                                        .then((isValidUser) {
                                      if (_userAuthController
                                              .currentUser.value !=
                                          null) {
                                        Get.offAll(const HomeScreen());
                                      } else {
                                        // Display an error message
                                        Get.snackbar(
                                          "Login Error",
                                          "Invalid email or password",
                                          duration: const Duration(seconds: 3),
                                        );
                                      }
                                    }).catchError((error) {
                                      Get.snackbar(
                                        "Login Error",
                                        error.toString(),
                                        duration: const Duration(seconds: 3),
                                      );
                                    });
                                  }
                                },
                              ),
                            );
                    }),
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
      ),
    );
  }
}
