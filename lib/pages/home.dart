import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learn_hiragana_app/components/card_features.dart';
import 'package:learn_hiragana_app/pages/menulis_aksara.dart';
import 'package:learn_hiragana_app/pages/sambung_aksara.dart';
import 'package:learn_hiragana_app/pages/tebak_aksara.dart';
import 'package:learn_hiragana_app/pages/teka_teki_kata.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(right: 16, left: 16, top: 32, bottom: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                        color: const Color.fromRGBO(26, 27, 26, 1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            width: 2,
                            color: const Color.fromRGBO(97, 194, 148, 1))),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                            imageUrl: "https://static1.cbrimages.com/wordpress/wp-content/uploads/2022/01/Kirby-1.jpg",
                            fit: BoxFit.cover,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          )
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Halo NAKAMA',
                      style: GoogleFonts.bebasNeue(textStyle: const TextStyle(
                          color: Color.fromRGBO(252, 212, 73, 1),
                          fontSize: 36,
                          fontWeight: FontWeight.bold),)
                    ),
                    Transform.translate(
                      offset: const Offset(0, -7),
                      child: Text(
                        'Apa Kabar? (元気ですか)',
                        style: GoogleFonts.shipporiMincho(textStyle: const TextStyle(color: Colors.white))
                      ),
                    )
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Text(
                'Ayo belajar Hiragana sekarang!',
                style: GoogleFonts.akshar(textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w200)),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 90,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.vertical,
                    children:  [
                      InkWell(
                        onTap: () => {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const MenulisAksara()))
                        },
                        child: const CardFeatures(
                            imagePath: "assets/images/1.png",
                            headingText: 'Hiragana',
                            title1: 'Menulis',
                            title2: 'Aksara',
                            desc: 'Powered by AI',
                            color: Color.fromRGBO(71, 147, 175, 1)),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const TebakAksara()));
                        },
                        child: const CardFeatures(
                            imagePath: "assets/images/2.png",
                            headingText: 'Hiragana',
                            title1: 'Tebak',
                            title2: 'Aksara',
                            desc: 'Asah kecerdasanmu!',
                            color: Color.fromRGBO(255, 196, 112, 1)),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SambungAksara()));
                        },
                        child: const CardFeatures(
                            imagePath: "assets/images/3.png",
                            headingText: 'Hiragana - Katakana',
                            title1: 'Sambung',
                            title2: 'Aksara',
                            desc: 'Jelajahi kreativitasmu',
                            color: Color.fromRGBO(221, 87, 70, 1)),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      InkWell(
                        onTap: () => {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const TekaTekiKata()))
                        },
                        child: const CardFeatures(
                            imagePath:  "assets/images/4.png",
                            headingText: 'Hiragana - Katakana',
                            title1: 'Teka-Teki',
                            title2: 'Kata',
                            desc: 'Uji kemampuan berpikirmu!',
                            color: Color.fromRGBO(126, 170, 146, 1)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
