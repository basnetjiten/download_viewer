/*
* @Author:Jiten Basnet on 15/06/2024
* @Company: GTEN SOFTWARE
*/
import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  const ProgressDialog({super.key, required this.onTokenCancel});

  final Function() onTokenCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'previewFile',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            const CircularProgressIndicator(),
            const SizedBox(
              height: 12,
            ),
            MaterialButton(
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              onPressed: onTokenCancel,
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
