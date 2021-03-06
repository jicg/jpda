import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';

class UIUtils {
  static void showDialogWait(BuildContext context, {String title = ""}) {
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return new WillPopScope(
              child: new Center(
                child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      new Container(
                          constraints: BoxConstraints(minWidth: 200.0),
                          color: Colors.white,
                          child: new Column(
                            children: <Widget>[
                              new Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: title.isEmpty ? 40.0 : 10.0),
                                child: new Container(
                                    width: 60.0,
                                    height: 60.0,
                                    child: SpinKitCircle(color: Colors.blue)),
                              ),
                              title.isEmpty
                                  ? new SizedBox()
                                  : new Container(
                                      padding: EdgeInsets.only(bottom: 20.0),
                                      child: Text(
                                        title,
                                        style: new TextStyle(
                                            decoration: TextDecoration.none,
                                            fontSize: 16.0,
                                            color: Colors.black,
                                            textBaseline: null),
                                      ),
                                    )
                            ],
                          ))
                    ]),
              ),
              onWillPop: () => new Future.value(false));
        });
  }

  static Future<T> jpdaShowMessageDialog<T>(BuildContext context,
      {String title = "",
      String desc = "",
      barrierDismissible = true,
      VoidCallback onTap,
      VoidCallback onWillPop,
      List<FlatButton> actions,
      String okLabel = "确定"}) {
    if (actions == null) {
      actions = [];
    }
    actions.add(FlatButton(
      child: Text(okLabel),
      onPressed: onTap,
    ));
    return showDialog<T>(
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return WillPopScope(
            onWillPop: onWillPop,
            child: AlertDialog(
              title: Text(title),
              content: Text(desc),
              actions: actions,
            ));
      },
      context: context,
    );
  }

  static toaskError(BuildContext context, String msg) {
//    Fluttertoast.showToast(
////        toastDuration: Duration(seconds: 1),
//        gravity: ToastGravity.TOP,
//        textColor: Colors.white,
//        backgroundColor: Colors.red,
//        msg: msg
////        child: Container(
////          child: Text(
////            "$msg",
////            style: TextStyle(color: Colors.white),
////          ),
////          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
////          decoration: BoxDecoration(color: Colors.red,
////          boxShadow: [BoxShadow(color: Colors.red,blurRadius: 10,spreadRadius: 20)],
////          borderRadius: BorderRadius.all(Radius.circular(3))),
////        ))
//        );
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        backgroundColor: Colors.red,
//        textColor: Colors.white,
        fontSize: 16.0);
  }

  static toaskSuccess(BuildContext context, String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
//        textColor: Colors.white,
        fontSize: 16.0);
//    FlutterToast(context).showToast(
//        toastDuration: Duration(seconds: 1),
//        gravity: ToastGravity.TOP,
//        child: Container(
//          child: Text(
//            "$msg",
//            style: TextStyle(color: Colors.white),
//          ),
//          decoration: BoxDecoration(
//              color: Colors.green.withAlpha(60),
//              borderRadius: BorderRadius.circular(10)),
//        ));
  }
}

//class PermUtils {
//  static Future<Map<PermissionGroup, PermissionStatus>>
//      requestPermissions() async {
//    return await PermissionHandler().requestPermissions(
//        [PermissionGroup.contacts, PermissionGroup.storage]);
//  }
//
//  static Future<PermissionStatus> requestPermission(
//      PermissionGroup permission) async {
//    final List<PermissionGroup> permissions = <PermissionGroup>[permission];
//    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
//        await PermissionHandler().requestPermissions(permissions);
//    return permissionRequestResult[permission];
//  }
//
//  static Future<Map<Permission, PermissionStatus>> requestPermissionList(
//      List<PermissionGroup> permissions) async {
//    return await PermissionHandler().requestPermissions(permissions);
//  }
//
//  static Future<bool> openAppSettings() async {
//    return await PermissionHandler().openAppSettings();
//  }
//}

//// md5 加密
//String generateMd5(String data) {
//  var content = new Utf8Encoder().convert(data);
//  var digest = md5.convert(content);
//  // 这里其实就是 digest.toString()
//  return hex.encode(digest.bytes);
//}
class StringUtils {
  // md5 加密
  static String generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }
}
