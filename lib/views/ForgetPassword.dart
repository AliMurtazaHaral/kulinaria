import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:yumnotes/constants/constants.dart';
import 'package:yumnotes/views/DeleteSuccess.dart';
import 'package:yumnotes/views/Favourites.dart';
import 'package:yumnotes/views/ForgetPasswordSuccess.dart';
import 'package:yumnotes/views/MyRestaurants.dart';
import 'package:yumnotes/views/Profile.dart';
import 'package:yumnotes/views/SingleRestaurant.dart';
import 'package:yumnotes/widgets/authTextField.dart';
import 'package:yumnotes/widgets/buttonWidget.dart';
import 'package:yumnotes/widgets/customAppbar.dart';
import 'package:yumnotes/widgets/textWidget.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  TextEditingController _emailcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: "Forget Password",
        icon: false,
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 8.h,
              ),
              TextWidget(
                text: "Enter your registered email below",
                size: 15.sp,
                color: primaryText,
                weight: FontWeight.w600,
              ),
              SizedBox(
                height: 4.h,
              ),
              TextWidget(
                text: "Email address",
                size: 13.sp,
                weight: FontWeight.w600,
                color: Color(0xff374151),
                align: TextAlign.left,
              ),
              SizedBox(
                height: 1.h,
              ),
              AuthTextField(
                obsecureText: false,
                text: "Eg namaemail@emailkamu.com",
                controller: _emailcontroller,
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  resetPassword(_emailcontroller.text);
                },
                child: ButtonWidget(text: "Submit"),
              ),
              SizedBox(
                height: 8.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Future<void> resetPassword(String email) async {
    if (_emailcontroller.text.isNotEmpty) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailcontroller.text);
      Fluttertoast.showToast(msg: "Link has been sent to your entered email");
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg: "You have entered wrong email");
    }
  }
}
