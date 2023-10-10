import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:yumnotes/constants/constants.dart';

class ButtonWidget extends StatelessWidget {
  ButtonWidget({required this.text});

  final text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0xffC45911).withOpacity(0.4),
            blurRadius: 10,
            offset: Offset(0, 0),
          ),
        ],
        color: kButtonBac,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.5.h, horizontal: 4.h),
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: kButtonText,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.045,
            ),
          ),
        ),
      ),
    );
  }
}

class SecondaryButtonWidget extends StatelessWidget {
  final void Function()? onTap;
  SecondaryButtonWidget({required this.text, this.onTap});

  final text;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0xffffffff).withOpacity(0.4),
              blurRadius: 10,
              offset: Offset(0, 0),
            ),
          ],
          color: Color(0xffF4F4F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 2.5.h, horizontal: 4.h),
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: secondaryText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.045,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
