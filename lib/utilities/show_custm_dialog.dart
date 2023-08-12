import 'package:flutter/material.dart';

Future<bool> showCustmDialog(
  BuildContext cntx, {
  required String title,
  required String msg,
  required String cancelButton,
  required String confirmButton,
  required Color confirmButtonColor,
  required Color cancelButtonColor,
  // required Color color,
  required Function() functionWhenConfirm,
  Function()? functionWhenCancel,
}) {
  return showDialog<bool>(
    context: cntx,
    builder: (context) {
      return AlertDialog(
        // backgroundColor: color,
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              functionWhenCancel!();
              Navigator.pop(context);
            },
            child: Text(
              cancelButton,
              style: TextStyle(
                color: cancelButtonColor,
                fontSize: 20,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              functionWhenConfirm();
              Navigator.pop(context);
            },
            child: Text(
              confirmButton,
              style: TextStyle(
                color: confirmButtonColor,
                fontSize: 20,
              ),
            ),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
