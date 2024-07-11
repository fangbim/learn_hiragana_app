import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:learn_hiragana_app/classifier/classifier.dart';
import 'package:learn_hiragana_app/components/appBar_features.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

import '../model/model_factories.dart';
import '../services/api_services.dart';

import 'package:image/image.dart' as dart_img;

const _labelFilename = 'assets/model/hiragana-label.txt';
const _modelFilename = 'model/model1(224X224)-mobilenetv2.tflite';

class Recogniser extends StatefulWidget {
  const Recogniser({super.key});

  @override
  State<Recogniser> createState() => _RecogniserState();
}

enum _ResultStatus {
  notStarted,
  notFound,
  found,
}

int CanvasSize = 300;

class _RecogniserState extends State<Recogniser> {
  bool _isAnalyzing = false;
  _ResultStatus _resultStatus = _ResultStatus.notStarted;
  String _hiraganaLabel = '';
  double _accuracy = 0.0;

  final ApiService _apiService = ApiService();
  List<HiraganaCharacters> _question = [];
  int _currentIndex = 0;

  late Classifier _classifier;
  List<Offset?> points = List.empty(growable: true);
  final pointMode = ui.PointMode.points;

  @override
  void initState() {
    super.initState();
    _loadClassifier();
    _apiService.fetchHuruf().then((characters) {
      setState(() {
        _question = _randomizeAndLimit(characters, 10);
      });
    });
  }

  Future<void> _loadClassifier() async {
    debugPrint('Start Loading of Classifier with '
        'Labels at $_labelFilename, '
        'Model at $_modelFilename');

    final classifier = await Classifier.loadWith(
      labelsFileName: _labelFilename,
      modelFileName: _modelFilename,
    );
    _classifier = classifier!;
  }

  List<HiraganaCharacters> _randomizeAndLimit(
      List<HiraganaCharacters> characters, int limit) {
    final random = Random();
    characters.shuffle(random);
    return characters.take(limit).toList();
  }

