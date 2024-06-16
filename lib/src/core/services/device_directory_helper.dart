/*
* @Author:Jiten Basnet on 15/06/2024
* @Company: GTEN SOFTWARE
*/
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class DeviceDirectoryHelper {
  static Future<(bool, String?, String?)> checkFilePath(
      {required String fileName, required String downloadFolderName}) async {
    final String? filePath = await _getDownloadDirectory(downloadFolderName);

    if (filePath != null) {
      final String savePath = path.join(filePath, fileName);
      final File file = File(savePath);
      final String ext = path.extension(savePath);
      return (file.existsSync(), savePath, ext);
    }
    return (false, null, null);
  }

  static Future<String?> _getDownloadDirectory(String folderName) async {
    if (Platform.isAndroid) {
      final Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final Directory downloadDir =
            Directory('${externalDir.path}/Download/$folderName');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        return downloadDir.path;
      } else {
        return await _getApplicationDocDir();
      }
    } else if (Platform.isIOS) {
      return await _getApplicationDocDir();
    }
    return null;
  }

  static Future<String> _getApplicationDocDir() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }
}
