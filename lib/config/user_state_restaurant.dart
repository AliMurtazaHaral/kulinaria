import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:sizer/sizer.dart';
import 'package:yumnotes/models/myrestaurants.dart';
import 'package:yumnotes/views/Login.dart';
import 'package:yumnotes/views/PremiumScreen.dart';
import 'package:yumnotes/views/Profile.dart';
import 'package:yumnotes/views/SingleRestaurantMyRestaurantsHiveScreen.dart';
import 'package:yumnotes/views/Splash.dart';
import 'package:yumnotes/views/bottomBar.dart';

import '../constants/constants.dart';
import '../models/AdHelper.dart';
import '../models/user_model.dart';
import '../views/MyRestaurants.dart';
import '../widgets/customAppbar.dart';
import '../widgets/textWidget.dart';

final _auth = FirebaseAuth.instance;
User? user = _auth.currentUser;
final box = Hive.box<MyRestaurants>('my');

class UserStateRestaurant extends StatefulWidget {
  const UserStateRestaurant({Key? key}) : super(key: key);

  @override
  State<UserStateRestaurant> createState() => _UserStateRestaurantState();
}

class _UserStateRestaurantState extends State<UserStateRestaurant> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  getuserinfo() async{
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMapRegsitration(value.data());
    });
  }
  BannerAd? _bannerAd;

  // COMPLETE: Add _interstitialAd
  InterstitialAd? _interstitialAd;

  // COMPLETE: Add _rewardedAd
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    // COMPLETE: Load a banner ad
    getuserinfo();
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

  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              //_moveToHome();
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
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        if (userSnapshot.data == null) {
          return Scaffold(
            appBar: CustomAppbar(
              title: "My Restaurants",
              icon: true,
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: "My Restaurants",
                    size: 20.sp,
                    color: primaryText,
                    weight: FontWeight.w700,
                    align: TextAlign.center,
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  if (_bannerAd != null)
                    Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                  ValueListenableBuilder(
                    valueListenable: box.listenable(),
                    builder: (context, Box<MyRestaurants> box, _) {
                      if (box.values.isEmpty) {
                        return const Center(
                          child: Text("No Restaurants"),
                        );
                      } else {
                        return Flexible(
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: box.values.length,
                              itemBuilder: (context, index) {
                                final restaurant = box.getAt(index);
                                return Card(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 3.w, vertical: 3.w),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            width: 20
                                                .w, // Specify your desired width
                                            height: 10.0
                                                .h, // Specify your desired height
                                            child: Image(
                                              image: NetworkImage(
                                                  restaurant!.imgUrl),
                                              fit: BoxFit
                                                  .cover, // Adjust the image fit based on your requirements
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 4.w,
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              TextWidget(
                                                text: restaurant.name,
                                                size: 13.sp,
                                                color: primaryText,
                                                weight: FontWeight.w600,
                                                align: TextAlign.left,
                                              ),
                                              ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                visualDensity:
                                                VisualDensity.compact,
                                                horizontalTitleGap: 0,
                                                leading: Icon(
                                                  Icons.location_on,
                                                  color: yellowcol,
                                                  size: 20.sp,
                                                ),
                                                title: TextWidget(
                                                  text: restaurant.address,
                                                  size: 9.sp,
                                                  weight: FontWeight.w400,
                                                  color: Color(0xff6B7280),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: InkWell(
                                            onTap: () async {
                                              if (_interstitialAd != null) {
                                                _interstitialAd?.show();
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SingleRestaurantMyRestaurantsHiveScreen(
                                                          index: index,
                                                          address: restaurant.address,
                                                          imgUrl: restaurant.imgUrl,
                                                          openingHours:
                                                          restaurant.openingHours,
                                                          phoneNumber:
                                                          restaurant.phoneNumber,
                                                          resName: restaurant.name,
                                                          website: restaurant.website,
                                                        ),
                                                  ),
                                                );
                                              } else {

                                              }

                                            },
                                            child: const Image(
                                              image: AssetImage(
                                                  "assets/viewicon.png"),
                                              width: 35,
                                              height: 35,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        } else if (userSnapshot.hasData) {
          if (loggedInUser.payment == null) {
             FirebaseAuth.instance.signOut();
          }
          return const MyRestaurantsScreen();
        } else if (userSnapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text(
                'An error has occurred. Try again later.',
              ),
            ),
          );
        } else if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Text(
              'FATAL ERROR',
              style: TextStyle(color: Colors.red, fontSize: 30),
            ),
          ),
        );
      },
    );
  }
}
