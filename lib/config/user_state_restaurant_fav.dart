import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sizer/sizer.dart';
import 'package:yumnotes/models/favrestaurant.dart';
import 'package:yumnotes/views/Favourites.dart';
import 'package:yumnotes/views/Login.dart';
import 'package:yumnotes/views/Profile.dart';
import 'package:yumnotes/views/SingleRestaurantHiveScreen.dart';
import 'package:yumnotes/views/Splash.dart';
import 'package:yumnotes/views/bottomBar.dart';
import 'package:hive_flutter/adapters.dart';

import '../constants/constants.dart';
import '../models/AdHelper.dart';
import '../models/user_model.dart';
import '../views/MyRestaurants.dart';
import '../views/PremiumScreen.dart';
import '../views/SingleRestaurant.dart';
import '../widgets/customAppbar.dart';
import '../widgets/textWidget.dart';

final _auth = FirebaseAuth.instance;
User? user = _auth.currentUser;
final box = Hive.box<FavRestaurants>('fav');

class UserStateRestaurantFav extends StatefulWidget {
  const UserStateRestaurantFav({Key? key}) : super(key: key);

  @override
  State<UserStateRestaurantFav> createState() => _UserStateRestaurantFavState();
}

class _UserStateRestaurantFavState extends State<UserStateRestaurantFav> {
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
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        if (userSnapshot.data == null) {
          return Scaffold(
            appBar: CustomAppbar(title: "Favourites", icon: true),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: "Favorite Restaurants",
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
                    builder: (context, Box<FavRestaurants> box, _) {
                      if (box.values.isEmpty) {
                        return const Center(
                          child: Text("No Favourites"),
                        );
                      } else {
                        return Flexible(
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: box.values.length,
                              itemBuilder: (context, index) {
                                final restaurant = box.getAt(index);
                                return GestureDetector(
                                  onTap: () {
                                    if (_interstitialAd != null) {
                                      _interstitialAd?.show();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SingleRestaurantHiveScreen(
                                                openingHours: restaurant.openingHours,
                                                imgUrl: restaurant.imgUrl,
                                                website: restaurant.website,
                                                phoneNumber: restaurant.phoneNumber,
                                                address: restaurant.address,
                                                resName: restaurant.name,
                                                index: index,
                                              ),
                                        ),
                                      );
                                    } else {

                                    }

                                  },
                                  child: Card(
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
                                                  text: restaurant!.name,
                                                  size: 13.sp,
                                                  color: primaryText,
                                                  weight: FontWeight.w600,
                                                  align: TextAlign.left,
                                                ),
                                                ListTile(
                                                  contentPadding:
                                                  EdgeInsets.zero,
                                                  visualDensity:
                                                  VisualDensity.compact,
                                                  horizontalTitleGap: 0,
                                                  leading: Icon(
                                                    Icons.location_on,
                                                    color: yellowcol,
                                                    size: 20.sp,
                                                  ),
                                                  title: TextWidget(
                                                    text: restaurant!.address,
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
                                                if (box.isOpen &&
                                                    index < box.length) {
                                                  await box.deleteAt(index);
                                                } else {
                                                  print(
                                                      'Failed to delete item at index $index');
                                                }
                                              },
                                              child: const Image(
                                                image: AssetImage(
                                                    "assets/Love.png"),
                                                width: 60,
                                                height: 60,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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
        }
        else if (userSnapshot.hasData) {
          if (loggedInUser.payment == null) {
            FirebaseAuth.instance.signOut();
          }
          return const FavouritesScreen();
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

// ValueListenableBuilder(
// valueListenable:
// Hive.box<FavRestaurants>('fav').listenable(),
// builder: (context, Box<FavRestaurants> box, _) {
// if (box.values.isEmpty) {
// const Center(
// child: Text(
// 'No Favourites',
// ),
// );
// }
// return ListView.builder(
// itemCount: box.values.length,
// itemBuilder: (context, index) {
// FavRestaurants? restaurant = box.getAt(index);
// return GestureDetector(
// onTap: () {},
// child: Card(
// child: Padding(
// padding: EdgeInsets.symmetric(
// horizontal: 3.w, vertical: 3.w),
// child: Row(
// mainAxisAlignment:
// MainAxisAlignment.spaceBetween,
// children: [
// Expanded(
// flex: 1,
// child: Image(
// image: NetworkImage(
// restaurant!.imgUrl),
// ),
// ),
// SizedBox(
// width: 4.w,
// ),
// Expanded(
// flex: 3,
// child: Column(
// crossAxisAlignment:
// CrossAxisAlignment.start,
// children: [
// TextWidget(
// text: restaurant!.name,
// size: 13.sp,
// color: primaryText,
// weight: FontWeight.w600,
// align: TextAlign.left,
// ),
// ListTile(
// contentPadding:
// EdgeInsets.zero,
// visualDensity:
// VisualDensity.compact,
// horizontalTitleGap: 0,
// leading: Icon(
// Icons.location_on,
// color: Colors.green,
// size: 20.sp,
// ),
// title: TextWidget(
// text: restaurant!.address,
// size: 9.sp,
// weight: FontWeight.w400,
// color: Color(0xff6B7280),
// ),
// ),
// ],
// ),
// ),
// Expanded(
// flex: 1,
// child: InkWell(
// onTap: () async {},
// child: const Image(
// image: AssetImage(
// "assets/Love.png"),
// width: 60,
// height: 60,
// ),
// ),
// ),
// ],
// ),
// ),
// ),
// );
// });
// })
