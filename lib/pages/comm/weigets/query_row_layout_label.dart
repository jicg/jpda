import 'package:flutter/material.dart';

class QueryRowLayoutLabel extends StatelessWidget {
  final String label;
  final Widget child;

  const QueryRowLayoutLabel({Key key, this.label, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("$label"),
            Text(" : "),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}