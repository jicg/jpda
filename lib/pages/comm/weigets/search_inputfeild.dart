import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef SearchInputFeildCallback = void Function(String value);

class SearchInputFeild extends StatefulWidget {
  final SearchInputFeildCallback query;
  final String hintText;

  const SearchInputFeild({Key key, @required this.query, this.hintText = ""})
      : super(key: key);

  @override
  _SearchInputFeildState createState() => _SearchInputFeildState();
}

class _SearchInputFeildState extends State<SearchInputFeild> {
  TextEditingController _textEditingController;
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textEditingController = new TextEditingController();
    _focusNode = new FocusNode();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            new BoxShadow(
                blurRadius: 2.0,
                offset: new Offset(1.0, 1.0),
                spreadRadius: 1.0)
          ],
          border: Border.all(color: Theme.of(context).dividerColor)),
      child: RawKeyboardListener(
        onKey: handleKey,
        child: TextField(
          maxLines: 1,
          controller: _textEditingController,
          autofocus: true,
          focusNode: _focusNode,
          textInputAction: TextInputAction.search,
          keyboardType: TextInputType.multiline,
          onSubmitted: (_) => widget.query(_textEditingController.text),
          onChanged: (t) {
            print(t);
          },
          decoration:
          InputDecoration(border: InputBorder.none, hintText: widget.hintText),
        ),
        focusNode: _focusNode,
      ),
    );
  }

  void handleKey(key) {
    if (Theme.of(context).platform == TargetPlatform.android) {
      RawKeyEventDataAndroid data = key.data as RawKeyEventDataAndroid;
      print(data);
      if (key.runtimeType.toString() == 'RawKeyUpEvent') {
        if (data.keyCode == 66) {
          widget.query(_textEditingController.text);
          //_focusNode.unfocus();
          FocusScope.of(context).requestFocus(new FocusNode());
        } else if (data.keyCode == 301) {
          if (_textEditingController.text.length == 0) {
            return;
          }
          _textEditingController.selection = TextSelection(
              baseOffset: 0, extentOffset: _textEditingController.text.length);
          widget.query(_textEditingController.text);
        }
      }
    }
  }
}