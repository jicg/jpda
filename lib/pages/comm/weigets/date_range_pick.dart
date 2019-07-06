import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:jpda/comm/func.dart';

typedef DateRangeCallback = void Function(String datebeg, String dateend);


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
        UIUtils.toaskError("$e");
      }
    }
    if (widget.dateend != null && widget.dateend.isNotEmpty) {
      try {
        _dateTimeEnd = dateFormat.parse(widget.dateend);
      } catch (e) {
        UIUtils.toaskError("$e");
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
