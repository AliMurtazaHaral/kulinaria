import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:yumnotes/views/PremiumScreen.dart';
import 'package:yumnotes/views/Profile.dart';

import '../models/user_model.dart';

class CheckScreen extends StatefulWidget {
  const CheckScreen({Key? key}) : super(key: key);

  @override
  State<CheckScreen> createState() => _CheckScreenState();
}

class _CheckScreenState extends State<CheckScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  @override
  void initState() {
    super.initState();
    getuserinfo();
  }
  getuserinfo() async{
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      setState(() {
        loggedInUser = UserModel.fromMapRegsitration(value.data());
      });
    });
  }
  @override
  Widget build(BuildContext context) {
   return (loggedInUser.payment==null) ? const PremiumScreen():const ProfileScreen();
  }
}
