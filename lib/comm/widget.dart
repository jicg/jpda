import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:jpda/comm/func.dart';

typedef DateRangeCallback = void Function(String datebeg, String dateend);
typedef InputScanSearchCallback = void Function(String value);

class DateRangePick extends StatefulWidget {
  final String datebeg;
  final String dateend;
  final DateRangeCallback onChange;

  const DateRangePick({Key key, this.datebeg, this.dateend, this.onChange})
      : super(key: key);

  @override
  _DateRangePickState createState() => _DateRangePickState();
}

class _DateRangePickState extends State<DateRangePick> {
  DateTime _dateTimeBeg = DateTime.now().subtract(Duration(days: 7));
  DateTime _dateTimeEnd = DateTime.now();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    if (widget.datebeg != null && widget.datebeg.isNotEmpty) {
      try {
        _dateTimeBeg = dateFormat.parse(widget.datebeg);
      } catch (e) {
        print(e);
        UIUtils.ToaskError("$e");
      }
    }
    if (widget.dateend != null && widget.dateend.isNotEmpty) {
      try {
        _dateTimeEnd = dateFormat.parse(widget.dateend);
      } catch (e) {
        UIUtils.ToaskError("$e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Row(
        children: <Widget>[
          InkWell(
            onTap: () {
              DatePicker.showDatePicker(context,
                  showTitleActions: true,
                  onConfirm: updateBeg,
                  maxTime: DateTime.now(),
                  currentTime: _dateTimeBeg,
                  locale: LocaleType.zh);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("${dateFormat.format(_dateTimeBeg)}"),
            ),
          ),
          Text("~"),
          InkWell(
            onTap: () {
              DatePicker.showDatePicker(context,
                  showTitleActions: true,
                  onConfirm: updateEnd,
                  currentTime: _dateTimeEnd,
                  locale: LocaleType.zh);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("${dateFormat.format(_dateTimeEnd)}"),
            ),
          ),
        ],
      ),
    );
  }

  updateBeg(DateTime time) {
    setState(() {
      _dateTimeBeg = time;
      if (_dateTimeEnd.isBefore(_dateTimeBeg)) {
        _dateTimeEnd = _dateTimeBeg;
      }
    });
    if (widget.onChange != null) {
      widget.onChange(
          dateFormat.format(_dateTimeBeg), dateFormat.format(_dateTimeEnd));
    }
  }

  updateEnd(DateTime time) {
    setState(() {
      _dateTimeEnd = time;
      if (_dateTimeEnd.isBefore(_dateTimeBeg)) {
        _dateTimeBeg = _dateTimeEnd;
      }
    });
    if (widget.onChange != null) {
      widget.onChange(
          dateFormat.format(_dateTimeBeg), dateFormat.format(_dateTimeEnd));
    }
  }
}

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

class RowSessionWithLabel extends StatelessWidget {
  final String label;
  final Widget child;

  const RowSessionWithLabel({Key key, this.label, this.child})
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

class RowRightQueryIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const RowRightQueryIconButton({Key key, this.onTap, this.child})
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

class InputScanSearch extends StatefulWidget {
  final InputScanSearchCallback query;
  final String hintText;

  const InputScanSearch({Key key, @required this.query, this.hintText = ""})
      : super(key: key);

  @override
  _InputScanSearchState createState() => _InputScanSearchState();
}

class _InputScanSearchState extends State<InputScanSearch> {
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
          textInputAction: TextInputAction.go,
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
