// AIzaSyAG7mcfJmUHPc7tBPAEyRPxa3hfslfdQT4
import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:sizer/sizer.dart';
import 'package:yumnotes/constants/constants.dart';
import 'package:yumnotes/services/login_services.dart';
import 'package:yumnotes/views/CreateAccount.dart';
import 'package:yumnotes/views/ForgetPassword.dart';
import 'package:yumnotes/views/bottomBar.dart';
import 'package:yumnotes/widgets/authTextField.dart';
import 'package:yumnotes/widgets/buttonWidget.dart';
import 'package:yumnotes/widgets/textWidget.dart';

import '../widgets/LoadingOverLay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool createselect = false;
  bool loginselect = true;

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
                height: MediaQuery.of(context).size.height * 0.58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 4.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      createselect = true;
                                      loginselect = false;
                                    });
                                  },
                                  child: TextWidget(
                                      text: "Create Account",
                                      size: 16.0,
                                      weight: FontWeight.w600,
                                      color: createselect == false
                                          ? Color(0xff89909E)
                                          : secondaryText),
                                ),
                                createselect == true
                                    ? Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        child: Divider(
                                          color: secondaryText,
                                          thickness: 2,
                                          height: 20,
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      createselect = false;
                                      loginselect = true;
                                    });
                                  },
                                  child: TextWidget(
                                      text: "Login",
                                      size: 16.0,
                                      weight: FontWeight.w600,
                                      color: loginselect == false
                                          ? Color(0xff89909E)
                                          : secondaryText),
                                ),
                                loginselect == true
                                    ? Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        child: Divider(
                                          color: secondaryText,
                                          thickness: 2,
                                          height: 20,
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      if (loginselect == true) LoginSection(),
                      if (createselect == true) RegisterSection()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LoginSection extends StatefulWidget {
  const LoginSection({super.key});

  @override
  State<LoginSection> createState() => _LoginSectionState();
}

class _LoginSectionState extends State<LoginSection> {
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();

  late LoadingOverlay _loadingOverlay;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              height: 1.h,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgetPasswordScreen(),
                  ),
                );
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: TextWidget(
                  text: "Forget Password",
                  size: 14.sp,
                  weight: FontWeight.w600,
                  color: secondaryText,
                  align: TextAlign.right,
                ),
              ),
            ),
            SizedBox(
              height: 4.h,
            ),
            InkWell(
              onTap: () async {
                await signIn(_emailcontroller.text, _passwordcontroller.text);
              },
              child: ButtonWidget(text: "Login"),
            ),
            SizedBox(
              height: 2.h,
            ),
            InkWell(
              onTap: () {
                signInWithGoogle();
              },
              child: SecondaryButtonWidget(text: "Login with Google"),
            ),
          ],
        ),
      ),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Services service = Services();
  Future<void> signIn(String email, String password) async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((uid) async => {
              Fluttertoast.showToast(msg: "Login Successful"),

              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => BottomNavigationHolder(),
              //   ),
              // ),
            })
        .catchError((e) {
      Fluttertoast.showToast(msg: "Login is not successful");
    });
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:yumnotes/widgets/customAppbar.dart';
// import 'dart:async';
// import 'package:location/location.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   late List<MapType> values = [];
//   late GoogleMapController _controller;
//   Location _locationTracker = Location();
//   static final CameraPosition initialLocation = CameraPosition(
//     target: LatLng(37.42796133580664, -122.08574955962),
//     zoom: 20,
//   );
//   final List<Marker> _markers = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _getLocationPermission();
//   }
//
//   Future<void> _getLocationPermission() async {
//     final hasPermission = await _locationTracker.requestPermission();
//     if (hasPermission == PermissionStatus.granted) {
//       final currentLocation = await _locationTracker.getLocation();
//       _updateCameraPosition(currentLocation);
//     }
//   }
//
//   void _updateCameraPosition(LocationData locationData) {
//     if (_controller != null) {
//       final newCameraPosition = CameraPosition(
//         target: LatLng(locationData.latitude!, locationData.longitude!),
//         zoom: 20,
//       );
//       _controller.moveCamera(CameraUpdate.newCameraPosition(newCameraPosition));
//       _addUserMarker(locationData.latitude!, locationData.longitude!);
//     }
//   }
//
//   void _addUserMarker(double latitude, double longitude) {
//     setState(() {
//       _markers.clear();
//       _markers.add(
//         Marker(
//           markerId: MarkerId('user_marker'),
//           position: LatLng(latitude, longitude),
//           icon: BitmapDescriptor.defaultMarker,
//         ),
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppbar(title: "Select Restaurants", icon: true),
//       body: GoogleMap(
//         mapType: MapType.satellite,
//         markers: Set<Marker>.from(_markers),
//         onMapCreated: (GoogleMapController controller) {
//           _controller = controller;
//         },
//         initialCameraPosition: initialLocation,
//       ),
//     );
//   }
// }
