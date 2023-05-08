import 'package:flutter/material.dart';

Future showCircularProgressIndicatorDialog(context,
    {dismissable = false}) async {
  await showDialog(
    barrierDismissible: dismissable,
    context: context,
    builder: (context) => WillPopScope(
      onWillPop: () => dismissable,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    ),
  );
}
