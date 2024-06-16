/*
* @Author:Jiten Basnet on 15/06/2024
* @Company: GTEN SOFTWARE
*/

typedef DownloadSuccessCallback = void Function(String);
typedef DownloadCompleteCallback = void Function();
typedef DownloadFailedCallback = void Function(String);
typedef DownloadProgressCallback = void Function(String);
typedef PreviewCallBack = void Function(String, String);