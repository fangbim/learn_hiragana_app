import 'dart:io';
import 'package:flutter/material.dart';

class PhotoView extends StatelessWidget {
  final File? file;
  const PhotoView({super.key, this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      color: Colors.grey[300],
      child: (file == null)
          ? _buildEmptyView()
          : Image.file(
              file!,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Text('Please pick a photo'),
    );
  }
}
