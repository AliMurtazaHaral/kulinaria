import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yumnotes/constants/constants.dart';
import 'package:yumnotes/views/AddNote.dart';
import 'package:yumnotes/views/DeleteSuccess.dart';
import 'package:yumnotes/views/EditNote.dart';
import 'package:yumnotes/views/EditSuccess.dart';
import 'package:yumnotes/widgets/customAppbar.dart';
import 'package:yumnotes/widgets/textWidget.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:yumnotes/constants/constants.dart';

import '../models/AdHelper.dart';

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

class SingleRestaurantScreen extends StatefulWidget {
  SingleRestaurantScreen(
      {super.key,
      required this.openingHours,
      required this.imgUrl,
      required this.website,
      required this.phoneNumber,
      required this.address,
      required this.resName,
      required this.uid,
      required this.docName});
  String? resName;
  String? address;
  String? imgUrl;
  String? phoneNumber;
  String? website;
  List<dynamic> openingHours;
  String? uid;
  String? docName;
  @override
  State<SingleRestaurantScreen> createState() => _SingleRestaurantScreenState();
}

class _SingleRestaurantScreenState extends State<SingleRestaurantScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  BannerAd? _bannerAd;

  // COMPLETE: Add _interstitialAd
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  Map<String, dynamic>? paymentIntent;
  // COMPLETE: Add _rewardedAd

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
  bool _customTileExpanded = false;

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
              if (FirebaseAuth.instance.currentUser == null)
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
                                      builder: (context) => AddNoteScreen(
                                        uid: widget.uid,
                                        address: widget.address,
                                        openingHours: widget.openingHours,
                                        imgUrl: widget.imgUrl,
                                        resName: widget.resName,
                                        phoneNumber: widget.phoneNumber,
                                        docName: widget.docName,
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
                                      // weight: FontWeight.w600,
                                      align: TextAlign.left,
                                      color: primaryText,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextWidget(
                                      text: widget.openingHours[1],
                                      size: 12.sp,
                                      // weight: FontWeight.w600,
                                      align: TextAlign.left,
                                      color: primaryText,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextWidget(
                                      text: widget.openingHours[2],
                                      size: 12.sp,
                                      // weight: FontWeight.w600,
                                      align: TextAlign.left,
                                      color: primaryText,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextWidget(
                                      text: widget.openingHours[3],
                                      size: 12.sp,
                                      // weight: FontWeight.w600,
                                      align: TextAlign.left,
                                      color: primaryText,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextWidget(
                                      text: widget.openingHours[4],
                                      size: 12.sp,
                                      // weight: FontWeight.w600,
                                      align: TextAlign.left,
                                      color: primaryText,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextWidget(
                                      text: widget.openingHours[5],
                                      size: 12.sp,
                                      // weight: FontWeight.w600,
                                      align: TextAlign.left,
                                      color: primaryText,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextWidget(
                                      text: widget.openingHours[6],
                                      size: 12.sp,
                                      // weight: FontWeight.w600,
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
                              // weight: FontWeight.w600,
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
              TextWidget(
                text: "Notes",
                size: 18.sp,
                color: primaryText,
                weight: FontWeight.w600,
                align: TextAlign.left,
              ),
              SizedBox(
                height: 2.h,
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .collection(widget.docName.toString())
                    .doc(widget.uid)
                    .collection('notes')
                    .snapshots(),
                builder:
                    (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                  final product = streamSnapshot.data?.docs;
                  return product?.length != 0
                      ? SingleChildScrollView(
                          child: Column(children: [
                            for (var data in product!)
                              FutureBuilder<String>(
                                  //future: getImg(data["donorProfileImage"]),
                                  builder: (_, imageSnapshot) {
                                //final imageUrl = imageSnapshot.data;
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
                                          child: Image(
                                            image: NetworkImage(
                                                data['imgUrl'].toString()),
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
                                                text: data['date'].toString(),
                                                size: 10.sp,
                                                color: Color(0xff6B7280),
                                                weight: FontWeight.w400,
                                                align: TextAlign.left,
                                              ),
                                              TextWidget(
                                                text: data['note'],
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
                                                                    EditNote(
                                                              uid: widget.uid,
                                                              docName: widget
                                                                  .docName,
                                                              imgUrl: data[
                                                                  'imgUrl'],
                                                              uid2: data.id,
                                                              note:
                                                                  data['note'],
                                                              title:
                                                                  data['title'],
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
                                                      onPressed: () async {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection("users")
                                                            .doc(user!.uid)
                                                            .collection(widget
                                                                .docName
                                                                .toString())
                                                            .doc(widget.uid)
                                                            .collection('notes')
                                                            .doc(data.id)
                                                            .delete();
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
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .05,
                            )
                          ]),
                        )
                      : const SizedBox(
                          height: 10,
                        );
                },
              ),
              SizedBox(
                height: 6.h,
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
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .collection(widget.docName.toString())
                    .snapshots(),
                builder:
                    (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                  List<Widget> Data = [];
                  var image_2;
                  final product = streamSnapshot.data?.docs;
                  return product?.length != 0
                      ? SingleChildScrollView(
                          child: Column(children: [
                            for (var data in product!)
                              FutureBuilder<String>(
                                  //future: getImg(data["donorProfileImage"]),
                                  builder: (_, imageSnapshot) {
                                //final imageUrl = imageSnapshot.data;
                                return data.id == widget.uid
                                    ? Card(
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
                                              Center(
                                                child: RatingBar.builder(
                                                  initialRating: double.parse(
                                                      '${data['star']}'),
                                                  minRating: double.parse(
                                                      '${data['star']}'),
                                                  direction: Axis.horizontal,
                                                  allowHalfRating: false,
                                                  itemCount: 5,
                                                  itemPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 0.0),
                                                  itemBuilder: (context, _) =>
                                                      Icon(
                                                    Icons.star,
                                                    size: 5,
                                                    color: Colors.amber,
                                                  ),
                                                  updateOnDrag: false,
                                                  onRatingUpdate:
                                                      (value) async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("users")
                                                        .doc(user?.uid)
                                                        .collection(widget
                                                            .docName
                                                            .toString())
                                                        .doc(widget.uid)
                                                        .update(
                                                            {'star': value});
                                                  },
                                                ),
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
                                                    onPressed: () async {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection("users")
                                                          .doc(user?.uid)
                                                          .collection(widget
                                                              .docName
                                                              .toString())
                                                          .doc(widget.uid)
                                                          .update(
                                                              {'star': 0.0});
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
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        height: 0,
                                      );
                              }),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .05,
                            )
                          ]),
                        )
                      : const SizedBox(
                          height: 10,
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
