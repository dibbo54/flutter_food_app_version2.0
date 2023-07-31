
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.buttonText,
    required this.onTap, this.backgroundColor, this.buttonTextColor,
  });
  final String buttonText;
  final VoidCallback onTap;
  final Color? backgroundColor, buttonTextColor;


  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor
      ),
      child: Text(buttonText,style: TextStyle(color: buttonTextColor),),
    );
  }
}
