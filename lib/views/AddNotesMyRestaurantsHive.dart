import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yumnotes/constants/constants.dart';
import 'package:yumnotes/models/myrestaurants.dart';
import 'package:yumnotes/models/notesModel.dart';
import 'package:yumnotes/widgets/authTextField.dart';
import 'package:yumnotes/widgets/buttonWidget.dart';
import 'package:yumnotes/widgets/customAppbar.dart';
import 'package:yumnotes/widgets/textWidget.dart';

import '../models/AdHelper.dart';
import '../models/favrestaurant.dart';
import '../models/user_model.dart';

final box = Hive.box<MyRestaurants>('my');
final _auth = FirebaseAuth.instance;
User? user = _auth.currentUser;
bool image = false;

class AddNoteMyRestaurantsHiveScreen extends StatefulWidget {
  AddNoteMyRestaurantsHiveScreen(
      {super.key,
      required this.address,
      required this.openingHours,
      required this.imgUrl,
      required this.resName,
      required this.phoneNumber,
      required this.index});
  String? resName;
  String? address;
  String? imgUrl;
  String? phoneNumber;
  List<dynamic> openingHours;
  int? index;
  @override
  State<AddNoteMyRestaurantsHiveScreen> createState() =>
      _AddNoteMyRestaurantsHiveScreenState();
}

class _AddNoteMyRestaurantsHiveScreenState
    extends State<AddNoteMyRestaurantsHiveScreen> {
  TextEditingController _titlecontroller = TextEditingController();
  TextEditingController _notecontroller = TextEditingController();
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
      appBar: CustomAppbar(title: "Add Note", icon: false),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
          child: Column(
            children: [
              TextWidget(
                text: widget.resName,
                size: 18.sp,
                color: primaryText,
                weight: FontWeight.w600,
                align: TextAlign.left,
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
                height: 3.h,
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
                          onTap: () => launch("tel://${widget.phoneNumber}"),
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
                            text: widget.address,
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
                text: "Add Notes",
                size: 18.sp,
                color: primaryText,
                weight: FontWeight.w600,
                align: TextAlign.left,
              ),
              SizedBox(
                height: 2.h,
              ),
              GestureDetector(
                onTap: () {
                  _getFromGallery();
                },
                child: Container(
                  width: 200.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                      image: NetworkImage(url),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: "Title",
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
                    text: "Enter title",
                    controller: _titlecontroller,
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  TextWidget(
                    text: "Note",
                    size: 13.sp,
                    weight: FontWeight.w600,
                    color: Color(0xff374151),
                    align: TextAlign.left,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  TextFormField(
                    maxLines: 3,
                    controller: _notecontroller,
                    decoration: InputDecoration(
                      hintText: "Enter Note",
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
                  ),
                  // AuthTextField(
                  //   obsecureText: false,
                  //   text: "Enter note",
                  //   controller: _notecontroller,

                  // ),
                ],
              ),
              SizedBox(
                height: 4.h,
              ),
              InkWell(
                  onTap: () async {
                    if (_rewardedAd != null) {
                      _rewardedAd?.show(
                        onUserEarnedReward: (_, reward) {
                          //QuizManager.instance.useHint();
                          if (_titlecontroller.text == "" ||
                              _notecontroller.text == "" ||
                              pickedFile?.path == null) {
                            Fluttertoast.showToast(
                                msg: "Please Enter all the details");
                          } else {
                            DateTime now = DateTime.now();
                            DateTime date = DateTime(now.year, now.month, now.day);
                            Notes newNote = Notes(
                                title: _titlecontroller.text,
                                image: pickedFile?.path,
                                note: _notecontroller.text,
                                date: date);
                            MyRestaurants? restaurant = box.getAt(widget.index!);
                            restaurant!.notes.add(newNote);
                            box.putAt(widget.index!, restaurant);
                            Fluttertoast.showToast(msg: "Note added");
                            Navigator.pop(context);
                          }
                        },
                      );
                    }

                  },
                  child: ButtonWidget(text: "Submit"))
            ],
          ),
        ),
      ),
    );
  }

  DateTime now = DateTime.now();
  String url =
      "https://getstamped.co.uk/wp-content/uploads/WebsiteAssets/Placeholder.jpg";
  File? imageFile;
  XFile? pickedFile;
  _getFromGallery() async {
    pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    if (pickedFile != null) {
      setState(() async {
        File file = File(pickedFile!.path);
        imageFile = File('${pickedFile?.path}');
      });
    }
  }
}
