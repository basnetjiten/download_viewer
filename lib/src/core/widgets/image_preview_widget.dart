import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePreviewWidget extends StatefulWidget {
  const ImagePreviewWidget({
    super.key,
    required this.imageFile,
    required this.fileName,
  });

  final String imageFile;
  final String fileName;

  @override
  State<ImagePreviewWidget> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewWidget> {
  late File _imageFile;

  @override
  void initState() {
    super.initState();
    _imageFile = File(widget.imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: FileImage(_imageFile),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 2,
        ),
      ),
    );
  }
}
