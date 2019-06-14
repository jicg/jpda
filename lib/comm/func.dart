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

  static ToaskError(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static ToaskSuccess(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.green,
//        textColor: Colors.white,
        fontSize: 16.0);
  }
}

class PermUtils {
  static Future<Map<PermissionGroup, PermissionStatus>>
      requestPermissions() async {
    return await PermissionHandler()
        .requestPermissions([PermissionGroup.contacts]);
  }

  static Future<PermissionStatus> requestPermission(
      PermissionGroup permission) async {
    final List<PermissionGroup> permissions = <PermissionGroup>[permission];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
        await PermissionHandler().requestPermissions(permissions);
    return permissionRequestResult[permission];
  }

  static Future<Map<PermissionGroup, PermissionStatus>> requestPermissionList(
      List<PermissionGroup> permissions) async {
    return await PermissionHandler().requestPermissions(permissions);
  }

  static Future<bool> openAppSettings() async {
    return await PermissionHandler().openAppSettings();
  }
}

class StringUtils {}
