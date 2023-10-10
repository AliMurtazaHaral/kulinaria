import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yumnotes/views/Login.dart';
import 'package:yumnotes/views/PremiumScreen.dart';
import 'package:yumnotes/views/Profile.dart';
import 'package:yumnotes/views/Splash.dart';
import 'package:yumnotes/views/bottomBar.dart';
import 'package:yumnotes/views/checkScreen.dart';

import '../models/user_model.dart';

class UserState extends StatelessWidget {
  UserState({super.key});
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        if (userSnapshot.data == null) {
          return const LoginScreen();
        } else if (userSnapshot.hasData){
          return const CheckScreen();
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
