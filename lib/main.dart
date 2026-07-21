import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen/home_page.dart';

void main() {
  runApp(const GlassmorphismApp());
}

class GlassmorphismApp extends StatelessWidget {
  const GlassmorphismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glassmorphism Light Experience',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: const HomePage(),
    );
  }
}
