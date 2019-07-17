import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jpda/comm/func.dart';
import 'package:jpda/comm/jpda.dart';
import 'package:jpda/pages/comm/weigets/detail_title_widget.dart';
import 'package:jpda/pages/comm/weigets/loading_widget.dart';

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

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Map args = ModalRoute.of(context).settings.arguments;
      _docid = args["id"] as int;
      loadData();
    });
  }

  loadData() async {
    _loading = true;
    try {
      Response data =
          await JPda.web.query(context, "jpda_pandian\$load", {"id": _docid});
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
                  onPressed: () {})
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
      setState(() {
//        _showBottomBtns = true;
      });
    });
  }

  Widget _buildItemPage(BuildContext context) {
    return LoadingWidget(
      loading: _loading,
      child: Container(
        child: Column(
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  Text("商品"),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "输入条码",
                          contentPadding: EdgeInsets.all(0)),
                    ),
                  ),
                  Material(
                    color: Colors.blue,
                    child: InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "确定",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ]),
              ),
            ),
            Expanded(
              child: Card(
                child: ListView.builder(itemBuilder: (c,i){
                  return ListTile(
                    title: Text("asoo1"),
                    subtitle: Text("1"),
                  );
                }),
              ),
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
}
