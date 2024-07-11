import 'package:flutter/material.dart';

class DrawingPage extends StatelessWidget {
  final GestureDetector gestureDetector;
  const DrawingPage({super.key, required this.gestureDetector});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      color: Colors.grey,
      child: gestureDetector,
    );
  }
}

