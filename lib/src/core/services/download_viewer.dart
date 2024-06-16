/*
* @Author:Jiten Basnet on 15/06/2024
* @Company: GTEN SOFTWARE
*/

import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:download_viewer/download_viewer.dart';
import 'package:download_viewer/src/core/context_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../typedefs.dart';
import 'package:path/path.dart' as p;

import 'device_directory_helper.dart';

class DownloadViewer {
  DownloadViewer._();

  static StreamController<String>? _downloadStreamController;

  static final Dio _dio = Dio();

  /// Downloads a file from the provided [downloadUrl] and saves it to the specified [savePath].
  ///
  /// This method handles downloading the file and provides feedback on the download progress,
  /// success, and failure through the respective callbacks.
  ///
  /// Parameters:
  /// * [downloadUrl] - The HTTPS URL of the file to be downloaded.
  /// * [savePath] - The local file path where the downloaded file should be saved.
  /// * [onSuccess] - Callback function to be executed when the download is successful. Receives the [savePath].
  /// * [onFailed] - Callback function to be executed when the download fails. Receives an error message.
  /// * [onProgress] - Callback function to be executed to report download progress. Receives a string representation of the progress percentage.
  /// * [queryParams] - Optional query parameters to include in the download request.
  /// * [cancelToken] - Optional token to cancel the download request.
  /// * [options] - Optional request configuration options.
  ///
  ///
  /// Errors:
  /// * [DioException] - If an error occurs during the download request.
  static Future<void> _downloadViaAPI({
    required String downloadUrl,
    required String savePath,
    required DownloadSuccessCallback onSuccess,
    required DownloadFailedCallback onFailed,
    required DownloadProgressCallback onProgress,
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      final response = await _dio.download(
        downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final String progress = (received / total * 100).toStringAsFixed(0);

            if (progress != '100') {
              onProgress(progress);
            }
          }
        },
        queryParameters: queryParams,
        cancelToken: cancelToken,
        options: options ??
            Options(
                responseType: ResponseType.bytes,
                headers: {HttpHeaders.acceptEncodingHeader: '*'}),
      );

