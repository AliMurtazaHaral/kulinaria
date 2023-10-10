import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:yumnotes/constants/constants.dart';

class CustomInfoWindow {
  static Widget CustomPopup(
    BuildContext context, {
    Function? heartButtonPressed,
    addButtonPressed,
    onButtonVisitPressed,
    required String imageUrl,
    required String title,
    required String distance,
  }) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.15,
      width: MediaQuery.of(context).size.width *
          0.9, // Adjust the width according to your needs
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width * 0.25,
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.05,
          ),
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width * 0.25,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    title,
                    maxLines: 1,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    minFontSize: 8,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Text(
                    distance,
                    style: const TextStyle(color: yellowcol, fontSize: 11),
                  ),
                  // TextButton(
                  //   onPressed: onButtonVisitPressed,
                  //   child: const Text("Visit the Restarunt",
                  //       style: TextStyle(color: kButtonBac)),
                  // ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: IconButton(
                            iconSize: 40.sp,
                            color: kButtonBac,
                            onPressed: onButtonVisitPressed,
                            icon: const ImageIcon(
                                AssetImage("assets/visitrestauranticon.png")),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            iconSize: 40.sp,
                            color: kButtonBac,
                            onPressed: () => {heartButtonPressed!()},
                            icon:
                                const ImageIcon(AssetImage("assets/Love.png")),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            iconSize: 40.sp,
                            color: kButtonBac,
                            onPressed: () => {addButtonPressed!()},
                            icon: const ImageIcon(
                                AssetImage("assets/add-icon.png")),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
