import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:sizer/sizer.dart';
import 'package:yumnotes/constants/customWindowInfo.dart';
import 'package:yumnotes/models/favrestaurant.dart';
import 'package:yumnotes/models/myrestaurants.dart';
import '../constants/constants.dart';
import '../constants/searchclass.dart';
import '../widgets/LoadingOverLay.dart';
import '../widgets/textWidget.dart';
import 'SinglePageRes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late GoogleMapController _controller;
  loc.Location _locationTracker = loc.Location();
  loc.LocationData? currentLocation;

  bool color = true;
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(37.42796133580664, -122.0857495596205),
    zoom: 20,
  );
  List<Marker> _markers = [];

  String _selectedType = 'Restaurant';
  String _selectedCuisine = 'Any';
  bool _onlyOpenNow = false;
  String imageIconPath = 'assets/restaurant.png';

  PolylinePoints polylinePoints = PolylinePoints();

  String googleAPiKey = "AIzaSyAG7mcfJmUHPc7tBPAEyRPxa3hfslfdQT4";

  Set<Marker> markers = Set(); //markers for google map
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction

  double distance = 0.0;

  getDirections(
      double userlat, double userlng, double restlat, double restlng) async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(userlat, userlng),
      PointLatLng(restlat, restlng),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }

    //polulineCoordinates is the List of longitute and latidtude.
    double totalDistance = 0;
    for (var i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += calculateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude);
    }
    print(totalDistance);

    setState(() {
      distance = totalDistance;
    });
    addPolyLine(polylineCoordinates);
    //add to the list of poly line coordinates
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: kAppbarBg,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // List<String> _locationTypes = [
  //   'Restaurant',
  //   'Cafe',
  //   'Bar',
  // ];
  // List<String> _cuisineTypes = [
  //   'Any',
  //   'Italian',
  //   'Chinese',
  //   'Mexican',
  //   'Indian',
  //   // Add more cuisines as needed
  // ];

  late LoadingOverlay _loadingOverlay;
  @override
  void initState() {
    super.initState();
    _loadingOverlay = LoadingOverlay(context);
    _getLocationPermission();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -1.0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<Uint8List> getResizedImage(String path) async {
    ByteData byteData = await DefaultAssetBundle.of(context).load(path);

    img.Image? originalImage = img.decodeImage(byteData.buffer.asUint8List());

    int newWidth = 300; // Define the width you want here
    int newHeight =
        (originalImage!.height * newWidth / originalImage.width).round();

    img.Image resizedImage =
        img.copyResize(originalImage, width: newWidth, height: newHeight);

    return img.encodePng(resizedImage);
  }

  Future<void> _getLocationPermission() async {
    final hasPermission = await _locationTracker.requestPermission();
    if (hasPermission == loc.PermissionStatus.granted) {
      currentLocation = await _locationTracker.getLocation();
      _updateCameraPosition(currentLocation!);
    }
  }

  void _updateCameraPosition(loc.LocationData locationData) {
    if (_controller != null) {
      final newCameraPosition = CameraPosition(
        target: LatLng(locationData.latitude!, locationData.longitude!),
        zoom: 20,
      );
      _controller.moveCamera(CameraUpdate.newCameraPosition(newCameraPosition));
      _addUserMarker(locationData.latitude!, locationData.longitude!);
      _getFoodMarkers(currentLocation!.latitude!, currentLocation!.longitude!);
    }
  }

  void _addUserMarker(double latitude, double longitude) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('user_marker'),
          position: LatLng(latitude, longitude),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: "You are here"),
        ),
      );
    });
  }

  Future<void> _getFoodMarkers(double latitude, double longitude) async {
    _loadingOverlay.show();
    _markers = _markers.sublist(0, 1);
    if (_selectedType == 'Restaurant') {
      imageIconPath = 'assets/restaurant.png';
    } else if (_selectedType == 'Cafe') {
      imageIconPath = 'assets/cafe.png';
    } else if (_selectedType == 'Bar') {
      imageIconPath = 'assets/bar.png';
    }
    Uint8List imageData = await getResizedImage(imageIconPath);
    // final BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
    //   ImageConfiguration(
    //       size: Size(20, 20)), // Set the desired size of the marker icon
    //   'assets/restaurant.png', // Replace 'marker_icon.png' with the actual path and name of your image file
    // );
    String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=1500&type=${_selectedType.toLowerCase()}&key=AIzaSyAG7mcfJmUHPc7tBPAEyRPxa3hfslfdQT4';
    if (_onlyOpenNow) {
      url += '&opennow';
    }
    if (_selectedCuisine != 'Any') {
      url += '&keyword=${_selectedCuisine.toLowerCase()}';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final results = data['results'] as List<dynamic>;

      // Prepare a list of Futures for the Place Details requests
      List<Future<http.Response>> detailFutures = [];

      for (final result in results) {
        final placeId = result['place_id'];

        // Send a Place Details request for each place
        String detailUrl =
            'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=AIzaSyAG7mcfJmUHPc7tBPAEyRPxa3hfslfdQT4';

        // Add the Future to the list
        detailFutures.add(http.get(Uri.parse(detailUrl)));
      }

      // Execute all the Futures in parallel
      final detailResponses = await Future.wait(detailFutures);

      for (int i = 0; i < results.length; i++) {
        final result = results[i];
        final detailResponse = detailResponses[i];

        if (detailResponse.statusCode == 200) {
          final geometry = result['geometry']['location'];
          final lat = geometry['lat'];
          final lng = geometry['lng'];
          final name = result['name'];

          final detailData = jsonDecode(detailResponse.body);
          final detailResult = detailData['result'];
          final openingHours = detailResult['opening_hours'] != null
              ? detailResult['opening_hours']['weekday_text']
              : ["No Opening Hours Detail"];
          final phoneNumber = detailResult['formatted_phone_number'] ??
              "Phone number not available";
          final website = detailResult['website'] ?? "Website not available";
          final address =
              detailResult['formatted_address'] ?? "Address not available";
          final photoReference = detailResult['photos'] != null &&
                  detailResult['photos'].length > 0
              ? detailResult['photos'][0]['photo_reference']
              : null;
          final photoUrl = photoReference != null
              ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=AIzaSyAG7mcfJmUHPc7tBPAEyRPxa3hfslfdQT4'
              : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRhlWdTq9fBCD-1CAap_IgiTPntvnBgi3dHnQ&usqp=CAU';
          final marker = Marker(
              markerId: MarkerId(name),
              position: LatLng(lat, lng),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: CustomInfoWindow.CustomPopup(
                        context,
                        heartButtonPressed: () async {
                          await postToFirebaseFirestoreFav(name, address,
                              phoneNumber, website, openingHours, photoUrl);
                          Navigator.pop(context);
                          // Close the dialog
                        },
                        addButtonPressed: () {
                          // Handle button 2 press
                          //const UserState();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SingleRestaurantScreen1(
                                        openingHours: openingHours.toString(),
                                        imgUrl: photoUrl,
                                        website: website,
                                        phoneNumber: phoneNumber,
                                        address: address,
                                        resName: name,
                                      )));

                          //await postToFirebaseFirestore(name, address, phoneNumber, website, openingHours, photoUrl);
                        },
                        onButtonVisitPressed: () async {
                          Navigator.pop(context);
                          _loadingOverlay.show();
                          getDirections(latitude, longitude, lat, lng);
                          await postToFirebaseFirestore(name, address,
                              phoneNumber, website, openingHours, photoUrl);
                          _loadingOverlay.hide();
                        },
                        title: name,
                        distance: openingHours[0] == "No Opening Hours Detail"
                            ? "No Details"
                            : openingHours[_getDayOfWeek() - 1],
                        imageUrl: photoUrl,
                      ),
                    );
                  },
                );
              },
              icon: BitmapDescriptor.fromBytes(imageData));

          _markers.add(marker);
        }
      }

      setState(() {});
    } else {
      print('Failed to load restaurant data');
    }
    _loadingOverlay.hide();
  }

  int _getDayOfWeek() {
    DateTime now = DateTime.now();
    return now.weekday;
  }

  callfunc(String name, String address, String phoneNumber, String website,
      String openingHours, String photoUrl) {}
  final _auth = FirebaseAuth.instance;

  Future<void> postToFirebaseFirestore(
      String name,
      String address,
      String phoneNumber,
      String website,
      List<dynamic> openingHours,
      String imgUrl) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    if (user?.uid == null) {
      final favBox = Hive.box<MyRestaurants>('my');
      bool doesExist =
          favBox.values.any((myRestaurant) => myRestaurant.name == name);

      if (doesExist) {
        Fluttertoast.showToast(
            msg: "Restaurant already added!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        MyRestaurants newRes = MyRestaurants(
            name: name,
            address: address,
            phoneNumber: phoneNumber,
            website: website,
            openingHours: openingHours,
            imgUrl: imgUrl,
            stars: 0,
            notes: []);
        await favBox.add(newRes);
        Fluttertoast.showToast(
            msg: "Restaurant has been added successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      final DocumentReference docRef = firebaseFirestore
          .collection("users")
          .doc(user?.uid)
          .collection("myRestaurant")
          .doc(name); // using 'name' as the document id

      docRef.get().then((doc) {
        if (doc.exists) {
          Fluttertoast.showToast(
              msg: "Restaurant already added!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          docRef.set({
            'star': 0.0,
            'resName': name,
            'address': address,
            'phoneNumber': phoneNumber,
            'website': website,
            'Opening Hours': openingHours,
            'imageUrl': imgUrl
          });

          Fluttertoast.showToast(
              msg: "Restaurant has been added successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      });
    }
  }

  Future<void> postToFirebaseFirestoreFav(
      String name,
      String address,
      String phoneNumber,
      String website,
      List<dynamic> openingHours,
      String imgUrl) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    if (user?.uid == null) {
      final favBox = Hive.box<FavRestaurants>('fav');
      bool doesExist =
          favBox.values.any((favRestaurant) => favRestaurant.name == name);

      if (doesExist) {
        Fluttertoast.showToast(
            msg: "Restaurant already added!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        FavRestaurants newFav = FavRestaurants(
            name: name,
            address: address,
            phoneNumber: phoneNumber,
            website: website,
            openingHours: openingHours,
            imgUrl: imgUrl,
            stars: 0,
            notes: []);
        await favBox.add(newFav);
        Fluttertoast.showToast(
            msg: "Restaurant has been added to favourite category successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      final DocumentReference docRef = firebaseFirestore
          .collection("users")
          .doc(user?.uid)
          .collection("favRestaurant")
          .doc(name); // using 'name' as the document id

      docRef.get().then((doc) {
        if (doc.exists) {
          Fluttertoast.showToast(
              msg: "Restaurant already added!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          docRef.set({
            'star': 0.0,
            'resName': name,
            'address': address,
            'phoneNumber': phoneNumber,
            'website': website,
            'Opening Hours': openingHours,
            'imageUrl': imgUrl
          });

          Fluttertoast.showToast(
              msg:
                  "Restaurant has been added to favourite category successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      });
    }
  }

  void _toggleAnimation() {
    if (_animationController.status == AnimationStatus.completed) {
      _animationController.reverse();
      color = true;
      setState(() {});
    } else {
      _animationController.forward();
      color = false;
      setState(() {});
    }
  }

  TextEditingController textController = TextEditingController();
  bool icon = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image(
          image: AssetImage("assets/icon.png"),
        ),
        title: TextWidget(
          text: "Kulinaria",
          size: 18.sp,
          weight: FontWeight.w600,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () async {
              final selectedMarker = await showSearch(
                context: context,
                delegate: PlacesSearch(_markers),
              );

              if (selectedMarker != null) {
                LatLng markerLatLng = selectedMarker.position;
                getDirections(
                  currentLocation!.latitude!,
                  currentLocation!.longitude!,
                  markerLatLng.latitude,
                  markerLatLng.longitude,
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.terrain,
            initialCameraPosition: initialLocation,
            markers: Set<Marker>.of(_markers),
            polylines: Set<Polyline>.of(polylines.values),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
          ),
          IntrinsicHeight(
            child: Container(
              color: color
                  ? Color(0xffFBBD00)
                  : Colors.transparent, // Set the background color
              child: SlideTransition(
                position: _offsetAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text("Location"),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Row(
                        children: [
                          buildContainer('Restaurant'),
                          SizedBox(
                            width: 15,
                          ),
                          buildContainer('Cafe'),
                          SizedBox(
                            width: 15,
                          ),
                          buildContainer('Bar'),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text("Food"),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Row(
                          children: [
                            buildFoodContainer('Any'),
                            SizedBox(
                              width: 15,
                            ),
                            buildFoodContainer('Italian'),
                            SizedBox(
                              width: 15,
                            ),
                            buildFoodContainer('Chinese'),
                            SizedBox(
                              width: 15,
                            ),
                            buildFoodContainer('Mexican'),
                            SizedBox(
                              width: 15,
                            ),
                            buildFoodContainer('Indian'),
                          ],
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: EdgeInsets.only(left: 20.0),
                    //   child: Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: DropdownButton<String>(
                    //       value: _selectedCuisine,
                    //       onChanged: (String? newValue) {
                    //         setState(() {
                    //           _selectedCuisine = newValue!;
                    //           _getFoodMarkers(currentLocation!.latitude!,
                    //               currentLocation!.longitude!);
                    //         });
                    //       },
                    //       items: _cuisineTypes
                    //           .map<DropdownMenuItem<String>>((String value) {
                    //         return DropdownMenuItem<String>(
                    //           value: value,
                    //           child: Text(value),
                    //         );
                    //       }).toList(),
                    //     ),
                    //   ),
                    // ),
                    CheckboxListTile(
                      title: Text('Show only open locations'),
                      value: _onlyOpenNow,
                      onChanged: (bool? value) {
                        setState(() {
                          _onlyOpenNow = value!;
                          _getFoodMarkers(currentLocation!.latitude!,
                              currentLocation!.longitude!);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Row(
              children: [
                FloatingActionButton(
                  child: Icon(
                    Icons.location_searching,
                    color: Colors.white,
                  ),
                  backgroundColor: kButtonBac,
                  heroTag: 1,
                  onPressed: () async {
                    currentLocation = await _locationTracker.getLocation();
                    _updateCameraPosition(currentLocation!);
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                FloatingActionButton(
                  backgroundColor: kButtonBac,
                  heroTag: 2,
                  child: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    color: Colors.white,
                    progress: _animationController,
                  ),
                  onPressed: _toggleAnimation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContainer(String type) {
    return GestureDetector(
      onTap: () {
        _handleContainerTap(type);
      },
      child: Container(
        width: 120,
        height: 40,
        decoration: BoxDecoration(
            color: _selectedType == type ? Colors.white : Colors.white,
            borderRadius: BorderRadius.circular(100)),
        child: Center(
          child: Container(
              width: 105,
              height: 32,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                      color: _selectedType == type
                          ? Color(0xffFBBD00)
                          : Colors.white,
                      width: 2)),
              child: Center(child: Text(type))),
        ),
      ),
    );
  }

  void _handleContainerTap(String type) {
    setState(() {
      _selectedType = type;
    });

    // Perform specific operations based on the selected value
    switch (_selectedType) {
      case 'Restaurant':
        _getFoodMarkers(
            currentLocation!.latitude!, currentLocation!.longitude!);
        break;
      case 'Cafe':
        _getFoodMarkers(
            currentLocation!.latitude!, currentLocation!.longitude!);
        break;
      case 'Bar':
        _getFoodMarkers(
          currentLocation!.latitude!,
          currentLocation!.longitude!,
        );
        break;
      default:
        break;
    }
  }

  Widget buildFoodContainer(String type) {
    return GestureDetector(
      onTap: () {
        _handleFoodContainerTap(type);
      },
      child: Container(
        width: 120,
        height: 40,
        decoration: BoxDecoration(
            color: _selectedCuisine == type ? Colors.white : Colors.white,
            borderRadius: BorderRadius.circular(100)),
        child: Center(
          child: Container(
              width: 105,
              height: 32,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                      color: _selectedCuisine == type
                          ? Color(0xffFBBD00)
                          : Colors.white,
                      width: 2)),
              child: Center(child: Text(type))),
        ),
      ),
    );
  }

  void _handleFoodContainerTap(String type) {
    setState(() {
      _selectedCuisine = type;
    });
    // 'Any',
    // 'Italian',
    // 'Chinese',
    // 'Mexican',
    // 'Indian',
    // Perform specific operations based on the selected value
    switch (_selectedCuisine) {
      case 'Any':
        _getFoodMarkers(
            currentLocation!.latitude!, currentLocation!.longitude!);
        break;
      case 'Italian':
        _getFoodMarkers(
            currentLocation!.latitude!, currentLocation!.longitude!);
        break;
      case 'Chinese':
        _getFoodMarkers(
          currentLocation!.latitude!,
          currentLocation!.longitude!,
        );
        break;
      case 'Mexican':
        _getFoodMarkers(
          currentLocation!.latitude!,
          currentLocation!.longitude!,
        );
        break;
      case 'Indian':
        _getFoodMarkers(
          currentLocation!.latitude!,
          currentLocation!.longitude!,
        );
        break;
      default:
        break;
    }
  }
}
