import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:sizer/sizer.dart';
import 'package:yumnotes/constants/constants.dart';
import 'package:yumnotes/widgets/textWidget.dart';

class PremiumBanner extends StatefulWidget {
  const PremiumBanner({super.key});

  @override
  State<PremiumBanner> createState() => _PremiumBannerState();
}

class _PremiumBannerState extends State<PremiumBanner> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: kAppbarBg, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: yellowcol,
                ),
                padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 1.h),
                child: TextWidget(
                  text: "PRO",
                  size: 16.sp,
                  color: kAppbarText,
                  weight: FontWeight.bold,
                  align: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              width: 3.w,
            ),
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: "Get Premium Features",
                    size: 13.sp,
                    color: kAppbarText,
                    weight: FontWeight.bold,
                  ),
                  // SizedBox(
                  //   height: 1.h,
                  // ),
                  TextWidget(
                    text: "Buy Premium plan to get premium features",
                    size: 10.sp,
                    color: kAppbarText,
                    weight: FontWeight.normal,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
