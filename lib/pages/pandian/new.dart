// 新增不支持抽盘

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:jpda/comm/func.dart';
import 'package:jpda/comm/jpda.dart';
import 'package:jpda/pages/comm/weigets/query_row_layout_iconbutton.dart';
import 'package:jpda/pages/comm/weigets/query_row_layout_label.dart';

class PanDianNewPage extends StatefulWidget {
  @override
  _PanDianNewPageState createState() => _PanDianNewPageState();
}

class _PanDianNewPageState extends State<PanDianNewPage> {
  DateTime _dateTime;

  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  TextEditingController _remarkController = null;
  String _doctype = "INR";
  Map _store = null;
  final List _doctypeItems = [
    {"name": "全盘", "val": "INF"},
    {"name": "随机盘点", "val": "INR"},
    {"name": "历史盘点", "val": "INH"},
//    {"name": "抽盘", "val": "INS"},
//    {"name": "历史抽盘", "val": "IHS"},
  ];

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController();
    _dateTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("新增"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    QueryRowLayoutLabel(
                      label: "单据日期",
                      child: InkWell(
                        onTap: () {
                          DatePicker.showDatePicker(context,
                              showTitleActions: true, onConfirm: (date) {
                            setState(() {
                              _dateTime = date;
                            });
                          }, currentTime: _dateTime, locale: LocaleType.zh);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text("${dateFormat.format(_dateTime)}"),
                        ),
                      ),
                    ),
                    QueryRowLayoutLabel(
                      label: "盘点店仓",
                      child: InkWell(
                        onTap: () async {
                          var ret = await Navigator.of(context).pushNamed(
                              "/comm/query/store",
                              arguments: {"single": true});
                          setState(() {
                            _store = ret as Map;
                          });
                        },
                        child: QueryRowLayoutIconButton(
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child:
                                Text("${_store != null ? _store['name'] : ''}"),
                          ),
                        ),
                      ),
                    ),
                    QueryRowLayoutLabel(
                      label: "单据类型",
                      child: Padding(
                        padding: const EdgeInsets.only(left: 14.0),
                        child: DropdownButton(
                          isExpanded: true,
                          onChanged: (value) {
                            setState(() {
                              _doctype = value;
                            });
                          },
                          value: _doctype,
                          underline: new Container(),
                          items: _doctypeItems.map((f) {
                            return DropdownMenuItem(
                              child: Text("${f['name']}"),
                              value: f['val'],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    QueryRowLayoutLabel(
                      label: "盘点备注",
                      child: Padding(
                        padding: const EdgeInsets.only(left: 14.0),
                        child: TextField(
                          controller: _remarkController,
                          minLines: 1,
                          maxLines: 6,
                          decoration: InputDecoration(border: InputBorder.none),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            _buildBottomBtns(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBtns(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Theme.of(context).dividerColor)),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10),
              child: RaisedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "取消",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10),
              child: RaisedButton(
                onPressed: () async {
                  UIUtils.showDialogWait(context, title: "新增中 。。。");
                  try {
                    Response resp =
                        await JPda.web.query( "jpda_pandian\$new", {
                      "doctype": _doctype,
                      "billdate": dateFormat.format(_dateTime),
                      "store": _store,
                      "remark": _remarkController.text,
                    },context);
                    Map doc = json.decode(resp.data["data"]);
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed(
                        "/pandian/detail",
                        arguments: {"id": doc['id'] as int});
                  } catch (e) {
                    Navigator.of(context).pop();
                    UIUtils.toaskError("$e");
                  } finally {

                  }
                },
                color: Theme.of(context).primaryColor,
                child: Text(
                  "确定",
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).primaryTextTheme.caption.color),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
