import 'package:flutter/material.dart';
import 'screens/main_menu_layout.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jump Day',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF111111),
        primaryColor: const Color(0xFFFF9900),
      ),
      home: const MainMenuLayout(),
    ),
  );
}
