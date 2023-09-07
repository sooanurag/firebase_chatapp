import 'package:flutter/material.dart';

class ShowDialogModel {
  static alertDialog(
    BuildContext context,
    String inputTitle,
    Widget inputContent,
    List<Widget> inputActions,
  ) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(inputTitle),
            content: inputContent,
            actions: inputActions,
          );
        });
  }
}
