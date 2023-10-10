
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:yumnotes/constants/constants.dart';
import 'package:yumnotes/services/login_services.dart';
import 'package:yumnotes/views/PremiumScreen.dart';
import 'package:yumnotes/widgets/authTextField.dart';
import 'package:yumnotes/widgets/buttonWidget.dart';
import 'package:yumnotes/widgets/premiumBanner.dart';
import 'package:yumnotes/widgets/textWidget.dart';
import 'dart:io';

import '../models/AdHelper.dart';
import '../models/user_model.dart';
import 'ForgetPassword.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _namecontroller = TextEditingController();
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();
  bool plan = false;
  String url = "https://freepngimg.com/thumb/man/22654-6-man-thumb.png";
  File? imageFile;
  XFile? pickedFile;
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  @override
  void initState() {
    super.initState();
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
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      setState(() {
        loggedInUser = UserModel.fromMapRegsitration(value.data());
      });
    });
  }
  BannerAd? _bannerAd;

  // COMPLETE: Add _interstitialAd
  InterstitialAd? _interstitialAd;

  // COMPLETE: Add _rewardedAd
  RewardedAd? _rewardedAd;
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
  final _auth = FirebaseAuth.instance;
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
        FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
        User? user = _auth.currentUser;
        UserModel userModel = UserModel();
        // writing all the values
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${user?.uid}.jpg');
        await ref.putFile(imageFile!);
        url = await ref.getDownloadURL();
        await firebaseFirestore
            .collection("users")
            .doc(user?.uid)
            .update({'imageRef': url});
        //StorageModel storageModel = StorageModel();
        //storageModel.uploadDonorImage(pickedFile?.path, pickedFile?.name);
      });
    }
  }

  bool flag = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppbarBg,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 6.h,
                  ),
                  loggedInUser.imageRef == null
                      ? GestureDetector(
                          onTap: () {
                            _getFromGallery();
                          },
                          child: CircleAvatar(
                            radius: 50.0,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: NetworkImage(
                              url,
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            _getFromGallery();
                          },
                          child: CircleAvatar(
                            radius: 50.0,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: NetworkImage(
                              loggedInUser.imageRef.toString(),
                            ),
                          ),
                        ),
                  SizedBox(
                    height: 2.h,
                  ),
                  TextWidget(
                    text: "${loggedInUser.fullName}",
                    size: 20.sp,
                    color: kAppbarText,
                    weight: FontWeight.w600,
                    align: TextAlign.center,
                  ),
                  TextWidget(
                    text: "${loggedInUser.email}",
                    size: 12.sp,
                    color: kAppbarText,
                    weight: FontWeight.w300,
                    align: TextAlign.center,
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  InkWell(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: TextWidget(
                      text: "LOGOUT",
                      size: 14.sp,
                      color: yellowcol,
                      weight: FontWeight.w600,
                      align: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 1.5.h,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          flag = !flag;
                        });
                      },
                      child: SecondaryButtonWidget(text: "Edit Profile"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          flag == true
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.53,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40)),
                        color: Colors.white,
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              TextWidget(
                                text: "Personal Information",
                                size: 20.sp,
                                color: primaryText,
                                weight: FontWeight.w600,
                                align: TextAlign.center,
                              ),
                              SizedBox(
                                height: 4.h,
                              ),
                              TextWidget(
                                text: "Full Name",
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
                                text: "John Abraham",
                                controller: _namecontroller,
                              ),
                              SizedBox(
                                height: 4.h,
                              ),
                              TextWidget(
                                text: "Email",
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
                                text: "email@gmail.com",
                                controller: _emailcontroller,
                              ),
                              SizedBox(
                                height: 4.h,
                              ),
                              TextWidget(
                                text: "Password",
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
                                text: "Password",
                                controller: _passwordcontroller,
                              ),
                              SizedBox(
                                height: 4.h,
                              ),
                              InkWell(
                                onTap: () async {
                                  await postToFirebaseFirestore();
                                },
                                child: ButtonWidget(text: "Submit"),
                              ),
                              SizedBox(
                                height: 4.h,
                              ),
                              TextWidget(
                                text: "Subscription Details",
                                size: 20.sp,
                                color: primaryText,
                                weight: FontWeight.w600,
                                align: TextAlign.center,
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: PricingCard(
                                      text1: "Lifetime access",
                                      text2: "Normal Price",
                                      price: "24€",
                                      select: false,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5.w,
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PremiumScreen(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: yellowcol,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 2.w, vertical: 2.h),
                                        child: Center(
                                          child: TextWidget(
                                            text: "Change Plan",
                                            color: kAppbarText,
                                            size: 10.0.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox(),
        ],
      ),
    );
  }

  Future<void> postToFirebaseFirestore() async {
    User? user = _auth.currentUser;
    UserModel userModel = UserModel();
    if(_namecontroller.text.isEmpty) {
      _namecontroller.text = loggedInUser.fullName.toString();
    }
    if(_passwordcontroller.text.isEmpty) {
      _passwordcontroller.text = loggedInUser.password.toString();
    }
    else {
      await user?.updatePassword(_passwordcontroller.text);
    }
    if(_emailcontroller.text.isEmpty) {
      _emailcontroller.text = loggedInUser.email.toString();
    }
    else {
      await user
        ?.updateEmail(_emailcontroller.text)
        .then(
          (value) => 'Success',
        )
        .catchError((onError) => 'error');
    }

    await changeFirebase();
    _namecontroller.text = '';
    _emailcontroller.text = '';
    _passwordcontroller.text = '';
    Fluttertoast.showToast(msg: "Your profile has been updated successfully");
  }

  changeFirebase() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    await firebaseFirestore.collection("users").doc(user?.uid).update({
      'fullName': _namecontroller.text,
      'email': _emailcontroller.text,
      'password': _passwordcontroller.text
    });
  }

  // Sign out the user
  void signOutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      print('User signed out successfully.');
    } catch (e) {
      print('Error signing out user: $e');
    }
  }
}
