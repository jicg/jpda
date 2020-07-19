import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jpda/comm/func.dart';
import 'package:jpda/comm/jpda.dart';
import 'package:jpda/pages/comm/weigets/detail_title_widget.dart';
import 'package:jpda/pages/comm/weigets/loading_widget.dart';
import 'package:jpda/pages/comm/weigets/query_row_layout_label.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PanDianDetailPage extends StatefulWidget {
  @override
  _PanDianDetailPageState createState() => _PanDianDetailPageState();
}

class _PanDianDetailPageState extends State<PanDianDetailPage> {
  bool _loading = false;
  bool _loading_item = false;
  int _docid;
  String _sheftno = "";
  int _totqty = 0;
  Map _doc = {"docno": ""};
  List<Widget> _docInfo = [];
  int _status = 1;
  bool _isactive = true;

//  StreamSubscription subscription;

  int page = 1;
  List<Map> items = [];
  RefreshController _refreshController;
  TextEditingController _skuController;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Map args = ModalRoute.of(context).settings.arguments;
      _docid = args["id"] as int;
      loadData();
//      subscription = JpdaPlugin.scanResponse.listen(listenScan);
    });
    _refreshController = RefreshController();
    _skuController = new TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
//    subscription?.cancel();
    _refreshController?.dispose();
  }

  void loadData() async {
    _loading = true;
    try {
      Map data =
          await JPda.web.query2("jpda_pandian\$load", {"id": _docid}, context);
      print("${data}");
      _doc = json.decode(data['data']);
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
      UIUtils.toaskError(context, "$e");
      setState(() {
        _loading = false;
      });
    }
  }

  void addSku(String no) async {
    try {
      Map response = await JPda.web.query2("jpda_pandian\$item_scan",
          {"no": no, "sheftno": _sheftno, "docid": _docid});
      Map obj = json.decode(response['data']);
      setState(() {
        _totqty = obj['totqty'] as int;
      });
      JPda.play.success();
      _skuController.text = "";
      reLoadItem();
    } catch (e) {
      JPda.play.error();
      Navigator.pop(context);
      _skuController.selection = TextSelection(
          baseOffset: 0, extentOffset: _skuController.text.length);
      await UIUtils.jpdaShowMessageDialog(context,
          title: "条码 $no",
          barrierDismissible: false,
          desc: "添加失败原因：$e", onTap: () {
        Navigator.pop(context);
        _openScanView(context);
      }, onWillPop: () {
        Navigator.pop(context);
        _openScanView(context);
      });
    }
  }

  Future<void> addSeftno(String val) async {
    if (val == null || val.isEmpty) {
      return;
    }
    if (val == _sheftno) {
      return;
    }
    try {
      Map response = await JPda.web.query2(
          "jpda_pandian\$item_addsheftnos", {"docid": _docid, "sheftno": val});
      Map obj = json.decode(response['data']);
      setState(() {
        _sheftno = val;
        _totqty = obj['totqty'] as int;
      });
      reLoadItem();
    } catch (e) {
      print(e);
      UIUtils.toaskError(context, "操作失败: $e");
    }
  }

  void showSheftnoPicker(BuildContext context) async {
    // todo 查询 货架
    String str = await showModalBottomSheet<String>(
        builder: (context) {
          return ShelfnoView(
            docid: _docid,
            cursheftno: _sheftno,
            status: _status,
            isactive: _isactive,
          );
        },
        context: context);
    addSeftno(str);
  }

  void showModifyItemQtyDialog(BuildContext context, Map item) async {
    if (_status != 1) {
      return;
    }
    int str = await showDialog<int>(
        builder: (context) {
          return ItemModifyView(
            item: item,
            docid: _docid,
            sheftno: _sheftno,
          );
        },
        context: context);

    if (str != null) {
      String no = item["SKU"];
      int bv = item["QTY"];
      if (str == bv) {
        return;
      }
      try {
        Map response = await JPda.web.query2("jpda_pandian\$item_scan", {
          "no": no,
          "sheftno": _sheftno,
          "docid": _docid,
          "type": "m",
          "qty": str
        });
        Map obj = json.decode(response['data']);
        setState(() {
          _totqty = obj['totqty'] as int;
        });
        JPda.play.success();
        reLoadItem();
      } catch (e) {
        JPda.play.error();
        UIUtils.toaskError(context, "添加失败原因：$e");
      }
    }
  }

  void showActionDialog(BuildContext context) async {
    if (_status != 1) {
      return;
    }
    // todo 更新货架明细
    await showModalBottomSheet<String>(
        builder: (context) {
          return Card(
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                InkWell(
                  onTap: doUpdateSheftnoItems,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.title),
                          Text("更新货架明细"),
                        ],
                      ),
                    ),
                  ),
                ),
