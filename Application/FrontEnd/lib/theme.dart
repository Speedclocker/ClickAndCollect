import 'package:flutter/material.dart';

const accentColor = Color(0xFF2D7DD2);

class AppColors extends ThemeExtension<AppColors> {
  final Color railColor;
  final Color selectedIconColor, unselectedIconColor;
  final Color okPillColor, lowPillColor, outPillColor;
  final Color indicatorColor;

  AppColors({required this.railColor, required this.selectedIconColor, required this.unselectedIconColor, required this.indicatorColor, required this.okPillColor, required this.lowPillColor, required this.outPillColor});

  @override
  AppColors copyWith({Color? railColor, Color? selectedIconColor, Color? unselectedIconColor, Color? indicatorColor, Color? okPillColor, Color? lowPillColor, Color? outPillColor}) {
    return AppColors(
      railColor: railColor ?? this.railColor,
      selectedIconColor: selectedIconColor ?? this.selectedIconColor,
      unselectedIconColor: unselectedIconColor ?? this.unselectedIconColor,
      indicatorColor: indicatorColor ?? this.indicatorColor, 
      okPillColor: okPillColor ?? this.okPillColor, 
      lowPillColor: lowPillColor ?? this.lowPillColor, 
      outPillColor: outPillColor ?? this.outPillColor,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      railColor: Color.lerp(railColor, other.railColor, t)!,
      selectedIconColor: Color.lerp(selectedIconColor, other.selectedIconColor, t)!,
      unselectedIconColor: Color.lerp(unselectedIconColor, other.unselectedIconColor, t)!,
      indicatorColor: Color.lerp(indicatorColor, other.indicatorColor, t)!, 
      okPillColor: Color.lerp(okPillColor, other.okPillColor, t)!, 
      lowPillColor: Color.lerp(lowPillColor, other.lowPillColor, t)!, 
      outPillColor: Color.lerp(outPillColor, other.outPillColor, t)!,
    );
  }
}

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: accentColor,
    surface: Color(0xFFF7F9FB),
    onSurface: Color(0xFF1A2332),
    ),
  scaffoldBackgroundColor: Color.fromARGB(255, 232, 236, 239),
  cardColor: Colors.white,
  extensions: [
    AppColors(
      railColor: Color(0xFF2C4A6E), 
      selectedIconColor: Colors.white, 
      unselectedIconColor: Color(0xFF7FA3C8),
      indicatorColor: Color(0x26FFFFFF), 
      okPillColor: Colors.green, 
      lowPillColor: Colors.orange, 
      outPillColor: Colors.red
      ),
  ],
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: accentColor,
    surface: Color(0xFF1F2937),
    onSurface: Color(0xFFE2E8F0),
    ),
  scaffoldBackgroundColor: Color(0xFF111827),
  cardColor: Color(0xFF1F2937),
  extensions: [
    AppColors(
      railColor: Color(0xFF1A2332), 
      selectedIconColor: Color(0xFF2D7DD2), 
      unselectedIconColor: Color(0xFF6B7A8D),
      indicatorColor: Color(0x26FFFFFF),
      okPillColor: Colors.green, 
      lowPillColor: Colors.orange, 
      outPillColor: Colors.red
      ),
  ],
);