import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatefulWidget {
  final bool loading;
  final Widget child;

  const LoadingWidget({Key key, this.loading, this.child}) : super(key: key);

  @override
  _LoadingWidgetState createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.loading == true
        ? Container(
      child: Center(
        child: SpinKitCircle(color: Colors.blue),
      ),
    )
        : widget.child;
  }
}