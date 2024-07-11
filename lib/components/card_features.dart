import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';

class CardFeatures extends StatelessWidget {
  final String imagePath;
  final String headingText;
  final String title1;
  final String title2;
  final String desc;
  final Color color;

  const CardFeatures({
    Key? key,
    required this.imagePath,
    required this.headingText,
    required this.title1,
    required this.title2,
    required this.desc,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  headingText,
                  style: GoogleFonts.athiti(textStyle: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white)),
                ),
                const Icon(IconlyLight.arrow_right,
                    color: Colors.white, size: 32),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title1,
                      style: GoogleFonts.acme(textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 46,
                          fontWeight: FontWeight.bold),)
                    ),
                    Transform.translate(
                      offset: const Offset(0, -12),
                      child: Text(
                        title2,
                        style: GoogleFonts.acme(textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold),)
                      ),
                    ),
                  ],
                ),
                Transform.translate(
                  offset: const Offset(20, 40),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 2, color: Colors.white)
                    ),
                    child: Image.asset(
                      imagePath,
                      width: 140,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(child: Text(desc, style: GoogleFonts.poppins(textStyle: const TextStyle(fontSize: 10)),)),
          ],
        ),
      ),
    );
  }
}
