import 'package:flutter/material.dart';
import 'package:jpda/pages/comm/weigets/query_row_layout_iconbutton.dart';
import 'package:jpda/pages/comm/weigets/query_row_layout_label.dart';

class QueryPage extends StatefulWidget {
  const QueryPage({Key key}) : super(key: key);

  @override
  _QueryPageState createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage> {
  List<QueryPageTextFeildBean> _textFeilds = [];
  List<BuildFunc> _widget_funcs = [];
  Map<String, dynamic> rets = {};
  QueryPageDataBuilder data;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        data = ModalRoute.of(context).settings.arguments;
        beforeBuild();
      });
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
                child: Column(
                  children: _widget_funcs.map((f) {
                    return f();
                  }).toList(),
                ),
              ),
            ),
            _buildBottomBtns(context),
          ],
        ),
      ),
    );
  }

  Future<void> beforeBuild() async {
//    _textFeilds.forEach((f) => f.dispose());
//    _widget_funcs = [];
//    _textFeilds=[];
    data._vdatas.forEach((d) {
      switch (d.type) {
        case QueryPageDataBuilder.QUERY_ITEM_INPUT_QUERY:
          _widget_funcs.add(_buildTextQuery(d.key, d.label, d.data["path"]));
          break;
        case QueryPageDataBuilder.QUERY_ITEM_INPUT:
          _widget_funcs.add(_buildText(d.key, d.label));
      }
    });
    setState(() {});
  }

  BuildFunc _buildText(String key, String label) {
    final QueryPageTextFeildBean textFeildBean =
        QueryPageTextFeildBean(key, TextEditingController(), FocusNode());
    _textFeilds.add(textFeildBean);
    final int index = _textFeilds.indexOf(textFeildBean);
    return () => QueryRowLayoutLabel(
          label: label,
          child: TextField(
            autofocus: true,
            controller: _textFeilds[index].controller,
            focusNode: _textFeilds[index].focusNode,
            textInputAction: _textFeilds.length - 1 <= index
                ? TextInputAction.done
                : TextInputAction.next,
            decoration: InputDecoration(border: InputBorder.none),
            enabled: _textFeilds[index].enable,
            onSubmitted: (text) {
              if (_textFeilds.length - 1 <= index) {
                print(" last ${_textFeilds.length} $index $text");
              } else {
                _textFeilds[index].focusNode.unfocus();
                FocusScope.of(context)
                    .requestFocus(_textFeilds[index + 1].focusNode);
              }
            },
          ),
        );
  }

  BuildFunc _buildTextQuery(String key, String label, String path) {
    final QueryPageTextFeildBean textFeildBean =
        QueryPageTextFeildBean(key, TextEditingController(), FocusNode());
    _textFeilds.add(textFeildBean);
    final int index = _textFeilds.indexOf(textFeildBean);
    //   记住，此次 的所有逻辑，是首次初始化的逻辑。
    return () => QueryRowLayoutLabel(
          label: label,
          child: QueryRowLayoutIconButton(
            iconData: _textFeilds[index].enable ? Icons.search : Icons.clear,
            child: TextField(
              autofocus: true,
              controller: _textFeilds[index].controller,
              focusNode: _textFeilds[index].focusNode,
              textInputAction: _textFeilds.length - 1 <= index
                  ? TextInputAction.done
                  : TextInputAction.next,
              decoration: InputDecoration(border: InputBorder.none),
              //内容提交(按回车)的回调
              enabled: _textFeilds[index].enable,
              onSubmitted: (text) {
                if (_textFeilds.length - 1 > index) {
                  _textFeilds[index].focusNode.unfocus();
                  FocusScope.of(context)
                      .requestFocus(_textFeilds[index + 1].focusNode);
                }
              },
            ),
            onTap: () async {
              if (!_textFeilds[index].enable) {
                rets.remove(key);
                _textFeilds[index].enable = true;
                _textFeilds[index].controller.text = "";
                FocusScope.of(context)
                    .requestFocus(_textFeilds[index].focusNode);
                return;
              }
              var d = await Navigator.of(context).pushNamed(path);
              List<Map> dd = d as List<Map>;
              if (dd != null && dd.length > 0) {
                rets[key] = dd;
                String name = "";
                dd.forEach((f) {
                  name += f["code"] + ",";
                });
                _textFeilds[index].enable = false;
                _textFeilds[index].controller.text = name;
              }
            },
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
                onPressed: () {
                  _textFeilds.forEach((f) {
                    if (!rets.containsKey(f.key)) {
                      rets[f.key] = f.controller.text;
                    }
                  });
                  Navigator.pop(context, rets);
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

  @override
  void dispose() {
    _textFeilds.forEach((f) => f.dispose());
    super.dispose();
  }
}

typedef BuildFunc = Widget Function();

class QueryPageTextFeildBean {
  final String key;
  final TextEditingController controller;

  final FocusNode focusNode;

  bool enable = true;

  QueryPageTextFeildBean(this.key, this.controller, this.focusNode);

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

class _QueryItemBuildBean {
  String key;
  String label;
  String type;
  Map data;
}

class QueryPageDataBuilder {
  static const String QUERY_ITEM_INPUT_QUERY = "text_query";
  static const String QUERY_ITEM_INPUT = "text";
  static const String QUERY_ITEM_DATE_PICKER = "date_picker";
  static const String QUERY_ITEM_QTY_RANGE = "qty_range";
  List<_QueryItemBuildBean> _vdatas = [];

  void add(String key, String label, String type, {Map data}) {
    _QueryItemBuildBean bean = _QueryItemBuildBean()
      ..key = key
      ..label = label
      ..type = type
      ..data = data;
    _vdatas.add(bean);
  }
}
