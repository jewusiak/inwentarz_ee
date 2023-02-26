import 'package:flutter/material.dart';

Future showCircularProgressIndicatorDialog(context) async {
  await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    ),
  );
}