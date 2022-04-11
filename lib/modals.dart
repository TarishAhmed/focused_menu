import 'package:flutter/material.dart';

class FocusedMenuItem {
  Color? backgroundColor;
  Widget title;
  Icon? trailingIcon;
  Function onPressed;
  double? menuItemHeight;

  FocusedMenuItem(
      {this.backgroundColor,
      required this.title,
      this.trailingIcon,
        this.menuItemHeight,
      required this.onPressed});
}
