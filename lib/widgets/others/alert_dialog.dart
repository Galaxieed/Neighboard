import 'package:flutter/material.dart';

void showAlertDialog(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          BackButton(
            onPressed: () {
              // Perform an action when the user taps on the 'OK' button.
              Navigator.of(context).pop();
            },

          ),
        ],
      );
    },
  );
}