//                Divider(),
//                Padding(
//                  padding: const EdgeInsets.all(8.0),
//                  child: Row(
//                    mainAxisSize: MainAxisSize.min,
//                    children: <Widget>[
//                      Icon(Icons.title),
//                      Text("更新货架明细"),
//                    ],
//                  ),
//                )
              ]),
            ),
          );
        },
        context: context);
  }

  void doUpdateSheftnoItems() async {
    Navigator.pop(context);
    try {
      Map response = await JPda.web
          .query2("jpda_pandian\$action_upitem", {"docid": _docid});
      UIUtils.jpdaShowMessageDialog(context,
          title: "操作成功", desc: "${response['data']}", onTap: () {
        Navigator.pop(context);
      });
      loadData();
    } catch (e) {
      UIUtils.jpdaShowMessageDialog(context, title: "操作失败", desc: "$e",
          onTap: () {
        Navigator.pop(context);
      });
    }
  }

  void reLoadItem() async {
    try {
      page = 1;
      items = [];
      _loading_item = true;
      Map da = await JPda.web.query2("jpda_pandian\$item_list",
          {"page": page, "sheftno": _sheftno, "docid": _docid});
      List dd = json.decode(da["data"]);
      List<Map> d = dd.map((f) => f as Map).toList();
      if (d.length > 0) {
        page++;
        items.addAll(d);
        setState(() {
          _refreshController.loadComplete();
        });
      } else {
        UIUtils.toaskError(context, "已经没有数据");
        setState(() {
          _refreshController.loadNoData();
        });
      }
    } catch (e) {
      setState(() {
        _refreshController.loadFailed();
      });
    }
    setState(() {
      _loading_item = false;
    });
  }

  Future<void> loadItemMore() async {
    try {
      Map da = await JPda.web.query2("jpda_pandian\$item_list",
          {"page": page, "sheftno": _sheftno, "docid": _docid});
      List dd = json.decode(da["data"]);
      List<Map> d = dd.map((f) => f as Map).toList();
      if (d.length > 0) {
        page++;
        items.addAll(d);
        setState(() {
          _refreshController.loadComplete();
        });
      } else {
        UIUtils.toaskError(context, "已经没有数据");
        setState(() {
          _refreshController.loadNoData();
        });
      }
    } catch (e) {
      setState(() {
        _refreshController.loadFailed();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
          bottom: true,
          child: DetailTitleWidget(
            showCloseBtn: true,
            actions: [
              IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                  ),
                  onPressed: () => showActionDialog(context))
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

  Widget _buildItemPage(BuildContext context) {
    return LoadingWidget(
      loading: _loading_item,
      child: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Card(
                child: SmartRefresher(
                  controller: _refreshController,
                  enablePullDown: false,
                  enablePullUp: true,
                  onLoading: () async {
                    await loadItemMore();
                  },
                  child: ListView.separated(
                    itemBuilder: (context, i) {
                      final Map d = items[i];
                      return ListTile(
                        title: Text("${d['SKU']}"),
                        subtitle: Text("${d['REMARK']}"),
                        onTap: () => showModifyItemQtyDialog(context, d),
                        trailing: Text(
                          "${d['QTY']}",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                    itemCount: items.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        height: 1,
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border:
                    Border(top: BorderSide(width: 2, color: Colors.black54)),
              ),
              child: Row(children: [
                Expanded(
                    child: InkWell(
                  onTap: () => showSheftnoPicker(context),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(child: Text("选择货号 $_sheftno")),
                  ),
                )),
                _status == 1
                    ? Expanded(
                        child: Material(
                          color: Colors.red,
                          child: InkWell(
                            onTap: () async {
//                              print(
//                                  await JpdaPlugin.openScanEditText("pandian"));
                              _openScanView(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                  child: Text(
                                "录入",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              )),
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ]),
            )
          ],
        ),
      ),
    );
  }

  _openScanView(BuildContext context) async {
    String str = await showModalBottomSheet<String>(
        builder: (context) {
          return new AnimatedPadding(
            padding: MediaQuery.of(context).viewInsets, //边距（必要）
            duration: const Duration(milliseconds: 100), //时常 （必要）
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
              child: TextField(
                controller: _skuController,
                focusNode: _focusNode,

                decoration: InputDecoration(border: InputBorder.none),
                onSubmitted: (val) {
                  print("onSubmitted " + val);
//                  Navigator.pop(context, val);
                  addSku(val);
                },
//                onEditingComplete: (){
//                  print("onEditingComplete ${_skuController.value.text}");
//                },
                autofocus: true,
              ),
            ),
          );
        },
        context: context);
    //addSeftno(str);
  }

  Widget _buildDocPage(BuildContext context) {
    final List<Widget> docWidgets = <Widget>[
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
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      )
    ]..addAll(_docInfo);
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
                children: docWidgets,
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

class ShelfnoView extends StatefulWidget {
  final int docid;
  final int status;
  final bool isactive;
  final String cursheftno;

  const ShelfnoView(
      {Key key, this.docid, this.status, this.cursheftno, this.isactive})
      : super(key: key);

  @override
  _ShelfnoViewState createState() => _ShelfnoViewState();
}

class _ShelfnoViewState extends State<ShelfnoView> {
  bool _isloading = false;
  String _cursheftno;

  List<Map> _sheftnos = [];
  TextEditingController _seftnoController = null;

  @override
  void initState() {
    super.initState();
    _cursheftno = widget.cursheftno;
    _seftnoController = TextEditingController();
    loadData();
  }

  @override
  void dispose() {
    super.dispose();
    _seftnoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: LoadingWidget(
        loading: _isloading,
        child: Column(
          children: <Widget>[
            Card(
              elevation: 4,
              margin: EdgeInsets.all(0),
              shape: BeveledRectangleBorder(),
              color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Text(
                  "选择货号",
                  style: TextStyle(color: Colors.white),
                )),
              ),
            ),
            Divider(
              height: 1,
            ),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, i) {
                  final Map sheft = _sheftnos[i];
                  return ListTile(
                    onTap: () {
                      _cursheftno = sheft['code'] as String;
                      Navigator.of(context).pop(_cursheftno);
                    },
                    title: Text("${sheft['code']}"),
                    subtitle: Text("${sheft['desc']}"),
                    trailing: widget.status == 1
                        ? InkWell(
                            onTap: () => delSheftno(sheft['code']),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.delete),
                            ),
                          )
                        : Icon(Icons.arrow_right),
                  );
                },
                itemCount: _sheftnos.length,
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    height: 1,
                  );
                },
              ),
            ),
            widget.status == 1
                ? Card(
                    color: Colors.blue,
                    child: InkWell(
                        onTap: () => showSeftnoDialog(context),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              "新增货架并扫描",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )),
                  )
                : new Container(),
          ],
        ),
      ),
      onWillPop: () {
        Navigator.pop(context, _cursheftno);
        return Future.value(false);
      },
    );
  }

  void loadData() async {
    _isloading = true;
    try {
      Map data = await JPda.web
          .query2("jpda_pandian\$item_loadsheftnos", {"docid": widget.docid});
      print(data);
      List ds = json.decode(data['data']);
      _sheftnos = ds.map((f) {
        return f as Map;
      }).toList();
      if (_sheftnos.length > 0) {
        if (_cursheftno == null || _cursheftno.isEmpty) {
          _cursheftno = _sheftnos[0]["code"];
        }
      } else {
        _cursheftno = "";
      }
    } catch (e) {
      print(e);
      UIUtils.toaskError(context, "查询货架失败：$e");
    }
    if (mounted)
      setState(() {
        _isloading = false;
      });
  }

  void showSeftnoDialog(BuildContext context) async {
    String val = await showDialog<String>(
        context: context,
        builder: (c) {
          return SimpleDialog(children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                Text("货架:"),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: Container(
                        child: TextField(
                  controller: _seftnoController,
                  decoration: InputDecoration(border: InputBorder.none),
                  onSubmitted: (val) {
                    Navigator.pop(context, val);
                  },
                  autofocus: true,
                )))
              ]),
            ),
            Divider(
              height: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("取消")),
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context, _seftnoController.text);
                    },
                    child: Text("确定")),
              ],
            )
          ]);
        });
    if (val != null && val.isNotEmpty) {
      _cursheftno = val;
      print("showSeftnoDialog " + val);
      Navigator.pop(context, val);
//      JpdaPlugin.openScanEditText("pandian");
    }
  }

  void delSheftno(String code) async {
    bool flag = await UIUtils.jpdaShowMessageDialog<bool>(context, actions: [
      FlatButton(
        child: Text("取消"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ], onTap: () {
      Navigator.of(context).pop(true);
    }, title: "操作警告", desc: "确定删除货架【$code】,删除后,将无法恢复！", okLabel: "确定");

    if (flag != null && flag) {
      try {
        await JPda.web.query2("jpda_pandian\$item_delsheftnos",
            {"docid": widget.docid, "sheftno": code});
        _cursheftno = "";
        loadData();
      } catch (e) {
        UIUtils.toaskError(context, "删除失败：$e");
      }
    }
  }
}

class ItemModifyView extends StatefulWidget {
  final Map item;
  final int docid;
  final String sheftno;

  const ItemModifyView({Key key, this.item, this.docid, this.sheftno})
      : super(key: key);

  @override
  _ItemModifyViewState createState() => _ItemModifyViewState();
}

class _ItemModifyViewState extends State<ItemModifyView> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.text = "${widget.item['QTY']}";
    _controller.selection =
        TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(children: [
      buildRow(
        context,
        "货架",
        Text("${widget.sheftno}"),
      ),
      buildRow(
        context,
        "商品",
        Text("${widget.item["SKU"]}"),
      ),
      buildRow(
        context,
        "数量",
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(0),
            ),
            buildCounter: (BuildContext context,
                    {int currentLength, int maxLength, bool isFocused}) =>
                null,
            maxLength: 10,
            maxLengthEnforced: true,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (String val) {
              int v = int.tryParse(val);
              if (v == null) {
                UIUtils.toaskError(context, "非法数量");
                return;
              }
              Navigator.pop(context, v);
            },
            keyboardType: TextInputType.numberWithOptions(),
          ),
        ),
      ),
      Divider(
        height: 1,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("取消")),
          FlatButton(
              onPressed: () {
                int v = int.tryParse(_controller.text);
                if (v == null) {
                  UIUtils.toaskError(context, "非法数量");
                  return;
                }
                Navigator.pop(context, v);
              },
              child: Text("确定")),
        ],
      )
    ]);
  }

  Widget buildRow(BuildContext context, String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}
