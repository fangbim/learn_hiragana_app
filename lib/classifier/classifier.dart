
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:learn_hiragana_app/classifier/classifier_category.dart';
import 'package:learn_hiragana_app/classifier/classifier_model.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:path_provider/path_provider.dart';

typedef ClassifierLabels = List<String>;

class Classifier {
  final ClassifierLabels _labels;
  final ClassifierModel _model;
  
  Classifier._({
    required ClassifierLabels labels,
    required ClassifierModel model,
  })  : _labels = labels,
        _model = model;
  
  static Future<Classifier?> loadWith({
    required String labelsFileName,
    required String modelFileName,
  }) async {
    try {
      final labels = await _loadLabels(labelsFileName);
      final model = await _loadModel(modelFileName);
      return Classifier._(labels: labels, model: model);
    } catch (e) {
      debugPrint('Can\'t initialize Classifier: ${e.toString()}');
      if (e is Error) {
        debugPrintStack(stackTrace: e.stackTrace);
      }
      return null;
    }
  }


  static Future<ClassifierModel> _loadModel(String modelFileName) async {
    final interpreter = await Interpreter.fromAsset(modelFileName);

    // Get input and output shape from the model
    final inputShape = interpreter.getInputTensor(0).shape;
    final outputShape = interpreter.getOutputTensor(0).shape;

    debugPrint('Input shape: $inputShape');
    debugPrint('Output shape: $outputShape');

    // Get input and output type from the model
    final inputType = interpreter.getInputTensor(0).type;
    final outputType = interpreter.getOutputTensor(0).type;

    debugPrint('Input type: $inputType');
    debugPrint('Output type: $outputType');

    return ClassifierModel(
      interpreter: interpreter, 
      inputShape: inputShape, 
      outputShape: outputShape, 
      inputType: inputType, 
      outputType: outputType,
    );
  }

  static Future<ClassifierLabels> _loadLabels(String labelsFileName) async {
    final rawLabels = await FileUtil.loadLabels(labelsFileName);

    // Remove the index number from the label
    final labels = rawLabels.map((e) {
      final split = e.split(' ');
      return split.sublist(1).join(' ');
    }).toList();

    debugPrint('Labels: $labels');
    return labels;
  }

  void close() {
    _model.interpreter.close();
  }


  List<ClassifierCategory> _postProcessOutput(TensorBuffer outputBuffer) {
    final probabilityProcessor = TensorProcessorBuilder().build();

    probabilityProcessor.process(outputBuffer);

    final labelledResult = TensorLabel.fromList(_labels, outputBuffer);

    final categoryList = <ClassifierCategory>[];
    labelledResult.getMapWithFloatValue().forEach((key, value) {
      final category = ClassifierCategory(key, value);
      categoryList.add(category);
      debugPrint('label: ${category.label}, score: ${category.score}');
    });
    categoryList.sort((a, b) => (b.score > a.score ? 1 : -1));  

    return categoryList;
  }

