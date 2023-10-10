import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AuthTextField extends StatelessWidget {
  AuthTextField({
    required this.obsecureText,
    required this.text,
    required this.controller,
  });

  final bool obsecureText;
  final String text;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textCapitalization: TextCapitalization.words,
      style: TextStyle(
        color: Color(0xff9CA3AF),
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.3,
      ),
      obscureText: obsecureText,
      controller: controller,
      decoration: InputDecoration(
        hintText: text,
        hintStyle: TextStyle(
          color: Color(0xff9CA3AF),
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xffBEC5D1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xffBEC5D1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xffBEC5D1),
          ),
        ),
      ),
    );
  }
}
