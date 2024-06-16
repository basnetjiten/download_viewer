/*
* @Author:Jiten Basnet on 15/06/2024
* @Company: GTEN SOFTWARE
*/
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewWidget extends StatelessWidget {
  const PdfViewWidget({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  final String filePath;
  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
      ),
      body: PDFView(
        filePath: filePath,
        enableSwipe: true,
        // Allow swipe gestures to navigate pages
        swipeHorizontal: false,
        // Swipe horizontally to navigate pages
        autoSpacing: true,
        // Auto spacing between pages
        pageFling: false,
        // Page fling (snap to next/previous page)
        pageSnap: false,
        onPageChanged: (page, total) {}, //print('Page changed: $page/$total');
      ),
    );
  }
}
