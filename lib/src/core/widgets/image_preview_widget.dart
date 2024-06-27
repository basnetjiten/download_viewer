/*
* @Author:Jiten Basnet on 15/06/2024
* @Company: GTEN SOFTWARE
*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePreviewWidget extends StatefulWidget {
  const ImagePreviewWidget({
    super.key,
    required this.imagePath,
    required this.fileName,
    this.backButtonColor,
  });

  final String imagePath;
  final String fileName;
  final Color? backButtonColor;

  @override
  State<ImagePreviewWidget> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewWidget> {
  late File _imageFile;

  @override
  void initState() {
    super.initState();
    _imageFile = File(widget.imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: widget.backButtonColor,
        ),
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
