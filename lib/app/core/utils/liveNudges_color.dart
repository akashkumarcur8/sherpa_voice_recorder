// anywhere in your utils
import 'package:flutter/material.dart';

extension ColorUtils on Color {
  Color darken([double amt = .2]) {
    final f = 1 - amt;
    return Color.fromARGB(alpha, (red * f).round(), (green * f).round(), (blue * f).round());
  }
}
