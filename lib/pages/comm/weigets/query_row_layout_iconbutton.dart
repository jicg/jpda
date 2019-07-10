import 'package:flutter/material.dart';

class QueryRowLayoutIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final IconData iconData;

  const QueryRowLayoutIconButton(
      {Key key, this.onTap, this.child, this.iconData = Icons.search})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: child,
        ),
        IconButton(icon: Icon(iconData), onPressed: onTap)
      ],
    );
  }
}
