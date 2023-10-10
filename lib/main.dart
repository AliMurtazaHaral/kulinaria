import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:yumnotes/constants/constants.dart';
import 'package:yumnotes/models/favrestaurant.dart';
import 'package:yumnotes/models/myrestaurants.dart';
import 'package:yumnotes/models/notesModel.dart';
import 'package:yumnotes/views/Splash.dart';
import 'package:sizer/sizer.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = "pk_test_51LfUARDwLhA5VoPRkSD2obwEXXsBH6qht4jukSTQMHQDsijrGktCbqawl9UjJPLLapGOcyQrw34kBkmfP9S6fOlm00H3rvSlUO";
  //Stripe.publishableKey = "pk_test_51NM23YFgdGXctD0RpJsM1AMkd5LyYxeOEIfexWKBM9E3DVeyDspqGubhmmwUCaNHz1tSxHEPPzq66QifJt3GLnar006hLx28aD";
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(FavRestaurantsAdapter());
  Hive.registerAdapter(MyRestaurantsAdapter());
  Hive.registerAdapter(NotesAdapter());
  await Future.wait(
      [Hive.openBox<MyRestaurants>('my'), Hive.openBox<FavRestaurants>('fav')]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        title: 'Kulinaria',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: kScaffoldBg,
          appBarTheme: AppBarTheme(backgroundColor: kAppbarBg),
          primarySwatch: MaterialColor(
            0xffFBBD00,
            <int, Color>{
              50: Color(0xfffff3e0),
              100: Color(0xffffe0b2),
              200: Color(0xffffcc80),
              300: Color(0xffffb74d),
              400: Color(0xffffa726),
              500: Color(0xffFBBD00), // The main color value
              600: Color(0xfff9a825),
              700: Color(0xfff57f17),
              800: Color(0xfff57f17),
              900: Color(0xfff57f17),
            },
          ),
        ),
        home: const SplashScreen(),
      );
    });
  }
}
