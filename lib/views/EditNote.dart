import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../constants/constants.dart';
import '../models/AdHelper.dart';
import '../widgets/authTextField.dart';
import '../widgets/buttonWidget.dart';
import '../widgets/textWidget.dart';

class EditNote extends StatefulWidget {
  EditNote({Key? key,required this.uid,
    required this.docName,required this.uid2,required this.imgUrl,required this.note,required this.title}) : super(key: key);
  String? uid;
  String? uid2;
  String? docName;
  String? imgUrl;
  String? title;
  String? note;
  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
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
      body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: 18,right: 18),
            child: Column(
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
                url==''?
                GestureDetector(
                  onTap:() {
                    _getFromGallery();
                  },
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: NetworkImage(
                      widget.imgUrl.toString(),),
                  ),
                ):CircleAvatar(
                  radius: 50.0,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: NetworkImage(
                    url.toString(),),
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
                      text: widget.title.toString(),
                      controller: _titlecontroller,
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    TextWidget(
                      text: 'Note',
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
                      text: widget.note.toString(),
                      controller: _notecontroller,
                    ),
                  ],
                ),
                SizedBox(
                  height: 4.h,
                ),
                InkWell(
                    onTap: ()async{
                      await postToFirebaseFirestore();
                      Navigator.pop(context);
                    },
                    child: ButtonWidget(text: "Submit"))
              ],
            ),
          )
      ),
    );
  }
  DateTime now = DateTime.now();
  String url='';
  final _auth = FirebaseAuth.instance;
  Future<void> postToFirebaseFirestore()async{
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    DateTime date = DateTime(now.year, now.month, now.day);
    User? user = _auth.currentUser;
    if(_titlecontroller.text=='') {
      _titlecontroller.text = widget.title.toString();
    }
    if(_notecontroller.text=='') {
      _notecontroller.text = widget.note.toString();
    }
    if(url=='') {
      url = widget.imgUrl.toString();
    }
    await firebaseFirestore
        .collection("users")
        .doc(user?.uid).collection(widget.docName.toString())
        .doc(widget.uid).collection('notes').doc(widget.uid2)
        .update(
        {'title': _titlecontroller.text,'imgUrl':url,'note':_notecontroller.text,'date':'${date.day}/${date.month}/${date.year}'}
    );

    Fluttertoast.showToast(msg: "Note has been updated successfully");
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
      setState(() async{
        File file = File(pickedFile!.path);
        imageFile = File('${pickedFile?.path}');
        //final url1 = await storage.ref('DonorProfileImage/$pickedFile?.name').putFile(file);
        //StorageModel storageModel = StorageModel();
        //storageModel.uploadDonorImage(pickedFile?.path, pickedFile?.name);
        final ref = FirebaseStorage.instance
            .ref()
            .child('note_images')
            .child('${imageFile?.path}.jpg');
        await ref.putFile(imageFile!);
        setState(() async{
          url = await ref.getDownloadURL();
        });
      });
    }
  }
}
