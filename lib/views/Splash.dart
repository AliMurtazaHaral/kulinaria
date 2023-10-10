import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yumnotes/constants/constants.dart';
import 'package:yumnotes/views/PremiumScreen.dart';

import '../models/user_model.dart';
import 'bottomBar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 3),
      () => moveToNextScreen(),
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
            backgroundColor: kAppbarBg,
            body: Center(
              child: Image(
                width: 313,
                height: 156,
                image: AssetImage("assets/logo.png"),
              ),
            ),
          );
        } else if (userSnapshot.hasData) {
          getuserinfo();
          if (loggedInUser.payment == null) {
            FirebaseAuth.instance.signOut();
          }
          return Scaffold(
            backgroundColor: kAppbarBg,
            body: Center(
              child: Image(
                width: 313,
                height: 156,
                image: AssetImage("assets/logo.png"),
              ),
            ),
          );
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

  moveToNextScreen() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BottomNavigationHolder(),
      ),
    );
  }
}
