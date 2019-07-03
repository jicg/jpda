import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jpda/comm/func.dart';
import 'package:jpda/comm/jpda.dart';
import 'package:jpda/comm/widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class QueryProductPage extends StatefulWidget {
  @override
  _QueryProductPageState createState() => _QueryProductPageState();
}

class _QueryProductPageState extends State<QueryProductPage> {
  RefreshController _refreshController;
  TextEditingController _textEditingController;
  FocusNode _focusNode;
  List<Map> datas = [];
  bool _loading = false;
  int _page = 1;
  String _query = "";
  final String func = "jpda_comm\$query_product";

  @override
  void initState() {
    reLoadData();
    super.initState();

    _refreshController = RefreshController(initialRefresh: false);
    _textEditingController = new TextEditingController();

    _focusNode = new FocusNode();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> reLoadData() async {
    try {
      _loading = true;
      datas = [];
      _page = 1;
      Response<Map> da =
          await JPda.web.query(func, {"page": _page, "query": _query});
      List dd = json.decode(da.data["data"]);
      List<Map> dm = dd.map((f) {
        return f as Map;
      }).toList();
      if (dm.length > 0) {
        _page++;
        datas.addAll(dm);
      }
    } catch (e) {
      UIUtils.ToaskError("$e");
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> loadMoreData() async {
    try {
      Response<Map> da =
          await JPda.web.query(func, {"page": _page, "query": _query});
      List dd = json.decode(da.data["data"]);
      List<Map> dm = dd.map((f) {
        return f as Map;
      }).toList();
      if (dm.length > 0) {
        _page++;
        datas.addAll(dm);
        setState(() {
          _refreshController.loadComplete();
        });
      } else {
        UIUtils.ToaskError("已经没有数据");
        setState(() {
          _refreshController.loadNoData();
        });
      }
    } catch (e) {
      UIUtils.ToaskError("$e");
      setState(() {
        _refreshController.loadFailed();
      });
    }
  }

  void query() {
    _query = _textEditingController.text;
    reLoadData();
  }

  void handleKey(key) {
    print("=========================$key");
    return;

    if (Theme.of(context).platform == TargetPlatform.android) {
      RawKeyEventDataAndroid data = key.data as RawKeyEventDataAndroid;
      print(data);
      if (key.runtimeType.toString() == 'RawKeyUpEvent') {
        if (data.keyCode == 66) {
          query();
          _focusNode.unfocus();
        } else if (data.keyCode == 301) {
          if (_textEditingController.text.length == 0) {
            return;
          }
          _textEditingController.selection = TextSelection(
              baseOffset: 0, extentOffset: _textEditingController.text.length);
          query();
        }
      }

//                    if (key.runtimeType.toString() == 'RawKeyDownEvent') {
//                      if (data.keyCode == 301) {
//                        if (_textEditingController.text.length > 0)
//                          _textEditingController.text = "";
//                      }
//                    }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("查询商品"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
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
                  keyboardType:TextInputType.multiline ,
                  onSubmitted: (_) => query(),
                  onChanged: (t) {
                    print(t);
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: "查询商品"),
                ),
                focusNode: _focusNode,
              )),
          Expanded(
              child:
                  LoadingWidget(loading: _loading, child: _buildQueryData())),
          Container(
            padding: EdgeInsets.all(0),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  new BoxShadow(
                      blurRadius: 20.0,
                      offset: new Offset(1.0, 3.0),
                      spreadRadius: 1.0)
                ],
                border: Border.all(color: Theme.of(context).dividerColor)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: RaisedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.cancel),
                      label: Text("取消")),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: RaisedButton.icon(
                      onPressed: () {},
                      color: Colors.blue,
                      icon: Icon(Icons.done, color: Colors.white),
                      label: Text(
                        "确定",
                        style: TextStyle(color: Colors.white),
                      )),
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQueryData() {
    if (datas.length == 0) {
      return new Container(
        child: Center(
          child: Text("没有数据"),
        ),
      );
    }
    return SmartRefresher(
      controller: _refreshController,
      child: ListView.separated(
        itemBuilder: (context, i) {
          return new ListTile(
            leading: datas[i]['img'] != null
                ? Container(
                    color: Colors.blue,
                    width: 40,
                    height: 40,
                    child: Center(
                      child: Image.network(
                        JPda.web.baseUrl + datas[i]['img'],
                      ),
                    ),
                  )
                : null,
            title: Text("${datas[i]['code']}"),
            subtitle: Text("${datas[i]['name']} ${datas[i]['desc']}"),
          );
        },
        separatorBuilder: (context, i) {
          return Divider(
            height: 0,
          );
        },
        itemCount: datas.length,
      ),
      enablePullDown: false,
      enablePullUp: true,
      onLoading: () async {
        await loadMoreData();
      },
    );
  }
}
