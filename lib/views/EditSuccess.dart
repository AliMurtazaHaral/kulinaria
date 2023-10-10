import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:yumnotes/constants/constants.dart';
import 'package:yumnotes/views/SingleRestaurant.dart';
import 'package:yumnotes/widgets/textWidget.dart';

class EditSuccess extends StatefulWidget {
  const EditSuccess({super.key});

  @override
  State<EditSuccess> createState() => _EditSuccessState();
}

movetonextscreen(BuildContext context) {
  Future.delayed(Duration(seconds: 2), () {
    Navigator.pop(context);
  });
}

class _EditSuccessState extends State<EditSuccess> {
  @override
  void initState() {
    movetonextscreen(context);
    super.initState();
  }

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
              Container(
                decoration: BoxDecoration(
                    color: yellowcol, borderRadius: BorderRadius.circular(100)),
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.edit,
                  color: kAppbarText,
                  size: 50.sp,
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              TextWidget(
                text: "Edited",
                size: 24.sp,
                color: primaryText,
                weight: FontWeight.w700,
                align: TextAlign.center,
              ),
              SizedBox(
                height: 1.h,
              ),
              TextWidget(
                text: "Successfully",
                size: 24.sp,
                color: primaryText,
                weight: FontWeight.w700,
                align: TextAlign.center,
              ),
              SizedBox(
                height: 2.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
