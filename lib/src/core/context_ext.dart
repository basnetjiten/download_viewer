/*
* @Author:Jiten Basnet on 15/06/2024
* @Company: GTEN SOFTWARE
*/
import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  void showSnackBar(
      {required String message,
      bool error = false,
      bool isInfo = false,
      int seconds = 2,
      TextStyle? messageStyle}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              message,
              style: messageStyle ?? const TextStyle(color: Colors.black),
            ),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          padding: const EdgeInsets.all(10),
          elevation: 0,
          duration: Duration(seconds: seconds),
          margin: const EdgeInsets.all(10),
        ),
      );
  }
}
