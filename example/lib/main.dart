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

class DownloadViewerWidget extends StatefulWidget {
  const DownloadViewerWidget({super.key});

  @override
  State<DownloadViewerWidget> createState() => _DownloadViewerWidgetState();
}

class _DownloadViewerWidgetState extends State<DownloadViewerWidget> {
  Completer _dialogCompleter = Completer<void>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download_Viewer'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {

            //use [useDefaultProgressDialog] false, to hide default dialog and use own progress dialog;
            // create own dialog using streamController
            // update streamController value with progress obtained in onDownloadProgress

            //Example:
            // showDialog(
            //   context: context,
            //   builder: (BuildContext context) {
            //     return StreamBuilder<String>(
            //       stream: _downloadStreamController?.stream,
            //       builder: (context, snapshot) {
            //         return Center(
            //           child: Text(
            //             snapshot.data ?? '',
            //           ),
            //         );
            //       },
            //     );
            //   },
            // );

            DownloadViewer.downloadAndViewFile(
              onDownloadComplete: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              onDownloadProgress: (Stream<String> progress) {
                //_downloadStreamController.add(progress);
              },
              context,
              displayInNativeApp: false,
              downloadUrl:
                  "https://cdn.builder.io/api/v1/image/assets%2FYJIGb4i01jvw0SRdL5Bt%2F869bfbaec9c64415ae68235d9b7b1425",
              fileName:
                  'assets_YJIGb4i01jvw0SRdL5Bt_869bfbaec9c64415ae68235d9b7b1425.jpeg',
              downloadFolderName: 'DownloadViewer',
              onDownloadFailed: (String fa) {},
              // customPreviewBuilder: (filename, savedPath) {
              //   final ImagePreviewWidget pdfRoute = ImagePreviewWidget(
              //       imagePath: savedPath, fileName: filename);
              //
              //   Navigator.of(context)
              //       .push(MaterialPageRoute(builder: (context) => pdfRoute));
              // },
            );
          },
          child: const Text('Download And view'),
        ),
      ),
    );
  }
}
