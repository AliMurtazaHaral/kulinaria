import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sizer/sizer.dart';
import 'package:yumnotes/constants/constants.dart';
import 'package:yumnotes/views/EmailVerification.dart';
import 'package:yumnotes/widgets/authTextField.dart';
import 'package:yumnotes/widgets/buttonWidget.dart';
import 'package:yumnotes/widgets/textWidget.dart';

import '../models/user_model.dart';
import '../widgets/LoadingOverLay.dart';
import 'Login.dart';

class RegisterSection extends StatefulWidget {
  const RegisterSection({super.key});

  @override
  State<RegisterSection> createState() => _RegisterSectionState();
}

class _RegisterSectionState extends State<RegisterSection> {
  TextEditingController _namecontroller = TextEditingController();
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();

  late LoadingOverlay _loadingOverlay;
  @override
  void initState() {
    super.initState();
    _loadingOverlay = LoadingOverlay(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                text: "Enter your full name",
                controller: _namecontroller,
              ),
              SizedBox(
                height: 2.h,
              ),
              TextWidget(
                text: "Email address",
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
                text: "Eg namaemail@emailkamu.com",
                controller: _emailcontroller,
              ),
              SizedBox(
                height: 2.h,
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
                obsecureText: true,
                text: "Enter your password",
                controller: _passwordcontroller,
              ),
              SizedBox(
                height: 4.h,
              ),
              InkWell(
                onTap: () async {
                  await signUp(_emailcontroller.text, _passwordcontroller.text);
                  if (FirebaseAuth.instance.currentUser != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const EmailVerificationScreen()));
                  }
                },
                child: ButtonWidget(text: "Registration"),
              ),
              SizedBox(
                height: 2.h,
              ),
              InkWell(
                onTap: () async{
                  await signInWithGoogle();
                },
                child: SecondaryButtonWidget(text: "Login with Google"),
              ),
            ],
          ),
        ),
      ),
    );
  }
  signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: <String>["email"]).signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
  final _auth = FirebaseAuth.instance;

  Future<void> postToFirebaseFirestore() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    UserModel userModel = UserModel();

    // writing all the values
    userModel.email = _emailcontroller.text;
    userModel.password = _passwordcontroller.text;
    userModel.fullName = _namecontroller.text;

    // Check if the user's email is verified
    if (user?.emailVerified == true) {
      await firebaseFirestore
          .collection("users")
          .doc(user?.uid)
          .set(userModel.toBecomeRegistration());
      Fluttertoast.showToast(msg: "Your account has been created successfully");
    } else {
      Fluttertoast.showToast(msg: "Please verify your email to proceed.");
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        // Send verification email
        await user.sendEmailVerification();
        Fluttertoast.showToast(
            msg:
            "A verification email has been sent to ${user.email}. Please check your email inbox.");
        await postToFirebaseFirestore();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
