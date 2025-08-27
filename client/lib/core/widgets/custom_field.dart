import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {

  final String hintText;

  final TextEditingController? controller;

  final bool isObscure;

  final bool readOnly;

  final VoidCallback? onTap;

  const CustomField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isObscure = false,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(hintText: hintText),
      controller: controller,
      obscureText: isObscure,
      readOnly: readOnly,
      onTap: onTap,
      validator: (value) {
        if (value!.trim().isEmpty) {
          return "$hintText is missing!";
        }
        if(hintText == "Email" && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return "Please enter a valid email address!";
        }
        if(hintText == "Password" && value.length < 6) {
          return "Password must be at least 6 characters long!";
        }
        return null;
      },
    );
  }
}
