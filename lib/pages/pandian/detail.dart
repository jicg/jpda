import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jpda/comm/func.dart';
import 'package:jpda/comm/jpda.dart';
import 'package:jpda/pages/comm/weigets/detail_title_widget.dart';
import 'package:jpda/pages/comm/weigets/loading_widget.dart';
import 'package:jpda_plugin/jpda_plugin.dart';
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

  StreamSubscription subscription;

  int page = 1;
  List<Map> items = [];
  RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Map args = ModalRoute.of(context).settings.arguments;
      _docid = args["id"] as int;
      loadData();
      subscription = JpdaPlugin.scanResponse.listen(listenScan);
    });
    _refreshController = RefreshController();
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
    _refreshController?.dispose();
  }

  void loadData() async {
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

  void listenScan(Map data) async {
    String no = data['no'];
    print(no);
    try {
      await addSku(no);
      JPda.play.success();
      reLoadItem();
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
        JpdaPlugin.openScanEditText("pandian");
      }, onWillPop: () {
        subscription.resume();
        Navigator.pop(context);
        JpdaPlugin.openScanEditText("pandian");
      });
    }
  }

  Future<void> addSku(String no) async {
    Response data = await JPda.web.query("jpda_pandian\$item_scan",
        {"no": no, "sheftno": _sheftno, "docid": _docid});
    _doc = json.decode(data.data['data']);
  }

  Future<void> addSeftno(String val) async {
    print("addSeftno $_sheftno $val");
    if (val == null || val.isEmpty) {
      setState(() {
        _sheftno = val;
        _totqty = 0;
      });
      return;
    }
    if (val == _sheftno) {
      return;
    }
    try {
      Response response = await JPda.web.query(
          "jpda_pandian\$item_addsheftnos", {"docid": _docid, "sheftno": val});
      Map obj = json.decode(response.data['data']);
      setState(() {
        _sheftno = val;
        _totqty = obj['totqty'] as int;
      });
      reLoadItem();
    } catch (e) {
      print(e);
      UIUtils.toaskError("操作失败: $e");
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

  void reLoadItem() async {
    // todo 更新总数量
    try {
      page = 1;
      items = [];
      _loading_item = true;
      Response<Map> da = await JPda.web.query("jpda_pandian\$item_list",
          {"page": page, "sheftno": _sheftno, "docid": _docid});
      List dd = json.decode(da.data["data"]);
      List<Map> d = dd.map((f) => f as Map).toList();
      if (d.length > 0) {
        page++;
        items.addAll(d);
        setState(() {
          _refreshController.loadComplete();
        });
      } else {
        UIUtils.toaskError("已经没有数据");
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
      Response<Map> da = await JPda.web.query("jpda_pandian\$item_list",
          {"page": page, "sheftno": _sheftno, "docid": _docid});
      List dd = json.decode(da.data["data"]);
      List<Map> d = dd.map((f) => f as Map).toList();
      if (d.length > 0) {
        page++;
        items.addAll(d);
        setState(() {
          _refreshController.loadComplete();
        });
      } else {
        UIUtils.toaskError("已经没有数据");
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
                        onTap: () {
                          // todo 修改明细
                        },
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
                Expanded(
                  child: Material(
                    color: Colors.red,
                    child: InkWell(
                      onTap: () async {
                        print(await JpdaPlugin.openScanEditText("pandian"));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                            child: Text(
                          "录入",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )),
                      ),
                    ),
                  ),
                ),
              ]),
            )
          ],
        ),
      ),
    );
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
                    trailing: InkWell(
                      onTap: () => delSheftno(sheft['code']),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.delete),
                      ),
                    ),
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
            Card(
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
      Response data = await JPda.web
          .query("jpda_pandian\$item_loadsheftnos", {"docid": widget.docid});
      print(data.data);
      List ds = json.decode(data.data['data']);
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
      UIUtils.toaskError("查询货架失败：$e");
    }
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
      JpdaPlugin.openScanEditText("pandian");
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
        await JPda.web.query("jpda_pandian\$item_delsheftnos",
            {"docid": widget.docid, "sheftno": code});
        _cursheftno = "";
        loadData();
      } catch (e) {
        UIUtils.toaskError("删除失败：$e");
      }
    }
  }
}
