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
      popupMenuTheme: const PopupMenuThemeData(color: Colors.white),
      // cardColor: const Color.fromARGB(255, 6, 6, 6),
      cardColor: Colors.grey[100],
      scaffoldBackgroundColor: Colors.white,
      checkboxTheme: CheckboxThemeData(
          checkColor: MaterialStateProperty.all(Colors.white),
          fillColor: MaterialStateProperty.all(Colors.black)),
      appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          iconTheme: IconThemeData(color: Colors.black)),
      sliderTheme: SliderThemeData(
        thumbColor: Colors.black,
        activeTrackColor: Colors.black,
        inactiveTrackColor: Colors.grey[200],
      ),
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
      brightness: Brightness.light,
      textTheme: const TextTheme(
          subtitle1: TextStyle(
              fontWeight: FontWeight.w400), // Default style for TextField
          headline1: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
          headline2: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
          headline3: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          headline4: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          headline5: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          headline6: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          bodyText2: TextStyle(color: Colors.black),
          caption: TextStyle(color: Colors.grey, fontSize: 14),
          button: TextStyle(color: Colors.blue),
          bodyText1: TextStyle(height: 1.5, letterSpacing: 1.2)),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.black,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.grey[600],
        elevation: 0,
      ));

  static ThemeData darkTheme = ThemeData(
      fontFamily: 'Poppins',
      primaryColor: Colors.white,
      brightness: Brightness.dark,
      dialogTheme:
          const DialogTheme(backgroundColor: Color.fromARGB(255, 14, 9, 27)),
      bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color.fromARGB(255, 14, 9, 27)),
      cardColor: const Color.fromARGB(255, 14, 9, 27),
      popupMenuTheme:
          const PopupMenuThemeData(color: Color.fromARGB(255, 16, 16, 35)),
      primaryColorDark: const Color.fromARGB(255, 0, 0, 0),
      scaffoldBackgroundColor: const Color.fromARGB(255, 5, 1, 24),
      appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: IconThemeData(color: Colors.white)),
      sliderTheme: SliderThemeData(
        thumbColor: Colors.white,
        activeTrackColor: Colors.grey[50],
        inactiveTrackColor: Colors.grey[200],
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.white,
      ),
      checkboxTheme: CheckboxThemeData(
          checkColor: MaterialStateProperty.all(Colors.black),
          fillColor: MaterialStateProperty.all(Colors.white)),
      textTheme: const TextTheme(
          subtitle1: TextStyle(
              fontWeight: FontWeight.w400), // Default style for TextField
          headline1: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
          headline2: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
          headline3: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          headline4: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          headline5: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          headline6: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          bodyText2: TextStyle(color: Colors.white),
          caption: TextStyle(color: Colors.grey, fontSize: 14),
          button: TextStyle(color: Colors.blue),
          bodyText1: TextStyle(height: 1.5, letterSpacing: 1.2)),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.grey[600],
        elevation: 0,
      ));

  static const Color darkScaffoldBackgroundColor = Colors.black12;
  static final colorScheme = MaterialColor(0x00000000, color);
}
