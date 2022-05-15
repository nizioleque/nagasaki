import 'package:flutter/material.dart';

class Constants {
  // colors
  static const backgroundColor = Color(0xFFD4D4D4);
  static const borderTopColor = Color(0xffF2F2F2);
  static const borderBottomColor = Color(0xff7F7F7F);
  static const gameLoseColor = Colors.red;
  static const gameWinColor = Colors.green;
  static const settingsAccentColor = Color.fromARGB(255, 209, 14, 0);

  // yellow buttons
  static const headerButtonColor = Color(0xffFFFF0A);
  static const headerButtonBorderTopColor = Color(0xffECEA90);
  static const headerButtonBorderBottomColor = Color(0xffB4B00A);
  static const headerButtonPressedColor = Color(0xff686600);
  static const headerButtonBorderTopPressedColor = Color(0xff504E04);
  static const headerButtonBorderBottomPressedColor = Color(0xffA4A11C);

  // counters
  static const counterBorderTopColor = Color(0xff630000);
  static const counterBorderBottomColor = Color(0xff150000);

  // header sizing
  static const double minAspectRatio = 2.95;
  static const double maxAspectRatio = 4.2;
  static const double maxHeaderHeight = 180;
  static const int headerFlex = 5; // header's height is 1/n of the window

  // borders
  static const double mainBorderWidth = 8.0 / 500;
}

class CachedData {
  static Map<String, Image> images = {};

  static loadImages() {
    images = {
      'digital_null':
          Image.asset('assets/images/digital_null.png', gaplessPlayback: true),
      'digital_0':
          Image.asset('assets/images/digital_0.png', gaplessPlayback: true),
      'digital_1':
          Image.asset('assets/images/digital_1.png', gaplessPlayback: true),
      'digital_2':
          Image.asset('assets/images/digital_2.png', gaplessPlayback: true),
      'digital_3':
          Image.asset('assets/images/digital_3.png', gaplessPlayback: true),
      'digital_4':
          Image.asset('assets/images/digital_4.png', gaplessPlayback: true),
      'digital_5':
          Image.asset('assets/images/digital_5.png', gaplessPlayback: true),
      'digital_6':
          Image.asset('assets/images/digital_6.png', gaplessPlayback: true),
      'digital_7':
          Image.asset('assets/images/digital_7.png', gaplessPlayback: true),
      'digital_8':
          Image.asset('assets/images/digital_8.png', gaplessPlayback: true),
      'digital_9':
          Image.asset('assets/images/digital_9.png', gaplessPlayback: true),
      'field_null': Image.asset('assets/images/field_null.png'),
      'field_1': Image.asset('assets/images/field_1.png'),
      'field_2': Image.asset('assets/images/field_2.png'),
      'field_3': Image.asset('assets/images/field_3.png'),
      'field_4': Image.asset('assets/images/field_4.png'),
      'field_5': Image.asset('assets/images/field_5.png'),
      'field_6': Image.asset('assets/images/field_6.png'),
      'field_7': Image.asset('assets/images/field_7.png'),
      'field_8': Image.asset('assets/images/field_8.png'),
      'bomb': Image.asset('assets/images/bomb.png'),
      'flag': Image.asset('assets/images/flag.png'),
      'mark': Image.asset('assets/images/mark.png'),
      'field_hidden': Image.asset('assets/images/field_hidden.png'),
      'field_correct': Image.asset('assets/images/field_correct.png'),
      'field_wrong': Image.asset('assets/images/field_wrong.png'),
    };
  }

  static void precacheImages(BuildContext context) {
    images.forEach((key, value) {
      precacheImage(value.image, context);
    });
  }
}
