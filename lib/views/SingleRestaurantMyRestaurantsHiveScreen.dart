import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yumnotes/constants/constants.dart';
import 'package:yumnotes/models/favrestaurant.dart';
import 'package:yumnotes/models/myrestaurants.dart';
import 'package:yumnotes/views/AddNote.dart';
import 'package:yumnotes/views/DeleteSuccess.dart';
import 'package:yumnotes/views/EditNote.dart';
import 'package:yumnotes/views/EditSuccess.dart';
import 'package:yumnotes/widgets/customAppbar.dart';
import 'package:yumnotes/widgets/textWidget.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:yumnotes/constants/constants.dart';

import '../models/AdHelper.dart';
import 'AddNoteFavouritesHive.dart';
import 'AddNotesMyRestaurantsHive.dart';
import 'EditNoteFavouritesHive.dart';
import 'EditNoteMyRestaurantHive.dart';

final box = Hive.box<MyRestaurants>('my');

class SingleRestaurantMyRestaurantsHiveScreen extends StatefulWidget {
  SingleRestaurantMyRestaurantsHiveScreen(
      {super.key,
      required this.openingHours,
      required this.imgUrl,
      required this.website,
      required this.phoneNumber,
      required this.address,
      required this.resName,
      required this.index});
  String? resName;
  String? address;
  String? imgUrl;
  String? phoneNumber;
  String? website;
  List<dynamic> openingHours;
  int? index;

  @override
  State<SingleRestaurantMyRestaurantsHiveScreen> createState() =>
      _SingleRestaurantMyRestaurantsHiveScreenState();
}

class _SingleRestaurantMyRestaurantsHiveScreenState
    extends State<SingleRestaurantMyRestaurantsHiveScreen> {
  bool _customTileExpanded = false;
  BannerAd? _bannerAd;

// COMPLETE: Add _interstitialAd
  InterstitialAd? _interstitialAd;

// COMPLETE: Add _rewardedAd
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    // COMPLETE: Load a banner ad
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();

    // COMPLETE: Load a rewarded Ad
    _loadRewardedAd();
    _loadInterstitialAd();
  }
