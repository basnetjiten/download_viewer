/*
* @Author:Jiten Basnet on 15/06/2024
* @Company: EB Pearls
*/
import 'dart:async';
import 'dart:developer';
import 'package:download_viewer/download_viewer.dart';
import 'package:flutter/material.dart';

void main() => runZonedGuarded(() async {
      WidgetsFlutterBinding.ensureInitialized();
      runApp(const MainApp());
    },
        (Object error, StackTrace stackTrace) =>
            log('DOWNLOAD_VIEWER_ERROR::${error.toString()}'));

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DownloadViewerWidget(),
    );
  }
}

class DownloadViewerWidget extends StatelessWidget {
  const DownloadViewerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download_Viewer'),
      ),
      body: Center(
        child: MaterialButton(
          color: Colors.blueGrey,
          onPressed: () {
            DownloadViewer.downloadAndViewFile(
              context,
              displayInNativeApp: false,
              downloadUrl:
                  "https://cdn.builder.io/api/v1/image/assets%2FYJIGb4i01jvw0SRdL5Bt%2F869bfbaec9c64415ae68235d9b7b1425",
              fileName:
                  'assets_YJIGb4i01jvw0SRdL5Bt_869bfbaec9c64415ae68235d9b7b1425.jpeg',
              downloadFolderName: 'DownloadViewer',
              //customPreviewBuilder: (filename, savedPath) {},
            );
          },
          child: const Text('Download And view'),
        ),
      ),
    );
  }
}
