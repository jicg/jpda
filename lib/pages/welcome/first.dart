import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              border: Border.all(color: Theme.of(context).dividerColor)),
          width: MediaQuery.of(context).size.width * 5 / 6,
          height: MediaQuery.of(context).size.height * 4 / 5,
          child: Stack(
            alignment: Alignment.center,
            overflow: Overflow.visible,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  "3s",
                  style: TextStyle(color: Colors.black, fontSize: 18.0),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: RaisedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed("/login");
                  },
                  child: Text("进入App"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
