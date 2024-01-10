import 'dart:ui';

import 'package:flutter/src/painting/text_style.dart';
import 'package:google_fonts/google_fonts.dart';

//text styling to use in app
class AppTextStyle {
  static TextStyle ubuntuStyle(Color color, double size) {
    return GoogleFonts.ubuntu(
        fontSize: size, fontWeight: FontWeight.w900, color: color);
  }
}

// colors to use in app
class AppColors {
  static const Color primaryColor = Color(0xFF9DD1F1);
  static const Color secondaryColor = Color(0xFF508AA8);
  static const Color tertiaryColor = Color(0xFFC8E0F4);
  static const Color textColor = Color(0xFF031927);
  static const Color accentColor = Color(0xFFBA1200);

}
