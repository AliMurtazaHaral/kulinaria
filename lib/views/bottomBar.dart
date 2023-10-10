import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:yumnotes/config/user_state.dart';
import 'package:yumnotes/config/user_state_restaurant.dart';
import 'package:yumnotes/config/user_state_restaurant_fav.dart';
import 'package:yumnotes/constants/constants.dart';
import 'package:yumnotes/views/Favourites.dart';
import 'package:yumnotes/views/Home.dart';
import 'package:yumnotes/views/MyRestaurants.dart';
import 'package:yumnotes/views/Profile.dart';

class BottomNavigationHolder extends StatefulWidget {
   BottomNavigationHolder({super.key,
     this.selectedIndex=0});
  int selectedIndex = 0;
  @override
  State<BottomNavigationHolder> createState() => _BottomNavigationHolderState();
}

class _BottomNavigationHolderState extends State<BottomNavigationHolder> {

  void onItemTapped(int index) {
    setState(() {
      widget.selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = <Widget>[
      HomeScreen(),
      UserStateRestaurant(),
      UserStateRestaurantFav(),
      UserState(),
    ];
    return Scaffold(
      body: Center(
        child: pages.elementAt(widget.selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: true,
        backgroundColor: kAppbarText,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_rounded,
              size: 25,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.restaurant_menu,
              size: 25,
            ),
            label: 'My Restaurants',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite_rounded,
              size: 25,
            ),
            label: 'Favourites',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 25,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: widget.selectedIndex,
        unselectedItemColor: Color(0xff9DA8C3),
        selectedItemColor: kButtonBac,
        selectedIconTheme: IconThemeData(color: kButtonBac),
        onTap: onItemTapped,
      ),
    );
  }
}
