/*
* @Author:Jiten Basnet on 15/06/2024
* @Company: GTEN SOFTWARE
*/
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class DeviceDirectoryHelper {
  static Future<(bool, String?, String?)> checkFilePath(
      {required bool deleteOldFile,
      required String fileName,
      required String downloadFolderName}) async {
    final String? filePath = await getDownloadDirectory(downloadFolderName);

    if (filePath != null) {
      final String savePath = path.join(filePath, fileName);
      final File file = File(savePath);

      if (deleteOldFile && await file.exists()) {
        await file.delete(recursive: true);
      }

      if (!(await file.exists())) {
        await file.create(recursive: true);
      }
      final String ext = path.extension(savePath);
      return (file.existsSync(), savePath, ext);
    }
    return (false, null, null);
  }

  // static Future<String?> _getDownloadDirectory(String folderName) async {
  //   if (Platform.isAndroid) {
  //     final Directory? externalDir = await getExternalStorageDirectory();
  //     if (externalDir != null) {
  //       final Directory downloadDir =
  //           Directory('${externalDir.path}/Download/$folderName');
  //       if (!await downloadDir.exists()) {
  //         await downloadDir.create(recursive: true);
  //       }
  //       return downloadDir.path;
  //     } else {
  //       return await _getApplicationDocDir();
  //     }
  //   } else if (Platform.isIOS) {
  //     return await _getApplicationDocDir();
  //   }
  //   return null;
  // }

  /// IOS: To download files in app folder use this in the info.plist:
  //   <key>LSSupportsOpeningDocumentsInPlace</key>
  //   <true/>
  //   <key>UIFileSharingEnabled</key>
  //   <true/>

  /// Checks for external directory in Android Platform
  /// If the directory is available it will create new download directory using the external directory.
  static Future<String?> getDownloadDirectory(String folderName) async {
    String? path;

    if (Platform.isAndroid) {
      final Directory? androidDirectory = await _getAndroidExternalStorageDir();

      if (androidDirectory != null) {
        // Create a folder named Talknow on Android
        final List<String> chunks =
            androidDirectory.path.split(Platform.pathSeparator);

        final String downloadPath = (chunks
              ..removeRange(chunks.length - 4, chunks.length)
              ..add('Download')
              ..add(folderName))
            .join(Platform.pathSeparator);

        final Directory downloadDir = Directory(downloadPath);

        try {
          if (!await downloadDir.exists()) {
            log('Directory not available, creating.');
            await downloadDir.create(recursive: true);
          }
        } catch (_) {}

        path = downloadPath;
      } else {
        // if can't get external storage dir then use
        // getApplicationDocumentsDirectory.
        // i.e. /storage/emulated/0/Android/data/com.talknow.app/files
        // it can be different according to Android version.
        final Directory dir = await getApplicationDocumentsDirectory();
        path = dir.path;
      }
    } else if (Platform.isIOS) {
      path = await _getApplicationDocumentsDirectory(folderName);
    } else {
      throw Exception('This is intended to support only Android and iOS.');
    }

    log('Download Dir is: $path');
    return path;
  }

  static Future<Directory?> _getAndroidExternalStorageDir() =>
      getExternalStorageDirectory();

  // Return the path of the Application Document Directory
  static Future<String> _getApplicationDocumentsDirectory(folderName) async {
    return getApplicationDocumentsDirectory()
        .then((Directory directory) => directory.path);
  }
}
