import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:yumnotes/constants/constants.dart';
import 'package:yumnotes/widgets/textWidget.dart';

class ForgetPasswordSuccess extends StatelessWidget {
  const ForgetPasswordSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 70.sp,
                color: yellowcol,
              ),
              SizedBox(
                height: 2.h,
              ),
              TextWidget(
                text: "Success",
                size: 24.sp,
                color: primaryText,
                weight: FontWeight.w600,
                align: TextAlign.center,
              ),
              SizedBox(
                height: 2.h,
              ),
              TextWidget(
                text: "Please check your email for create a new password",
                size: 15.sp,
                color: Color(0xff6B7280),
                weight: FontWeight.w400,
                align: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
