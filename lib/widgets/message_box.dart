import 'package:flutter/material.dart';

void showWarningMsg(final context, final msg) {
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return Container(
        alignment: Alignment.center,
        height: 100,
        width: 300,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 3,
            child: Container(
              alignment: Alignment.center,
              height: 100,
              width: 200,
              child: Text(
                "$msg",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    },
  );
}