  Future<void> _saveDrawing() async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromPoints(const Offset(0, 0), const Offset(double.infinity, 300)));
      final painter = Painter(points: points);
      painter.paint(canvas, const Size(double.infinity, 300));
      final picture = recorder.endRecording();
      final img = await picture.toImage(500, 300);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/drawing.png';
      File(imagePath).writeAsBytesSync(buffer);

      // Show confirmation dialog or toast
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Gambar Disimpan'),
          content: Text('Gambar berhasil disimpan di: $imagePath'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error saving drawing: $e');
      // Show error dialog or toast
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          children: [
            AppBarFeatures(
                title: 'Menulis Aksara', currentIndex: _currentIndex, questionLength: _question.length,),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: HexColor("#ffb703"),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10), topLeft: Radius.circular(10)),
              ),
              child: _question.isNotEmpty ?  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                          color: HexColor("#83c5be"), shape: BoxShape.circle),
                      child: Center(
                          child: Text(
                                  _question[_currentIndex].latin,
                                  style: GoogleFonts.acme(
                                      textStyle: const TextStyle(
                                          fontSize: 80,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                )
                              ),
                    ),
                  ),
                ],
              ) : LoadingAnimationWidget.flickr(
                leftDotColor: Colors.pink,
                rightDotColor: Colors.blueAccent,
                size: 50,
              ),
            ),
            // canvas
            Container(
              width: double.infinity,
              height: 300,
              decoration: const BoxDecoration(
                    color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
              child: GestureDetector(
                onPanUpdate: (DragUpdateDetails details) {
                  Offset _localPosition = details.localPosition;
                  if (_localPosition.dx >= 0 &&
                      _localPosition.dx <= double.infinity &&
                      _localPosition.dy >= 0 &&
                      _localPosition.dy <= double.infinity) {
                    setState(() {
                      points.add(_localPosition);
                    });
                  }
                },
                onPanEnd: (details) async {
                  points.add(null);
                  List<Offset> nonNullPoints = points
                      .where((point) => point != null)
                      .cast<Offset>()
                      .toList();
                  await _analyzeDrawing(nonNullPoints);
                  setState(() {});
                },
                child: CustomPaint(
                  painter: Painter(points: points),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    _checkAnswer(
                        _hiraganaLabel, _question[_currentIndex].latin);
                  },
                  child: Container(
                    height: 60,
                    width: 280,
                    decoration: BoxDecoration(
                        color: HexColor("#2a9d8f"),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Center(
                      child: Text(
                        "CHECK",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _clearDrawing();
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Center(
                      child: Icon(IconlyBold.delete)
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _checkAnswer(labelModel, labelData) {
    // ),
    if (labelData == labelModel && _accuracy >= 0.8) {
      showDialog(
        barrierDismissible: false,
          context: context,
          builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.white,
                child: SizedBox(
                  width: 400,
                  height: 400,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/centang.png", width: 150, height: 150,),
                        const Text(
                          "Benar",
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                        // Text(
                        //   "Akurasi: ${(_accuracy * 100).toStringAsFixed(2)}%",
                        //   style: const TextStyle(fontSize: 24),
                        // ),
                        Text(
                          "Kamu berhasil menulis ${_question[_currentIndex].karakter} (${_question[_currentIndex].latin}) dengan benar!",
                          textAlign: TextAlign.center,style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () => _nextQuestion(),
                          child: Container(
                            width: 150,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Center(
                                child: Text(
                              'Selanjutnya',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            )),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ));
    } else {
      // show result and try again
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.white,
                child: SizedBox(
                  width: 400,
                  height: 400,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/silang.png", width: 150, height: 150,),
                        const Text(
                          "Kurang Tepat",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Text('aksara hiragana yang kamu tulis belum sesuai!', textAlign: TextAlign.center, style: GoogleFonts.cabin(
                          fontSize: 20,

                        ),),
                        const SizedBox(height: 20,),
                        InkWell(
                          onTap: () => {
                            Navigator.of(context).pop(),
                            _clearDrawing(),
                            setState(() {
                              points.clear();
                              _hiraganaLabel = '';
                              _accuracy = 0.0;
                              _resultStatus = _ResultStatus.notStarted;
                            }),
                          },
                          child: Container(
                            width: 120,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Center(
                                child: Text(
                              'Coba lagi',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            )),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ));
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _question.length - 1) {
      setState(() {
        Navigator.of(context).pop();
        _currentIndex++;
        _clearDrawing();
      });
    } else {
      showDialog(
          context: context,
          builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.white,
                child: SizedBox(
                  width: 400,
                  height: 400,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl:
                          "https://i.giphy.com/3o7abGQa0aRJUurpII.webp",
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
                        SizedBox(height: 10,),
                        const Text(
                          "Latihan selesai!",
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "Anda telah berhasil menulis setiap karakter Hiragana dengan benar",
                          textAlign: TextAlign.center,style: TextStyle(
                              fontSize: 14),
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  _question = _randomizeAndLimit(_question, 10);
                                  Navigator.of(context).pop();
                                  _currentIndex = 0;
                                  _clearDrawing();
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
                                  'Coba Lagi',
                                  style: TextStyle(fontSize: 20, color: Colors.white),
                                )),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.popUntil(context, (route) => route.isFirst);
                              },
                              child: Container(
                                width: 120,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Center(
                                    child: Text(
                                      'Selesai',
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
              ));
    }
  }

  void _setAnalyzing(bool flag) {
    setState(() {
      _isAnalyzing = flag;
    });
  }

  Future<void> _analyzeDrawing(List<Offset> points) async {
    _setAnalyzing(true);

    if (points.isEmpty) {
      return;
    }

    {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromPoints(const Offset(0, 0), const Offset(double.infinity, 300)));
      canvas.drawColor(Colors.white, ui.BlendMode.src);
      final painter = Painter(points: points);
      painter.paint(canvas, const Size(double.infinity, 300));
      final picture = recorder.endRecording();
      final img = await picture.toImage(500, 300);
      final imgByteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      final imgBytes = Uint8List.view(imgByteData!.buffer);
      debugPrint('imgBytes: ${imgBytes.length}');

      final image = dart_img.Image.fromBytes(500, 300, imgBytes);

      final resultCategory = _classifier.predict(image);
      final result = resultCategory.score >= 0.8
          ? _ResultStatus.found
          : _ResultStatus.notFound;
      final hiraganaLabel = resultCategory.label;
      final accuracy = resultCategory.score;

      _setAnalyzing(false);

      setState(() {
        _resultStatus = result;
        _hiraganaLabel = hiraganaLabel;
        _accuracy = accuracy;
      });
    }

    // final resultCategory = await _classifier.predictDrawing(points);
    // final result = resultCategory.score >= 0.8
    //     ? _ResultStatus.found
    //     : _ResultStatus.notFound;
    // final hiraganaLabel = resultCategory.label;
    // final accuracy = resultCategory.score;
    //
    // _setAnalyzing(false);
    //
    // setState(() {
    //   _resultStatus = result;
    //   _hiraganaLabel = hiraganaLabel;
    //   _accuracy = accuracy;
    // });
  }


  // Drawing
  void _clearDrawing() {
    setState(() {
      points.clear();
      _hiraganaLabel = '';
      _accuracy = 0.0;
      _resultStatus = _ResultStatus.notStarted;
    });
  }
}

class Painter extends CustomPainter {
  final List<Offset?> points;

  Painter({required this.points});

  final Paint _paintDetails = Paint()
    ..style = PaintingStyle.fill
    ..strokeWidth =
        12
    ..color = Colors.black;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        for (int i = 0; i < points.length - 1; i++) {
          // Jika titik saat ini atau titik berikutnya null, lanjutkan ke iterasi berikutnya
          if (points[i] == null || points[i + 1] == null) {
            continue;
          }
          // Cek jarak antara dua titik, jika lebih besar dari threshold, jangan gambar garis
          double distance = (points[i]! - points[i + 1]!).distance;
          if (distance > 50) {
            continue;
          }
          canvas.drawLine(points[i]!, points[i + 1]!, _paintDetails);
        }

        canvas.drawCircle(points[i]!, 6.0, _paintDetails);
        canvas.drawCircle(points[i + 1]!, 6.0, _paintDetails);
      }
    }
  }

  @override
  bool shouldRepaint(Painter oldDelegate) {
    return true ;
  }
}