// COMPLETE: Implement _loadRewardedAd()
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                ad.dispose();
                _rewardedAd = null;
              });
              _loadRewardedAd();
            },
          );

          setState(() {
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          debugPrint('Failed to load a rewarded ad: ${err.message}');
        },
      ),
    );
  }
  void _moveToHome() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _moveToHome();
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          debugPrint('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "", icon: false),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_bannerAd != null)
                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          children: [
                            Expanded(
                              flex: 9,
                              child: TextWidget(
                                text: widget.resName,
                                size: 18.sp,
                                color: primaryText,
                                weight: FontWeight.w600,
                                align: TextAlign.left,
                              ),
                            ),
                            SizedBox(
                              width: 2.w,
                            ),
                            Expanded(
                              flex: 3,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddNoteMyRestaurantsHiveScreen(
                                        address: widget.address,
                                        openingHours: widget.openingHours,
                                        imgUrl: widget.imgUrl,
                                        resName: widget.resName,
                                        phoneNumber: widget.phoneNumber,
                                        index: widget.index,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: yellowcol,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2.w, vertical: 1.h),
                                  child: Center(
                                    child: TextWidget(
                                      text: "Add Note",
                                      color: kAppbarText,
                                      size: 10.0.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.location_on,
                                color: yellowcol,
                                size: 18.sp,
                              ),
                            ),
                            SizedBox(
                              width: 1.w,
                            ),
                            Expanded(
                              flex: 11,
                              child: TextWidget(
                                text: widget.address,
                                size: 12.sp,
                                weight: FontWeight.w400,
                                align: TextAlign.left,
                                color: Color(0xff6B7280),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Image(
                          image: NetworkImage(widget.imgUrl.toString()),
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ExpansionTile(
                              iconColor: yellowcol,
                              collapsedIconColor: yellowcol,
                              tilePadding: EdgeInsets.all(0),
                              leading: Icon(
                                Icons.timer_rounded,
                                color: yellowcol,
                                size: 18.sp,
                              ),
                              title: TextWidget(
                                text: "Opening Hours",
                                size: 12.sp,
                                weight: FontWeight.w600,
                                align: TextAlign.left,
                                color: primaryText,
                              ),
                              trailing: Icon(
                                _customTileExpanded
                                    ? Icons.arrow_drop_down_circle
                                    : Icons.arrow_drop_down,
                              ),
                              children: <Widget>[
                                widget.openingHours.length == 7
                                    ? Padding(
                                        padding: EdgeInsets.only(left: 40),
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: TextWidget(
                                                text: widget.openingHours[0],
                                                size: 12.sp,
                                                weight: FontWeight.w600,
                                                align: TextAlign.left,
                                                color: primaryText,
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: TextWidget(
                                                text: widget.openingHours[1],
                                                size: 12.sp,
                                                weight: FontWeight.w600,
                                                align: TextAlign.left,
                                                color: primaryText,
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: TextWidget(
                                                text: widget.openingHours[2],
                                                size: 12.sp,
                                                weight: FontWeight.w600,
                                                align: TextAlign.left,
                                                color: primaryText,
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: TextWidget(
                                                text: widget.openingHours[3],
                                                size: 12.sp,
                                                weight: FontWeight.w600,
                                                align: TextAlign.left,
                                                color: primaryText,
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: TextWidget(
                                                text: widget.openingHours[4],
                                                size: 12.sp,
                                                weight: FontWeight.w600,
                                                align: TextAlign.left,
                                                color: primaryText,
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: TextWidget(
                                                text: widget.openingHours[5],
                                                size: 12.sp,
                                                weight: FontWeight.w600,
                                                align: TextAlign.left,
                                                color: primaryText,
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: TextWidget(
                                                text: widget.openingHours[6],
                                                size: 12.sp,
                                                weight: FontWeight.w600,
                                                align: TextAlign.left,
                                                color: primaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : TextWidget(
                                        text: widget.openingHours[0],
                                        size: 12.sp,
                                        weight: FontWeight.w600,
                                        align: TextAlign.left,
                                        color: primaryText,
                                      ),
                              ],
                              onExpansionChanged: (bool expanded) {
                                setState(() {
                                  _customTileExpanded = expanded;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 1.h,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Icon(
                                    Icons.call,
                                    color: yellowcol,
                                    size: 18.sp,
                                  ),
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                                Expanded(
                                  flex: 11,
                                  child: GestureDetector(
                                    onTap: () =>
                                        launch("tel://${widget.phoneNumber}"),
                                    child: TextWidget(
                                        text: widget.phoneNumber,
                                        size: 12.sp,
                                        weight: FontWeight.w600,
                                        align: TextAlign.left,
                                        color: primaryText),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 0.5.h,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Icon(
                                    Icons.location_on,
                                    color: yellowcol,
                                    size: 18.sp,
                                  ),
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                                Expanded(
                                  flex: 11,
                                  child: TextWidget(
                                      text: widget.address,
                                      size: 12.sp,
                                      weight: FontWeight.w600,
                                      align: TextAlign.left,
                                      color: primaryText),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 0.5.h,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Icon(
                                    Icons.web_rounded,
                                    color: yellowcol,
                                    size: 18.sp,
                                  ),
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                                Expanded(
                                  flex: 11,
                                  child: TextWidget(
                                      text: widget.website,
                                      size: 12.sp,
                                      weight: FontWeight.w600,
                                      align: TextAlign.left,
                                      color: primaryText),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 6.h,
                        ),
                        TextWidget(
                          text: "Notes",
                          size: 18.sp,
                          color: primaryText,
                          weight: FontWeight.w600,
                          align: TextAlign.left,
                        ),
                        ValueListenableBuilder(
                            valueListenable: box.listenable(),
                            builder: (context, Box<MyRestaurants> box, _) {
                              if (box.getAt(widget.index!)!.notes.isEmpty) {
                                return SizedBox(
                                  height: 2.h,
                                );
                              } else {
                                return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount:
                                        box.getAt(widget.index!)!.notes.length,
                                    itemBuilder: (context, index) {
                                      final restaurant = box
                                          .getAt(widget.index!)!
                                          .notes[index];
                                      return Card(
                                        elevation: 1.5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10.0), // Set the desired border radius
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 3.w, vertical: 2.5.h),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Image.file(
                                                  File(restaurant.image!),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 4.w,
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    TextWidget(
                                                      text: restaurant?.date
                                                              .toString() ??
                                                          "No date provided",
                                                      size: 10.sp,
                                                      color: Color(0xff6B7280),
                                                      weight: FontWeight.w400,
                                                      align: TextAlign.left,
                                                    ),
                                                    TextWidget(
                                                      text: restaurant.note ??
                                                          "No Data Provided",
                                                      size: 15.sp,
                                                      color: Color(0xff6B7280),
                                                      weight: FontWeight.w600,
                                                      align: TextAlign.left,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: 1.w,
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: InkWell(
                                                  onTap: () {
                                                    // Navigator.push(
                                                    //   context,
                                                    //   MaterialPageRoute(
                                                    //     builder: (context) => SingleRestaurantScreen(),
                                                    //   ),
                                                    // );
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Material(
                                                          elevation: 1,
                                                          shadowColor:
                                                              Color(0xffC45911),
                                                          color: Colors.white,
                                                          shape: CircleBorder(),
                                                          child: IconButton(
                                                            icon: Icon(
                                                              Icons.edit,
                                                              color: yellowcol,
                                                              size: 12.sp,
                                                            ),
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          EditNoteMyRestaurantsHiveScreen(
                                                                    imgUrl:
                                                                        restaurant
                                                                            .image,
                                                                    title: restaurant
                                                                        .title,
                                                                    note: restaurant
                                                                        .note,
                                                                    index: widget
                                                                        .index,
                                                                    notesindex:
                                                                        index,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 2.w,
                                                      ),
                                                      Expanded(
                                                        child: Material(
                                                          elevation: 1,
                                                          shadowColor:
                                                              Color(0xffC45911),
                                                          color: Colors.white,
                                                          shape: CircleBorder(),
                                                          child: IconButton(
                                                            icon: Icon(
                                                              Icons.delete,
                                                              color: yellowcol,
                                                              size: 12.sp,
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              final myRestaurants =
                                                                  box.getAt(widget
                                                                      .index!);
                                                              myRestaurants
                                                                  ?.notes
                                                                  .removeAt(
                                                                      index);
                                                              box.putAt(
                                                                  widget.index!,
                                                                  myRestaurants!);
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          DeleteSuccess(),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              }
                            }),
                        SizedBox(
                          height: 2.h,
                        ),
                        SizedBox(
                          height: 6.h,
                        ),
                        TextWidget(
                          text: "My Rating",
                          size: 18.sp,
                          color: primaryText,
                          weight: FontWeight.w600,
                          align: TextAlign.left,
                        ),
                        SizedBox(
                          height: 6.h,
                        ),
                        Card(
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // Set the desired border radius
                          ),
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.w, vertical: 2.5.h),
                              child: ValueListenableBuilder(
                                valueListenable: box.listenable(),
                                builder: (context, Box<MyRestaurants> box, _) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Center(
                                        child: RatingBar.builder(
                                          direction: Axis.horizontal,
                                          initialRating:
                                              box.getAt(widget.index!)!.stars,
                                          allowHalfRating: false,
                                          itemCount: 5,
                                          itemPadding: EdgeInsets.symmetric(
                                              horizontal: 0.0),
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            size: 5,
                                            color: Colors.amber,
                                          ),
                                          updateOnDrag: false,
                                          onRatingUpdate: (value) async {
                                            MyRestaurants? restaurant =
                                                box.getAt(widget.index!);
                                            restaurant!.stars = value;
                                            box.putAt(
                                                widget.index!, restaurant);
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: Material(
                                          elevation: 1,
                                          shadowColor: Color(0xffC45911),
                                          color: Colors.white,
                                          shape: CircleBorder(),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: yellowcol,
                                              size: 12.sp,
                                            ),
                                            onPressed: () async {
                                              MyRestaurants? restaurant =
                                                  box.getAt(widget.index!);
                                              restaurant!.stars = 0.0;
                                              box.putAt(
                                                  widget.index!, restaurant);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DeleteSuccess(),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              )),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
