import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:yumnotes/constants/constants.dart';
import 'package:yumnotes/widgets/textWidget.dart';
import 'package:anim_search_bar/anim_search_bar.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppbar({required this.title, required this.icon});

  final String title;
  bool icon;

  @override
  Widget build(BuildContext context) {
    TextEditingController textController = TextEditingController();

    return AppBar(
      backgroundColor: kAppbarBg,
      leading: icon == true
          ? Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Image(
                image: AssetImage("assets/fav.png"),
              ),
            )
          : InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back),
            ),
      title: TextWidget(
        text: title,
        size: 16.sp,
        color: Colors.white,
        weight: FontWeight.w600,
      ),
      actions: [
        icon == true
            ? AnimSearchBar(
                color: kAppbarBg,
                searchIconColor: Colors.white,
                width: 350,
                textController: textController,
                onSubmitted: (query) {
                  // handle the submitted query here
                },
                onSuffixTap: () {
                  textController.clear();
                },
              )
            : Container(),
        SizedBox(
          width: 2.w,
        ),
      ],
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
