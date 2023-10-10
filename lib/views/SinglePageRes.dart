import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/constants.dart';
import '../models/AdHelper.dart';
import '../widgets/customAppbar.dart';
import '../widgets/textWidget.dart';
import 'SingleRestaurant.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class BarChartModel {
  String year;
  int financial;
  final charts.Color color;

  BarChartModel({
    required this.year,
    required this.financial,
    required this.color,
  });
}

class SingleRestaurantScreen1 extends StatefulWidget {
  SingleRestaurantScreen1({
    super.key,
    required this.openingHours,
    required this.imgUrl,
    required this.website,
    required this.phoneNumber,
    required this.address,
    required this.resName,
  });
  String? resName;
  String? address;
  String? imgUrl;
  String? phoneNumber;
  String? website;
  String? openingHours;
  @override
  State<SingleRestaurantScreen1> createState() =>
      _SingleRestaurantScreen1State();
}

class _SingleRestaurantScreen1State extends State<SingleRestaurantScreen1> {
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
  final List<BarChartModel> data = [
    BarChartModel(
      year: "Monday",
      financial: 450,
      color: charts.ColorUtil.fromDartColor(Color(0xffC45911)),
    ),
    BarChartModel(
      year: "Tuesday",
      financial: 630,
      color: charts.ColorUtil.fromDartColor(Color(0xffC45911)),
    ),
    BarChartModel(
      year: "Wednesday",
      financial: 950,
      color: charts.ColorUtil.fromDartColor(Color(0xffC45911)),
    ),
    BarChartModel(
      year: "Thursday",
      financial: 400,
      color: charts.ColorUtil.fromDartColor(Color(0xffC45911)),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    List<charts.Series<BarChartModel, String>> series = [
      charts.Series(
        id: "financial",
        data: data,
        domainFn: (BarChartModel series, _) => series.year,
        measureFn: (BarChartModel series, _) => series.financial,
        colorFn: (BarChartModel series, _) => series.color,
      ),
    ];
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
                      ],
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
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.timer_rounded,
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
                            text: "Opening Hours",
                            size: 12.sp,
                            weight: FontWeight.bold,
                            align: TextAlign.left,
                            color: primaryText),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 0.5.h,
                  ),
                  TextWidget(
                    text: widget.openingHours.toString(),
                    size: 12.sp,
                    // weight: FontWeight.w600,
                    color: primaryText,
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
              Container(
                width: MediaQuery.of(context).size.width * 1,
                height: 300,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                child: charts.BarChart(
                  series,
                  animate: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
