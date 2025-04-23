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
    colorScheme: ColorScheme.light().copyWith(primary: Colors.black),
    popupMenuTheme: const PopupMenuThemeData(color: Colors.white),
    cardColor: Colors.grey[100],
    scaffoldBackgroundColor: Colors.white,
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(Colors.white),
    ),
    checkboxTheme: CheckboxThemeData(
      checkColor: MaterialStateProperty.all(Colors.white),
      fillColor: MaterialStateProperty.all(Colors.black),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    sliderTheme: SliderThemeData(
      thumbColor: Colors.black,
      activeTrackColor: Colors.black,
      inactiveTrackColor: Colors.grey[200],
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    brightness: Brightness.light,
    textTheme: const TextTheme(
      bodySmall: TextStyle(fontWeight: FontWeight.w400),
      headlineLarge: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      headlineMedium: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      headlineSmall: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      titleLarge: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: Colors.black),
      labelSmall: TextStyle(color: Colors.grey, fontSize: 14),
      labelMedium: TextStyle(color: Colors.blue),
      bodyMedium: TextStyle(height: 1.5, letterSpacing: 1.2),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.black,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      unselectedItemColor: Colors.grey[600],
      elevation: 0,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    fontFamily: 'Poppins',
    primaryColor: Colors.white,
    colorScheme: ColorScheme.dark().copyWith(primary: Colors.white),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(Colors.black),
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: Color.fromARGB(255, 14, 9, 27),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color.fromARGB(255, 16, 16, 35),
    ),
    cardColor: const Color.fromARGB(255, 14, 9, 27),
    popupMenuTheme: const PopupMenuThemeData(
      color: Color.fromARGB(255, 16, 16, 35),
    ),
    primaryColorDark: const Color.fromARGB(255, 0, 0, 0),
    scaffoldBackgroundColor: const Color.fromARGB(255, 5, 1, 24),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    sliderTheme: SliderThemeData(
      thumbColor: Colors.white,
      activeTrackColor: Colors.grey[50],
      inactiveTrackColor: Colors.grey[200],
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.white,
    ),
    checkboxTheme: CheckboxThemeData(
      checkColor: MaterialStateProperty.all(Colors.black),
      fillColor: MaterialStateProperty.all(Colors.white),
    ),
    textTheme: const TextTheme(
      bodySmall: TextStyle(fontWeight: FontWeight.w400),
      headlineLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      headlineSmall: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: Colors.white),
      labelSmall: TextStyle(color: Colors.grey, fontSize: 14),
      labelMedium: TextStyle(color: Colors.blue),
      bodyMedium: TextStyle(height: 1.5, letterSpacing: 1.2),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      unselectedItemColor: Colors.grey[600],
      elevation: 0,
    ),
  );

  static const Color darkScaffoldBackgroundColor = Colors.black12;
  static final colorScheme = MaterialColor(0x00000000, color);
}
