import 'package:flutter/material.dart';

class QueryRowLayoutIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const QueryRowLayoutIconButton({Key key, this.onTap, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: child,
        ),
        IconButton(icon: Icon(Icons.search), onPressed: onTap)
      ],
    );
  }
}