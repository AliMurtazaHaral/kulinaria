import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sizer/sizer.dart';
import 'package:yumnotes/constants/constants.dart';
import 'package:yumnotes/payments/stripe_payment.dart';
import 'package:yumnotes/views/Login.dart';
import 'package:yumnotes/widgets/buttonWidget.dart';
import 'package:yumnotes/widgets/textWidget.dart';

import '../config/user_state.dart';
import '../models/AdHelper.dart';
import 'package:http/http.dart' as http;

import 'bottomBar.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool monthlySelected = true;
  bool yearlySelected = false;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Image.asset("assets/mainimg.png"),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 5.h, 4.w, 5.h),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: "Buy Premium Package",
                          size: 15.sp,
                          weight: FontWeight.w600,
                          color: secondaryText,
                          align: TextAlign.left,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: Divider(
                            color: secondaryText,
                            thickness: 2,
                            height: 20,
                          ),
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async{
                                  setState(() {
                                    monthlySelected = true;
                                    yearlySelected = false;
                                  });
                                },
                                child: PricingCard(
                                  text1: "Monthly",
                                  text2: "Normal Price",
                                  price: "0,99€",
                                  select: monthlySelected,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 1.w,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () async{
                                  setState(() {
                                    monthlySelected = false;
                                    yearlySelected = true;

                                  });

                                },
                                child: PricingCard(
                                    select: yearlySelected,
                                    text1: "Lifetime access",
                                    text2: "Normal Price",
                                    price: "24€"),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        TextWidget(
                          text: "Premium Features",
                          size: 16.sp,
                          weight: FontWeight.w600,
                          color: secondaryText,
                          align: TextAlign.left,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: Divider(
                            color: secondaryText,
                            thickness: 2,
                            height: 20,
                          ),
                        ),
                        Features(
                          text: "No more ads",
                        ),
                        Features(
                          text:
                              "Family access so that they can use the same account on several devices and everyone has access to the notes",
                        ),
                        Features(
                          text:
                              "Saved information because the notes are saved on the account and if the user's device gets broken he can simply log in on the new device and still has all of his data",
                        ),
                        Features(
                          text: "Notes without limitations",
                        ),
                        Features(
                          text:
                              "The restaurants stats of how much people are visiting a restaurant at a specific time and day",
                        ),
                        SizedBox(height: 3.h),
                        SecondaryButtonWidget(
                            onTap: (){
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>BottomNavigationHolder()));
                            },
                            text: "Maybe later"),
                        SizedBox(height: 2.h),
                        InkWell(
                          onTap: () async{
                            if (monthlySelected == true){
                              await makePayment('1');
                            }
                             else  {
                              await makePayment('24');
                            }

                          },
                          child:
                              ButtonWidget(text: "Get Lifetime Premium Access"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Future<void> makePayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'Eur');
      //Payment Sheet
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent!['client_secret'],
              // applePay: const PaymentSheetApplePay(merchantCountryCode: '+92',),
              // googlePay: const PaymentSheetGooglePay(testEnv: true, currencyCode: "US", merchantCountryCode: "+92"),
              style: ThemeMode.dark,
              merchantDisplayName: 'Yum Notes')).then((value){
      });


      ///now finally display payment sheeet
      displayPaymentSheet(amount);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet(String amount) async {

    try {
      await Stripe.instance.presentPaymentSheet(
      ).then((value) async{
        showDialog(
            context: context,
            builder: (_) => const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green,),
                      Text("Payment Successfull"),
                    ],
                  ),
                ],
              ),
            ));
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("paid successfully")));

        paymentIntent = null;
        final _auth = FirebaseAuth.instance;
        FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
        User? user = _auth.currentUser;


        // writing all the values
        await firebaseFirestore
            .collection("users")
            .doc(user?.uid)
            .update({
          'payment':amount
        });
        Fluttertoast.showToast(msg: "Payment Done");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavigationHolder(),
          ),
        );
        //Navigator.push(context, MaterialPageRoute(builder: (context) => UserState(),),);
        //_loadInterstitialAd();

      }).onError((error, stackTrace){
        print('Error is:--->$error $stackTrace');
      });


    } on StripeException catch (e) {
      print('Error is:---> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            content: Text("Cancelled "),
          ));
    } catch (e) {
      print('$e');
    }
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserState(),),);
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
  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer sk_test_51LfUARDwLhA5VoPRDxnbj9uoqfXrzLF3LNB8SruISPK7mObpnWmyDa1bUDU4sueko30iSfIB3Tgu99QMngsmsEZd00PLOBUklC',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      // ignore: avoid_print
      print('Payment Intent Body->>> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      // ignore: avoid_print
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100 ;
    return calculatedAmout.toString();
  }
}

class PricingCard extends StatelessWidget {
  PricingCard(
      {required this.text1,
      required this.text2,
      required this.price,
      required this.select});

  final text1;
  final text2;
  final price;
  bool select;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Color(0xffFFF8F3),
          borderRadius: BorderRadius.circular(20),
          border: select == true
              ? Border.all(color: Color(0xffC45911), width: 1.5)
              : Border.all(color: Color(0xffFFF8F3), width: 1.5)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 4.h),
        child: Column(
          children: [
            TextWidget(
              text: text1,
              size: 13.sp,
              weight: FontWeight.w600,
              color: secondaryText,
              align: TextAlign.left,
            ),
            SizedBox(
              height: 1.5.h,
            ),
            TextWidget(
              text: price,
              size: 23.sp,
              weight: FontWeight.w600,
              color: secondaryText,
              align: TextAlign.left,
            ),
            SizedBox(
              height: 1.5.h,
            ),
            TextWidget(
              text: text2,
              size: 11.sp,
              weight: FontWeight.w500,
              color: secondaryText,
              align: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}

class Features extends StatelessWidget {
  const Features({required this.text});

  final text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      horizontalTitleGap: 0,
      leading: Icon(Icons.check_circle, color: yellowcol),
      title: TextWidget(
        text: text,
        size: 11.sp,
        weight: FontWeight.w600,
        color: secondaryText,
      ),
    );
  }
}
