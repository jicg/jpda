import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatefulWidget {
  final bool loading;
  final Widget child;
  final Color loadBackgroundColor;

  const LoadingWidget(
      {Key key, this.loading, this.child, this.loadBackgroundColor})
      : super(key: key);

  @override
  _LoadingWidgetState createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.loading == true
        ? Container(
            color: widget.loadBackgroundColor,
            child: Center(
              child: SpinKitCircle(color: Colors.blue),
            ),
          )
        : widget.child;
  }
}
