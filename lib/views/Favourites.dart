import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sizer/sizer.dart';
import 'package:yumnotes/constants/constants.dart';
import 'package:yumnotes/models/favrestaurant.dart';
import 'package:yumnotes/widgets/customAppbar.dart';
import 'package:yumnotes/widgets/textWidget.dart';

import '../models/AdHelper.dart';
import 'SingleRestaurant.dart';

final _auth = FirebaseAuth.instance;
User? user = _auth.currentUser;

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  User? user = FirebaseAuth.instance.currentUser;
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
      appBar: CustomAppbar(title: "Favourites", icon: true),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
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
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .collection('favRestaurant')
                      .snapshots(),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                    if (streamSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (streamSnapshot.connectionState ==
                        ConnectionState.active) {

                      final product = streamSnapshot.data?.docs;

                      return product?.length != 0
                          ? SingleChildScrollView(
                              child: Column(children: [
                                for (var data in product!)
                                  FutureBuilder<String>(
                                      //future: getImg(data["donorProfileImage"]),
                                      builder: (_, imageSnapshot) {
                                    //final imageUrl = imageSnapshot.data;
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SingleRestaurantScreen(
                                                  openingHours:
                                                  data['Opening Hours'],
                                                  imgUrl: data['imageUrl'],
                                                  website: data['website'],
                                                  phoneNumber: data['phoneNumber'],
                                                  address: data['address'],
                                                  resName: data['resName'],
                                                  uid: data.id,
                                                  docName: 'favRestaurant',
                                                ),
                                          ),
                                        );

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
                                                        data['imageUrl']),
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
                                                      text: data['resName'],
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
                                                        text: data['address'],
                                                        size: 9.sp,
                                                        weight: FontWeight.w400,
                                                        color:
                                                            Color(0xff6B7280),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: InkWell(
                                                  onTap: () async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("users")
                                                        .doc(user!.uid)
                                                        .collection(
                                                            'favRestaurant')
                                                        .doc(data.id)
                                                        .delete();
                                                  },
                                                  child: const Image(
                                                    image: AssetImage(
                                                        "assets/Love.png"),
                                                    width: 45,
                                                    height: 45,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .1,
                                )
                              ]),
                            )
                          : const SizedBox(
                              height: 1000,
                            );

                    } else {
                      return const Center(
                        child: Text(
                          'FATAL ERROR',
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
