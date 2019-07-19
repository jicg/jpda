import 'package:flutter/material.dart';

typedef ScanBarCodeInputFeildCallback = void Function(String value);

class ScanBarCodeInputFeild extends StatefulWidget {
  final ScanBarCodeInputFeildCallback onEnter;

  const ScanBarCodeInputFeild({Key key, @required this.onEnter})
      : super(key: key);

  @override
  _ScanBarCodeInputFeildState createState() => _ScanBarCodeInputFeildState();
}

class _ScanBarCodeInputFeildState extends State<ScanBarCodeInputFeild> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        return;
      }
      if (_controller.text.contains("\n")) {
        print("---1--------------------------");
        print("---${_controller}--------------------------");
        print("---2--------------------------");
        _controller.clear();
        widget.onEnter(_controller.text.replaceFirst("\n", ""));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [
        Text("条码"),
        SizedBox(
          width: 12,
        ),
        Expanded(
          child: TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "输入条码",
                contentPadding: EdgeInsets.all(0)),
            maxLines: 2,
            textInputAction: TextInputAction.none,
            textCapitalization: TextCapitalization.characters,
            minLines: 1,
            onEditingComplete: () {
              print('onEditingComplete');
            },
//            onChanged: (value) {
//              if(value.isEmpty){
//                return;
//              }
//              if (value.contains("\n")) {
//                print("---${value.replaceFirst("\n", "")}--------------------------");
//                _controller.clear();
//                widget.onEnter(value.replaceFirst("\n", ""));
//
//              }
//            },
          ),
        ),
      ]),
    );
  }
}
