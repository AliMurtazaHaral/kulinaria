import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class Services{
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  UserModel loginServices() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid).get()
        .then((value) {
      loggedInUser = UserModel.fromMapRegsitration(value.data());

    });
    return loggedInUser;
  }
}