import 'package:flutter/widgets.dart';

class SizeHelper {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double safeAreaHorizontal;
  static double safeAreaVertical;
  static double safeScreeHeight;
  static double safeScreeHeightPerc;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    safeScreeHeight = _mediaQueryData.size.height -
        _mediaQueryData.padding.top -
        _mediaQueryData.padding.bottom;

    safeScreeHeightPerc =
        (_mediaQueryData.padding.top - _mediaQueryData.padding.bottom) /
            (_mediaQueryData.size.height);

    safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
  }

  static double percentageWidth(int percentage) {
    return screenWidth * (0.01 * percentage);
  }

  static double percentageHeight(int percentage) {
    return screenHeight * (0.01 * percentage);
  }

  static double percentageSafeWidth(int percentage) {
    return (screenWidth - safeAreaHorizontal) * (0.01 * percentage);
  }

  static double percentageSafeHeight(int percentage) {
    return (screenHeight - safeAreaVertical) * (0.01 * percentage);
  }
}
