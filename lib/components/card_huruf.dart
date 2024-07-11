import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class CardHuruf extends StatelessWidget {
  final String karakter;
  final String latin;
  const CardHuruf({Key? key, required this.karakter, required this.latin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const randomColor = ['#7ED7C1', '#F0DBAF', '#DC8686', '#B06161', '#F6995C', '#51829B', '#638889'];
    final random = Random();
    final randomIndex = random.nextInt(randomColor.length);
    final randomBackgroundColor = HexColor(randomColor[randomIndex]);
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
          color: randomBackgroundColor, borderRadius: BorderRadius.circular(10),
          border: Border.all(
              width: 4,
              color: Colors.white)
          ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(karakter,
              style: GoogleFonts.notoSans(
                  textStyle: const TextStyle(
                      color: Colors.white, fontSize: 80))),
          Text(latin,
              style: GoogleFonts.amaranth(
                  textStyle: const TextStyle(
                      color: Colors.white, fontSize: 24))),
        ],
      ),
    );
  }
}
