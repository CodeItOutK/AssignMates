import 'package:assignmates/theme.dart';
import 'package:flutter/material.dart';

void showCustomSnackbar(BuildContext context,String message) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: pblue, // Custom background color
    duration: Duration(seconds: 3), // Duration the Snackbar is visible
    action: SnackBarAction(
      label: '👀', // Label for the action button
      onPressed: () {
        // Code to execute when the action is pressed
      },
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}