import 'package:flutter/material.dart';

Future showCircularProgressIndicatorDialog(context) async {
  await showDialog(
    context: context,
    builder: (context) => Center(
      child: CircularProgressIndicator(),
    ),
  );
}