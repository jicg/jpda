import 'package:flutter/material.dart';
import 'package:jpda/comm/widget.dart';
import 'package:jpda/models/query_bean.dart';

class QueryProductPage extends StatefulWidget {
  @override
  _QueryProductPageState createState() => _QueryProductPageState();
}

class _QueryProductPageState extends State<QueryProductPage> {
  List<QueryBean> datas = [];

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
              child: TextField(
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: (t) {},
                decoration:
                    InputDecoration(border: InputBorder.none, hintText: "查询商品"),
              )),
          Expanded(child: _buildQueryData()),
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
    return ListView.separated(
        itemBuilder: (context, i) {
          return new ListTile(
            title: Text("测试 $i"),
          );
        },
        separatorBuilder: (context, i) {
          return new Divider();
        },
        itemCount: 5);
  }
}