  Image crop(Image image) {
    // Convert the image to grayscale
    Image grayImage = grayscale(image);
    // Calculate bounding box of non-white areas
    int minX = grayImage.width;
    int minY = grayImage.height;
    int maxX = 0;
    int maxY = 0;

    debugPrint('minX: ${minX}, minY: ${minY}, length: ${grayImage.data.length}');


    for (int y = 0; y < grayImage.height; y++) {
      for (int x = 0; x < grayImage.width; x++) {
        // if (grayImage.getPixel(x, y) != getColor(255, 255, 255)) {
        if (grayImage.getPixel(x, y) == getColor(0,0,0)) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }
    image = copyCrop(image, minX, minY, maxX - minX + 1, maxY - minY + 1);
    return image;
  }

  TensorImage _preProcessInput(Image image) {
    // crop to remove whitespace
    _saveImage(image, 'original.png');

    final imageCrop = crop(image);

    // Save or inspect the resized image
    _saveImage(imageCrop, 'resized_image.png');
    debugPrint('Resized image: ${imageCrop.width}x${imageCrop.height}');


    // #1
    final inputTensor = TensorImage(_model.inputType);
    inputTensor.loadImage(imageCrop);

    //2
    // final minLength = min(inputTensor.height, inputTensor.width);
    // final crpOp = ResizeWithCropOrPadOp(minLength, minLength);

    // #3
    final shapeLength  = _model.inputShape[1];
    final resizeOp = ResizeOp(shapeLength, shapeLength, ResizeMethod.BILINEAR);

    // #4
    final normalizeOp = NormalizeOp(127.5, 127.5);

    // #5
    final imageProcessor = ImageProcessorBuilder()
      // .add(crpOp)
      .add(resizeOp)
      .add(normalizeOp)
      .build();

    imageProcessor.process(inputTensor);
    debugPrint('size result after image processor: ${inputTensor.image.width}x${inputTensor.image.height}');



    // #6
    return inputTensor;
  }

  void _saveImage(Image image, String fileName) async {
    // Encode the image to PNG
    final pngBytes = encodePng(image);

    try {
      // Get the application's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;

      // Construct the full file path
      final filePath = '$path/$fileName';

      // Create the file and write the image data
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      debugPrint('Saved image to $filePath');
    } catch (e) {
      debugPrint('Failed to save image: $e');
    }
  }


  Image _convertPointsToImage(List<Offset> points, {int thickness = 4}) {
    final width = _model.inputShape[1];
    final height = _model.inputShape[2];

    // Buat gambar putih dengan ukuran input model
    final image = Image(width, height);
    fill(image, getColor(255, 255, 255)); // Isi dengan warna putih

    for (int i = 0; i < points.length - 1; i++) {
      // Jika titik saat ini atau titik berikutnya null, lanjutkan ke iterasi berikutnya
      if (points[i] == null || points[i + 1] == null) {
        continue;
      }
      // Cek jarak antara dua titik, jika lebih besar dari threshold, jangan gambar garis
      double distance = (points[i] - points[i + 1]).distance;
      if (distance > 50) { // Threshold jarak, bisa disesuaikan
        continue;
      }
      drawLine(
        image,
        (points[i].dx * width ~/ 300).toInt(),
        (points[i].dy * height ~/ 300).toInt(),
        (points[i + 1].dx * width ~/ 300).toInt(),
        (points[i + 1].dy * height ~/ 300).toInt(),
        getColor(0, 0, 0),
        thickness: thickness,
      );
    }
    return image;
  }

  ClassifierCategory predictDrawing(List<Offset> points) {
    final image = _convertPointsToImage(points,  thickness: 12);
    final tensorImage = _preProcessInput(image);

    debugPrint(
      'Image: ${image.width}x${image.height}, '
          'size: ${image.length} bytes',);

    debugPrint(
      'Pre-processed image: ${tensorImage.width}x${image.height}, '
          'size: ${tensorImage.buffer.lengthInBytes} bytes',
    );

    final outputBuffer = TensorBuffer.createFixedSize(
      _model.outputShape,
      _model.outputType,
    );

    _model.interpreter.run(tensorImage.buffer, outputBuffer.buffer);


    debugPrint('Output buffer: ${outputBuffer.getDoubleList()}');
    debugPrint('Tensor buffer: ${tensorImage.buffer.lengthInBytes}');

    // Post Process the outputBuffer
    final resultCategories = _postProcessOutput(outputBuffer);
    final topResult = resultCategories.first;

    debugPrint('Top category: ${topResult}');

    return topResult;
  }

  ClassifierCategory predict(Image image) {
    final tensorImage = _preProcessInput(image);
    debugPrint(
      'Image: ${image.width}x${image.height}, '
          'size: ${image.length} bytes',);

    debugPrint(
      'Pre-processed image: ${tensorImage.width}x${image.height}, '
          'size: ${tensorImage.buffer.lengthInBytes} bytes',
    );

    final outputBuffer = TensorBuffer.createFixedSize(
      _model.outputShape,
      _model.outputType,
    );

    _model.interpreter.run(tensorImage.buffer, outputBuffer.buffer);


    debugPrint('Output buffer: ${outputBuffer.getDoubleList()}');
    debugPrint('Tensor buffer: ${tensorImage.buffer.lengthInBytes}');

    // Post Process the outputBuffer
    final resultCategories = _postProcessOutput(outputBuffer);
    final topResult = resultCategories.first;

    debugPrint('Top category: ${topResult}');

    return topResult;
  }
}