      if (response.statusCode == 200) {
        onSuccess(savePath);
      } else {
        onFailed('Download failed with status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      onFailed(e.message ?? 'An error occurred during download');
    } catch (e) {
      onFailed('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Downloads the document using the provided [downloadUrl].
  ///
  /// If the file already exists at the specified path, it opens the file preview
  /// in either the native viewer or a custom viewer based on [displayInNativeApp].
  /// If the file does not exist, it downloads the file to the specified path and
  /// then opens the file.
  ///
  /// Parameters:
  /// * [downloadUrl] - The HTTPS URL for the file to be downloaded.
  /// * [fileName] - The name of the file to be downloaded.
  /// * [downloadFolderName] - The name of the folder where the file will be downloaded, usually the app name.
  /// * [displayInNativeApp] - Determines whether to open the file using the native app or a custom viewer. Defaults to true.
  /// * [progressWidget] - A widget to display a progress bar during the download process.
  /// * [customPreviewBuilder] - A custom builder widget to provide your own preview and routing. Make sure to set [displayInNativeApp] to false when using this.
  /// * [useDefaultProgressDialog] - Flag to enable or disable download progress Dialog

  ///
  /// Usage:
  ///
  /// ```dart
  /// await downloadAndViewFile(
  ///   context,
  ///   downloadUrl: 'https://example.com/file.pdf',
  ///   fileName: 'file.pdf',
  ///   downloadFolderName: 'MyApp',
  ///   displayInNativeApp: true,
  ///   progressWidget: CircularProgressIndicator(),
  /// );
  /// ```

  static Future<void> downloadAndViewFile(
    BuildContext context, {
    required String downloadUrl,
    required String fileName,
    required String downloadFolderName,
    bool displayInNativeApp = true,
    bool useDefaultProgressDialog = true,
    bool useBuiltInPreviewer = true,
    required Function(Stream<String>) onDownloadProgress,
    required DownloadFailedCallback onDownloadFailed,
    required DownloadCompleteCallback onDownloadComplete,
    void Function(String, String)? customPreviewBuilder,
    Widget? progressWidget,
  }) async {
    _downloadStreamController = StreamController<String>.broadcast();
    final CancelToken cancelToken = CancelToken();

    final (hasFilePath, savePath, fileExtension) =
        await DeviceDirectoryHelper.checkFilePath(
            fileName: fileName, downloadFolderName: downloadFolderName);

    if (savePath == null) {
      // Log error or show a message to the user
      return;
    }

    // Whether to show download progress
    if (useDefaultProgressDialog) {
      _showProgressDialog(context, cancelToken, progressWidget);
    }

    if (hasFilePath) {
      onDownloadComplete();
      _openDownloadedFile(
        displayInNativeApp,
        context,
        savePath,
        fileExtension,
        fileName,
        previewBuilder: customPreviewBuilder,
      );
    } else {
      try {
        _downloadViaAPI(
          downloadUrl: downloadUrl,
          savePath: savePath,
          cancelToken: cancelToken,
          onSuccess: (path) {
            onDownloadComplete();

            final String fileExtension = p.extension(savePath);

            _openDownloadedFile(
              displayInNativeApp,
              context,
              savePath,
              fileExtension,
              fileName,
            );
          },
          onFailed: (message) {
            onDownloadFailed(message);
          },
          onProgress: (progress) {
            _downloadStreamController?.add(progress);
          },
        );
      } catch (e) {
        onDownloadFailed(e.toString());
      }
    }
  }

  static void _openDownloadedFile(bool displayInNativeApp, BuildContext context,
      String? savePath, String? fileExtension, String? fileName,
      {void Function(String, String)? previewBuilder}) {
    if (displayInNativeApp) {
      _openNativeFile(savePath);
      _downloadStreamController?.close();
    } else {
      _openFile(
        context: context,
        savePath: savePath,
        fileExtension: fileExtension,
        fileName: fileName,
        customPreviewBuilder: previewBuilder,
      );
    }
  }

  static void _handleDownloadFailure(
      BuildContext context, CancelToken cancelToken, String message) {
    if (cancelToken.isCancelled) {
      context.showSnackBar(message: 'Download cancelled.', error: true);
    } else {
      context.showSnackBar(
          message: 'Failed to download document.', error: true);
    }
  }

  //Open file in-app or recommend app based on the document extension
  static void _openFile({
    required BuildContext context,
    required String? savePath,
    required String? fileExtension,
    required String? fileName,
    Function(String, String)? customPreviewBuilder,
  }) {
    if (fileExtension == '.pdf' || fileExtension == '.PDF') {
      if (savePath != null) {
        if (customPreviewBuilder != null) {
          customPreviewBuilder(fileName!, savePath);
          _downloadStreamController?.close();
          return;
        } else {
          final PdfViewWidget pdfRoute =
              PdfViewWidget(filePath: savePath, fileName: fileName!);
          if (Platform.isAndroid) {
            _androidRouting(context, savePath, fileName, pdfRoute);
          } else {
            _iosRouting(context, savePath, fileName, pdfRoute);
          }
        }
      }
    } else if (fileExtension == '.png' ||
        fileExtension == '.PNG' ||
        fileExtension == '.jpg' ||
        fileExtension == '.JPG' ||
        fileExtension == '.jpeg' ||
        fileExtension == '.JPEG') {
      if (savePath != null) {
        if (customPreviewBuilder != null) {
          customPreviewBuilder(fileName!, savePath);
          return;
        } else {
          final ImagePreviewWidget imageRoute =
              ImagePreviewWidget(imagePath: savePath, fileName: fileName!);
          if (Platform.isAndroid) {
            _androidRouting(context, savePath, fileName, imageRoute);
          } else {
            _iosRouting(context, savePath, fileName, imageRoute);
          }
        }
      }
    } else if (fileExtension == '.doc' ||
        fileExtension == '.DOC' ||
        fileExtension == '.docx' ||
        fileExtension == '.DOCX') {
      _openNativeFile(savePath);
    } else {
      _openNativeFile(savePath);
    }
  }

  static void _openNativeFile(String? savePath) {
    OpenFilex.open(savePath);
  }

  static void _iosRouting(
      BuildContext context, String savePath, String? fileName, Widget page) {
    Navigator.of(context).push(
        CupertinoPageRoute(builder: (context) => page, fullscreenDialog: true));
    _downloadStreamController?.close();
  }

  static void _androidRouting(
      BuildContext context, String savePath, String? fileName, Widget page) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => page, fullscreenDialog: true));
    _downloadStreamController?.close();
  }

  static void _showProgressDialog(
      BuildContext context, CancelToken cancelToken, Widget? progressWidget) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return progressWidget ??
            StreamBuilder<String>(
              stream: _downloadStreamController?.stream,
              builder: (context, snapshot) {
                return ProgressDialog(onTokenCancel: () {
                  cancelToken.cancel();
                });
              },
            );
      },
    );
  }
}
