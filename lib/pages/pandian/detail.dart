import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jpda/comm/func.dart';
import 'package:jpda/comm/jpda.dart';
import 'package:jpda/pages/comm/weigets/detail_title_widget.dart';
import 'package:jpda/pages/comm/weigets/loading_widget.dart';
import 'package:jpda/pages/comm/weigets/scan_barcode_inputfeild.dart';
import 'package:jpda_plugin/jpda_plugin.dart';

class PanDianDetailPage extends StatefulWidget {
  @override
  _PanDianDetailPageState createState() => _PanDianDetailPageState();
}

class _PanDianDetailPageState extends State<PanDianDetailPage> {
  bool _loading = false;
  int _docid;
  String _sheftno = "---";
  int _totqty = 0;
  Map _doc = {"docno": ""};
  List<Widget> _docInfo = [];
  int _status = 1;
  bool _isactive = true;

  StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Map args = ModalRoute.of(context).settings.arguments;
      _docid = args["id"] as int;
      loadData();
      subscription = JpdaPlugin.scanResponse.listen((data) async {
        String no = data['no'];
        try {
          await addSku(no);
          JPda.play.success();
        } catch (e) {
          JPda.play.error();
          subscription.pause();
          JpdaPlugin.closeScanEditText();
          await UIUtils.jpdaShowMessageDialog(context,
              title: "条码 $no",
              barrierDismissible: false,
              desc: "添加失败原因：$e", onTap: () {
            Navigator.pop(context);
            subscription.resume();
          }, onWillPop: () {
            subscription.resume();
            Navigator.pop(context);
          });
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  loadData() async {
    _loading = true;
    try {
      Response data =
          await JPda.web.query("jpda_pandian\$load", {"id": _docid}, context);
      print("${data.data}");
      _doc = json.decode(data.data['data']);
      _docInfo = [];

      if (_doc['show'] != null) {
        Map show = _doc['show'] as Map;
        show.forEach((k, v) {
          _docInfo.add(_buildDocInfoRow(k, v));
        });
      }
      _status = _doc['status'] as int;
      _isactive = _doc['isactive'] == 'Y';
      setState(() {
        _loading = false;
      });
    } catch (e) {
      print(e);
      UIUtils.toaskError("$e");
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
          bottom: false,
          child: DetailTitleWidget(
            showCloseBtn: true,
            actions: [
              IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    // todo actions
                  })
            ],
            backTitle: Text(
              "单据",
            ),
            frontTitle: Text("明细"),
            frontHeading: _buildTotal(context),
            frontBody: _buildItemPage(context),
            backBody: _buildDocPage(context),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          )),
    );
  }

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, state) {
              return InkWell(
                onTap: () {},
                child: Container(),
              );
            },
          );
        }).whenComplete(() {
      setState(() {});
    });
  }

  Widget _buildItemPage(BuildContext context) {
    return LoadingWidget(
      loading: _loading,
      child: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Card(
                child: ListView.builder(itemBuilder: (c, i) {
                  return ListTile(
                    title: Text("asoo1"),
                    subtitle: Text("1"),
                  );
                }),
              ),
            ),
            RaisedButton(
              onPressed: () async {
                print(await JpdaPlugin.openScanEditText("pandian"));
              },
              child: Text("录入"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDocPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        child: LoadingWidget(
          loading: _loading,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  Container(
                    color: _isactive
                        ? (_status == 2
                            ? Colors.red
                            : (_status == 1 ? Colors.green : Colors.blueAccent))
                        : Colors.grey,
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        " ${_isactive ? (_status == 2 ? '已提交' : (_status == 1 ? '未提交' : '待审核')) : '已作废'}",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "${_doc['docno']}",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  )
                ]..addAll(_docInfo),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotal(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[Text("当前货号："), Text("$_sheftno")],
          )),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            height: 20,
            width: 1,
            color: Colors.white,
          ),
          Expanded(
              child: Row(
            children: <Widget>[Text("总录入数量："), Text("$_totqty")],
          ))
        ],
      ),
    );
  }

  Widget _buildDocInfoRow(k, v) {
    return Container(
      child: Column(
        children: <Widget>[
          Divider(),
          Row(
            children: <Widget>[
              SizedBox(child: Text("$k :")),
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "$v",
                        textDirection: TextDirection.rtl,
                      ))),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> addSku(String no) async {
    Response data = await JPda.web.query("jpda_pandian\$item_scan",
        {"no": no, "sheftno": _sheftno, "docid": _docid});
    _doc = json.decode(data.data['data']);
  }
}
