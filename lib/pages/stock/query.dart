import 'package:flutter/material.dart';
import 'package:jpda/pages/comm/weigets/query_row_layout_iconbutton.dart';
import 'package:jpda/pages/comm/weigets/query_row_layout_label.dart';

class StockQueryPage extends StatefulWidget {
  @override
  _StockQueryPageState createState() => _StockQueryPageState();
}

class _StockQueryPageState extends State<StockQueryPage> {
//  TextEditingController _pdtController = new TextEditingController();
//  FocusNode _pdtFocusNote = new FocusNode();
//  TextEditingController _storeController = new TextEditingController();
//  FocusNode _storeFocusNote = new FocusNode();
//  bool _pdtEnable = true;

  QueryItemBuild _builder = null;

  @override
  void initState() {
//    _pdtController.text = "";
//    _storeController.text = "";
    _builder = QueryItemBuild();
    initViews();
    super.initState();
  }

  @override
  void dispose() {
    _builder.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("查询条件"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: _buildBody(context),
              ),
            ),
            _buildBottomBtns(context),
          ],
        ),
      ),
    );
  }

  List<Map> vdata = [
    {
      "key": "product",
      "label": "商品",
      "type": "text_query",
      "path": "/comm/query/product"
    },
    {
      "key": "store",
      "label": "店仓",
      "type": "text_query",
      "path": "/comm/query/store"
    },
  ];

  Widget _buildBody(BuildContext context) {
    return _builder.getWidget(context);
//    List<Widget> widgets = [];
//    vdata.forEach((f) {
//      widgets.add(QueryRowLayoutLabel(
//        label: f["label"],
//        child: QueryRowLayoutIconButton(
//          child: TextField(
//            autofocus: true,
//            controller: _pdtController,
//            focusNode: _pdtFocusNote,
//            textInputAction: TextInputAction.next,
//            decoration: InputDecoration(border: InputBorder.none),
//            //内容提交(按回车)的回调
//            enabled: _pdtEnable,
//            onSubmitted: (text) {
//              _pdtFocusNote.unfocus();
//              FocusScope.of(context).requestFocus(_storeFocusNote);
//            },
//          ),
//          onTap: () async {
//            if (!_pdtEnable) {
//              _pdtEnable = true;
//              _pdtController.text = "";
//              return;
//            }
//            var d = await Navigator.of(context).pushNamed(f["path"]);
//            List<Map> dd = d as List<Map>;
//            if (dd.length > 0) {
//              String name = "";
//              dd.forEach((f) {
//                name += f["code"] + ",";
//              });
//              _pdtController.text = name;
//              _pdtEnable = false;
//            }
//          },
//        ),
//      ));
//    });
//    return Column(
//      children: <Widget>[
//        QueryRowLayoutLabel(
//          label: "商品",
//          child: QueryRowLayoutIconButton(
//            child: TextField(
//              autofocus: true,
//              controller: _pdtController,
//              focusNode: _pdtFocusNote,
//              textInputAction: TextInputAction.next,
//              decoration: InputDecoration(border: InputBorder.none),
//              //内容提交(按回车)的回调
//              enabled: _pdtEnable,
//              onSubmitted: (text) {
//                _pdtFocusNote.unfocus();
//                FocusScope.of(context).requestFocus(_storeFocusNote);
//              },
//            ),
//            onTap: () async {
//              if (!_pdtEnable) {
//                _pdtEnable = true;
//                _pdtController.text = "";
//                return;
//              }
//              var d =
//                  await Navigator.of(context).pushNamed("/comm/query/product");
//              List<Map> dd = d as List<Map>;
//              if (dd.length > 0) {
//                String name = "";
//                dd.forEach((f) {
//                  name += f["code"] + ",";
//                });
//                _pdtController.text = name;
//                _pdtEnable = false;
//              }
//            },
//          ),
//        ),
//        QueryRowLayoutLabel(
//            label: "店仓",
//            child: QueryRowLayoutIconButton(
//              onTap: () {},
//              child: TextField(
//                autofocus: true,
//                controller: _storeController,
//                focusNode: _storeFocusNote,
//                decoration: InputDecoration(border: InputBorder.none),
//                textInputAction: TextInputAction.done,
//                //内容提交(按回车)的回调
//                onSubmitted: (text) {},
//              ),
//            )),
//      ],
//    );
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
                  // todo 重置
                },
                child: Text(
                  "重置",
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
                onPressed: () {
                  // todo 确定
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

  void initViews() async {
    _builder
      ..add("商品", QueryItemBuild.QUERY_ITEM_INPUT_QUERY,
          {"path": "/comm/query/product"})
      ..add("店仓", QueryItemBuild.QUERY_ITEM_INPUT_QUERY,
          {"path": "/comm/query/store"})
      ..build();
    setState(() {});
  }
}

class QueryItemBuild {
  static const String QUERY_ITEM_INPUT_QUERY = "text_query";

  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNotes = [];
  Map<int, bool> _enables = {};
  Widget _widget;

  BuildContext _context;

  List<_QueryItemBuildBean> _vdatas = [];

  void add(String label, String type, Map data) {
    _QueryItemBuildBean bean = _QueryItemBuildBean()
      ..label = label
      ..type = type
      ..data = data;
    _vdatas.add(bean);
  }

  Widget getWidget(BuildContext context) {
    _context = context;
    return _widget;
  }

  void build() {
    List<Widget> _widgets = [];
    _vdatas.forEach((d) {
      switch (d.type) {
        case QUERY_ITEM_INPUT_QUERY:
          _widgets.add(_buildTextQuery(d.label, d.data["path"]));
      }
    });
    _widget = Column(
      children: _widgets,
    );
  }

  Widget _buildTextQuery(String label, String path) {
    final TextEditingController controller = new TextEditingController();
    final FocusNode focusNode = new FocusNode();

    _controllers.add(controller);
    _focusNotes.add(focusNode);
    final int index = _controllers.indexOf(controller);
    _enables[index] = true;
    return QueryRowLayoutLabel(
      label: label,
      child: QueryRowLayoutIconButton(
        child: TextField(
          autofocus: true,
          controller: controller,
          focusNode: focusNode,
          textInputAction: _controllers.length - 1 <= index
              ? TextInputAction.done
              : TextInputAction.next,
          decoration: InputDecoration(border: InputBorder.none),
          //内容提交(按回车)的回调
          enabled: _enables[index],
          onSubmitted: (text) {
            if (_controllers.length - 1 <= index) {
              print(" last ${_controllers.length} $index $text");
            } else {
              focusNode.unfocus();
              FocusScope.of(_context).requestFocus(_focusNotes[index + 1]);
            }
          },
        ),
        onTap: () async {
          if (!_enables[index]) {
            _enables[index] = true;
            controller.text = "";
            return;
          }
          var d = await Navigator.of(_context).pushNamed(path);
          List<Map> dd = d as List<Map>;
          if (dd.length > 0) {
            String name = "";
            dd.forEach((f) {
              name += f["code"] + ",";
            });
            controller.text = name;
            _enables[index] = false;
          }
        },
      ),
    );
  }

  void disable() {
    _controllers.forEach((f) => f.dispose());
    _focusNotes.forEach((f) => f.dispose());
  }
}

class _QueryItemBuildBean {
  String label;
  String type;
  Map data;
}
