import 'dart:math';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:learn_hiragana_app/components/appBar_features.dart';
import 'package:learn_hiragana_app/model/model_factories.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../services/api_services.dart';

class SambungAksara extends StatefulWidget {
  const SambungAksara({super.key});

  @override
  State<SambungAksara> createState() => _SambungAksaraState();
}

class _SambungAksaraState extends State<SambungAksara> {
  final ApiService _apiService = ApiService();
  List<Vocab> _words = [];
  int _currentIndex = 0;
  List<String> _shuffledCharacters = [];
  List<String> _selectedCharacters = [];

  @override
  void initState() {
    super.initState();
    _apiService.fetchHiragana().then((characters) {
      setState(() {
        _words = _randomizeAndLimit(characters, 10);
        _loadCurrentWord();
      });
    });
  }

  void _loadCurrentWord() {
    final currentWord = _words[_currentIndex];
    _shuffledCharacters = currentWord.karakter.split('')..shuffle();
    _selectedCharacters = [];
  }

  void _nextWord() {
    if (_currentIndex + 1 != _words.length) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _words.length;
        _loadCurrentWord();
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl:
                      "https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExMHVtNjJlZnVmMnJ4OTY5OGw0aXJ3cTFxbDkyMWI5ZXZmYmpiNnpydyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/I0cPAY60mn1fwilC0F/giphy.webp",
                  imageBuilder: (context, imageProvider) => Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: imageProvider,
                        )),
                  ),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Kamu hebat💪',
                  style: GoogleFonts.anton(
                      textStyle: const TextStyle(fontSize: 24)),
                  textAlign: TextAlign.center,
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
                          _words = _randomizeAndLimit(_words, 10);
                          _currentIndex = 0;
                          _loadCurrentWord();
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
                          style: TextStyle(fontSize: 20, color: Colors.white),
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
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        )),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }
  }

  void _removeLastCharacter() {
    if (_selectedCharacters.isNotEmpty) {
      setState(() {
        _selectedCharacters.removeLast();
      });
    }
  }

  List<Vocab> _randomizeAndLimit(List<Vocab> characters, int limit) {
    final random = Random();
    characters.shuffle(random);
    return characters.take(limit).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: LoadingAnimationWidget.flickr(
            leftDotColor: Colors.pink,
            rightDotColor: Colors.blueAccent,
            size: 50,
          ),
        ),
      );
    }

    final currentWord = _words[_currentIndex];

    double dynamicBoxSize = currentWord.karakter.length > 5 ? 40 : 60;
    double dynamicTextSize = currentWord.karakter.length > 5 ? 26 : 32;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.only(right: 16, left: 16, top: 32, bottom: 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppBarFeatures(
            title: 'Sambung Aksara',
            currentIndex: _currentIndex,
            questionLength: _words.length,
          ),
          const SizedBox(
            height: 40,
          ),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
                color: HexColor("#ffb703"),
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentWord.latin,
                  style: GoogleFonts.acme(
                      textStyle: const TextStyle(
                          fontSize: 38, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(color: HexColor("#fb8500")),
                  child: Text(
                    currentWord.arti,
                    style: GoogleFonts.acme(
                        textStyle: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w300)),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(currentWord.karakter.length, (index) {
                return DragTarget<String>(
                  onAccept: (data) {
                    setState(() {
                      _selectedCharacters.add(data);
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: dynamicBoxSize,
                      height: dynamicBoxSize,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                          color: _selectedCharacters.length > index
                              ? HexColor("#ff006e")
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 2)),
                      child: Center(
                        child: Text(
                          _selectedCharacters.length > index
                              ? _selectedCharacters[index]
                              : '',
                          style: TextStyle(
                              fontSize: dynamicTextSize, color: Colors.white),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _shuffledCharacters.map((char) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Draggable<String>(
                  data: char,
                  onDragStarted: () {
                    // _hideCharacter(char);
                  },
                  feedback: Material(
                    color: Colors.transparent,
                    child: Container(
                      height: dynamicBoxSize,
                      width: dynamicBoxSize,
                      decoration: BoxDecoration(
                          color: HexColor("#3a86ff"),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                          child: Text(
                        char,
                        style: TextStyle(fontSize: dynamicTextSize),
                      )),
                    ),
                  ),
                  childWhenDragging: Container(
                    height: dynamicBoxSize,
                    width: dynamicBoxSize,
                    decoration: BoxDecoration(
                        color: HexColor("#3a86ff").withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Container(
                    height: dynamicBoxSize,
                    width: dynamicBoxSize,
                    decoration: BoxDecoration(
                        color: HexColor("#3a86ff"),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: Text(
                      char,
                      style: TextStyle(
                          fontSize: dynamicTextSize, color: Colors.white),
                    )),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
              child: Text(
                'drag ke kotak putih untuk menyusun huruf',
                style: GoogleFonts.abel(
                    color: Colors.white60,
                    fontSize: 18
                ),
              )),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 2,
            decoration: const BoxDecoration(color: Colors.white),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  if (_selectedCharacters.join() == currentWord.karakter) {
                    _nextWord();
                  } else {
                    final snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Susunan Aksara Salah!',
                        message:
                            'perbaiki susunan aksara agar dapat melanjutkan ke kata yang lain!',
                        contentType: ContentType.failure,
                      ),
                    );

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(snackBar);
                  }
                },
                child: Container(
                  height: 60,
                  width: 280,
                  decoration: BoxDecoration(
                      color: HexColor("#2a9d8f"),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Text('BERIKUTNYA',
                        style: GoogleFonts.yaldevi(
                            textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white))),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  _removeLastCharacter();
                },
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Center(child: Icon(IconlyBold.delete)),
                ),
              ),
            ],
          )
        ]),
      ),
    );
  }
}
