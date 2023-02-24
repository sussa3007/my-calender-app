import 'package:flutter/material.dart';
import 'package:my_calender_app/screen/home_screen.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        fontFamily: 'NotoSans',
      ),
      home: HomeScreen(),
    )
  );
}

