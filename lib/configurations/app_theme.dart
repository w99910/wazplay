import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Map<int, Color> color = {
  50: const Color.fromRGBO(136, 14, 79, .1),
  100: const Color.fromRGBO(136, 14, 79, .2),
  200: const Color.fromRGBO(136, 14, 79, .3),
  300: const Color.fromRGBO(136, 14, 79, .4),
  400: const Color.fromRGBO(136, 14, 79, .5),
  500: const Color.fromRGBO(136, 14, 79, .6),
  600: const Color.fromRGBO(136, 14, 79, .7),
  700: const Color.fromRGBO(136, 14, 79, .8),
  800: const Color.fromRGBO(136, 14, 79, .9),
  900: const Color.fromRGBO(136, 14, 79, 1),
};

class AppTheme {
  static ThemeData lightTheme = ThemeData(
      fontFamily: 'Poppins',
      primaryColor: Colors.black,
      primaryColorDark: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      sliderTheme: SliderThemeData(
        thumbColor: Colors.black,
        activeTrackColor: Colors.black,
        inactiveTrackColor: Colors.grey[200],
      ),
      textTheme: const TextTheme(
          subtitle1: TextStyle(
              fontWeight: FontWeight.w400), // Default style for TextField
          headline1: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 28),
          headline2: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 26),
          headline3: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
          headline4: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          headline5: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          headline6: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          bodyText2: TextStyle(color: Colors.black),
          caption: TextStyle(color: Colors.grey, fontSize: 14),
          button: TextStyle(color: Colors.blue),
          bodyText1: TextStyle(height: 1.5, letterSpacing: 1.2)),
      // dialogBackgroundColor: const Color(0xFF1B1B2F),
      // backgroundColor: Colors.white,
      // bottomSheetTheme: const BottomSheetThemeData(
      //   backgroundColor: Color(0xFF1B1B2F),
      // ),
      // primarySwatch: colorScheme,
      // primaryColor: Colors.black,
      // brightness: Brightness.dark,
      // primaryColorLight: Colors.black,
      // indicatorColor: Colors.black,
      // cardColor: Colors.black,
      // colorScheme: const ColorScheme.dark()
      //     .copyWith(primary: Color.fromARGB(255, 0, 0, 0)),
      // textButtonTheme: TextButtonThemeData(
      //     style: TextButton.styleFrom(
      //         alignment: Alignment.bottomCenter,
      //         textStyle:
      //             const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
      // elevatedButtonTheme: ElevatedButtonThemeData(
      //     style: ElevatedButton.styleFrom(
      //   primary: Colors.black,
      // )),
      // appBarTheme: const AppBarTheme(
      //   iconTheme: IconThemeData(
      //     color: Colors.white,
      //   ),
      //   backgroundColor: darkScaffoldBackgroundColor,
      // ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.grey[600],
        elevation: 0,
      ));

  static ThemeData darkTheme = ThemeData(
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(
          subtitle1: TextStyle(fontWeight: FontWeight.bold),
          headline1: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          headline2: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          headline4: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              height: 1.4),
          headline6: TextStyle(color: Colors.white),
          caption: TextStyle(color: Colors.black),
          button: TextStyle(color: Colors.blue),
          bodyText1: TextStyle(height: 1.5, letterSpacing: 1.2)));

  static const Color darkScaffoldBackgroundColor = Colors.black12;
  static final colorScheme = MaterialColor(0x00000000, color);
}
