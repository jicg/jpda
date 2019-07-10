import 'package:flutter/material.dart';

class PanDianPage extends StatefulWidget {
  @override
  _PanDianPageState createState() => _PanDianPageState();
}

class _PanDianPageState extends State<PanDianPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("盘点"),
      ),
    );
  }
}
