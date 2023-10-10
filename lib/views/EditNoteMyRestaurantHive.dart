import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:yumnotes/models/myrestaurants.dart';

import '../constants/constants.dart';
import '../models/AdHelper.dart';
import '../models/favrestaurant.dart';
import '../models/notesModel.dart';
import '../widgets/authTextField.dart';
import '../widgets/buttonWidget.dart';
import '../widgets/textWidget.dart';

final box = Hive.box<MyRestaurants>('my');

class EditNoteMyRestaurantsHiveScreen extends StatefulWidget {
  EditNoteMyRestaurantsHiveScreen(
      {Key? key,
      required this.imgUrl,
      required this.title,
      required this.note,
      required this.index,
      required this.notesindex})
      : super(key: key);

  String? imgUrl;
  String? title;
  String? note;
  int? index;
  int? notesindex;
  @override
  State<EditNoteMyRestaurantsHiveScreen> createState() =>
      _EditNoteMyRestaurantsHiveScreenState();
}

class _EditNoteMyRestaurantsHiveScreenState
    extends State<EditNoteMyRestaurantsHiveScreen> {
  TextEditingController _titlecontroller = TextEditingController();
  TextEditingController _notecontroller = TextEditingController();
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
      body: SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.only(left: 18, right: 18),
        child: Column(
          children: [
            SizedBox(
              height: 30.h,
            ),
            TextWidget(
              text: "Edit Note",
              size: 18.sp,
              color: primaryText,
              weight: FontWeight.w600,
              align: TextAlign.left,
            ),
            SizedBox(
              height: 2.h,
            ),
            SizedBox(
              height: 2.h,
            ),
            GestureDetector(
              onTap: () {
                _getFromGallery();
              },
              child: CircleAvatar(
                radius: 50.0,
                backgroundColor: Colors.grey[300],
                backgroundImage: FileImage(
                  File(widget.imgUrl!),
                ),
              ),
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
                  text: widget.title!,
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
                AuthTextField(
                  obsecureText: false,
                  text: widget.note!,
                  controller: _notecontroller,
                ),
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
                        final favRestaurants = box.getAt(widget.index!);
                        DateTime now = DateTime.now();
                        DateTime date = DateTime(now.year, now.month, now.day);
                        final Notes newnote = Notes(
                          title: _titlecontroller.text.isEmpty
                              ? favRestaurants?.notes[widget.notesindex!].title
                              : _titlecontroller.text,
                          image: pickedFile?.path ??
                              favRestaurants?.notes[widget.notesindex!].image,
                          note: _notecontroller.text.isEmpty
                              ? favRestaurants?.notes[widget.notesindex!].note
                              : _notecontroller.text,
                          date: date,
                        );
                        favRestaurants?.notes[widget.notesindex!] = newnote;
                        box.putAt(widget.index!, favRestaurants!);

                        Navigator.pop(context);
                      },
                    );
                  }

                },
                child: ButtonWidget(text: "Submit"))
          ],
        ),
      )),
    );
  }

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
        //final url1 = await storage.ref('DonorProfileImage/$pickedFile?.name').putFile(file);
        //StorageModel storageModel = StorageModel();
        //storageModel.uploadDonorImage(pickedFile?.path, pickedFile?.name);
      });
    }
  }
}
