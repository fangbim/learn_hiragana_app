import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:learn_hiragana_app/components/appBar_features.dart';
import 'package:learn_hiragana_app/model/model_factories.dart';
import 'package:learn_hiragana_app/services/api_services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TebakAksara extends StatefulWidget {
  const TebakAksara({super.key});

  @override
  State<TebakAksara> createState() => _TebakAksaraState();
}

class _TebakAksaraState extends State<TebakAksara> {
  final ApiService _apiService = ApiService();
  List<HiraganaCharacters> _question = [];
  int _currentIndex = 0;
  int _score = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiService.fetchHuruf().then((characters) {
      setState(() {
        _question = _randomizeAndLimit(characters, 10);
      });
    });
  }

  List<HiraganaCharacters> _randomizeAndLimit(
      List<HiraganaCharacters> characters, int limit) {
    final random = Random();
    characters.shuffle(random);
    return characters.take(limit).toList();
  }

  void _nextQuestion() {
    if (_controller.text.trim().toLowerCase() ==
        _question[_currentIndex].latin) {
      _score++;
    }
    if (_currentIndex < _question.length - 1) {
      setState(() {
        _currentIndex++;
        _controller.clear();
      });
    } else {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _score != 0
                          ? CachedNetworkImage(
                              imageUrl:
                                  "https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExeXRjZ3lzNGR1c25hcW5qNno5ajBqN3ZoMjAyMHdyeTZ2MDFvajc4YyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/l49JHLpRSLhecYEmI/giphy.webp",
                              imageBuilder: (context, imageProvider) => Container(
                                height: 200,
                                width: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    fit: BoxFit.cover, image: imageProvider,
                                    
                                  )
                                ),
                              ),
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      )
                          : CachedNetworkImage(
                        imageUrl:
                        "https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExM2ttbm9oOWloY2U2OGFyOHNqdjJqM2QzM3RncDcyNDhnbDV0cWxvaCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/fX8H5vJLL7ejmb8kkH/giphy.webp",
                        imageBuilder: (context, imageProvider) => Container(
                          height: 200,
                          width: 300,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                fit: BoxFit.cover, image: imageProvider,

                              )
                          ),
                        ),
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                      const SizedBox(height: 10,),
                      _score != 0
                          ? Column(
                              children: [
                                Text(
                                  'Kamu hebat!',
                                  style: GoogleFonts.anton(
                                      textStyle: const TextStyle(fontSize: 24)),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'jawaban kamu benar $_score 💪',
                                  style: GoogleFonts.abel(
                                      textStyle: const TextStyle(fontSize: 20)),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Text(
                                  'Tetap semangat!',
                                  style: GoogleFonts.anton(
                                      textStyle: const TextStyle(fontSize: 24)),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'Kesalahan adalah bagian dari proses belajar 📚',
                                  style: GoogleFonts.abel(
                                      textStyle: const TextStyle(fontSize: 14)),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('Skor Anda:'),
                      Text(
                        '${_score * 10}',
                        style: GoogleFonts.anton(fontSize: 42),
                      ),
                      const Text('Kembali ke menu'),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              setState(() {
                                _question = _randomizeAndLimit(_question,
                                    10); // Re-randomize for a new game
                                _currentIndex = 0;
                                _score = 0;
                                _controller.clear();
                              });
                            },
                            child: Container(
                              width: 120,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Center(
                                  child: Text(
                                'Tidak',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              )),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 120,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Center(
                                  child: Text(
                                'Ya',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              )),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.only(right: 16, left: 16, top: 32, bottom: 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppBarFeatures(
            title: 'Tebak Aksara',
            currentIndex: _currentIndex,
            questionLength: _question.length,
          ),
          const SizedBox(
            height: 40,
          ),
          Container(
            height: 200,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: HexColor("#ffb703")),
            child: Center(
              child: _question.isNotEmpty
                  ? Text(
                      _question[_currentIndex].karakter,
                      style: GoogleFonts.acme(
                          textStyle: const TextStyle(
                              fontSize: 100, fontWeight: FontWeight.bold)),
                    )
                  : LoadingAnimationWidget.flickr(
                      leftDotColor: Colors.pink,
                      rightDotColor: Colors.blueAccent,
                      size: 50,
                    ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'ketik jawaban disini',
                hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.w300, fontSize: 20),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2)),
                contentPadding: EdgeInsets.all(16)),
            textAlign: TextAlign.center,
            cursorColor: Colors.white,
            style: const TextStyle(color: Colors.white, fontSize: 26),
          ),
          const SizedBox(
            height: 60,
          ),
          InkWell(
            onTap: _nextQuestion,
            child: Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: HexColor("#2a9d8f"),
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child: Text('BERIKUTNYA',
                      style: GoogleFonts.yaldevi(
                          textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)))),
            ),
          ),
        ]),
      ),
    );
  }
}
