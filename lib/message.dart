import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

enum TypeMsg {
  Information,
  Warning,
}
class MsgShow {
  void showMsg(String msg, TypeMsg type, BuildContext context) {
    Flushbar(
      titleText: Text("ระบบใบรับรองภาษีและสลิป",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
              color: Colors.yellow.shade600)),
      // titleColor: Colors.white,
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.blueGrey,
      icon: Icon(
        type == TypeMsg.Warning
            ? Icons.warning_rounded
            : Icons.check_circle_outline,
        color: Colors.greenAccent,
      ),
      messageText: Text(
        msg,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: Colors.yellow.shade600),
      ),
      duration: Duration(seconds: 3),
      // reverseAnimationCurve: Curves.decelerate,
      // forwardAnimationCurve: Curves.elasticOut,
      //  boxShadows: [
      //   BoxShadow(
      //       color: Colors.blue.shade800,
      //       offset: Offset(0.0, 2.0),
      //       blurRadius: 3.0)
      // ],
      // backgroundGradient:
      //     LinearGradient(colors: [Colors.blueGrey, Colors.black]),
      isDismissible: false,
      // backgroundColor: Colors.green.shade100,
      // messageSize: 16,
      // messageColor: Colors.red,
    )..show(context);
  }
}