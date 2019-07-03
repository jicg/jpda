import 'package:flutter/material.dart';
import 'package:jpda/comm/widget.dart';

class StockQueryPage extends StatefulWidget {
  @override
  _StockQueryPageState createState() => _StockQueryPageState();
}

class _StockQueryPageState extends State<StockQueryPage> {
  TextEditingController _pdtController = new TextEditingController();
  FocusNode _pdtFocusNote = new FocusNode();
  TextEditingController _storeController = new TextEditingController();
  FocusNode _storeFocusNote = new FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    _pdtController.text = "";
    _storeController.text = "";
    super.initState();
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
                  children: <Widget>[
                    RowSessionWithLabel(
                      label: "商品",
                      child: RowRightQueryIconButton(
                        child: TextField(
                          autofocus: true,
                          controller: _pdtController,
                          focusNode: _pdtFocusNote,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(border: InputBorder.none),
                          //内容提交(按回车)的回调
                          onSubmitted: (text) {
                            _pdtFocusNote.unfocus();
                            FocusScope.of(context)
                                .requestFocus(_storeFocusNote);
                          },
                        ),
                        onTap: () async {
                          print(await Navigator.of(context)
                              .pushNamed("/comm/query/product"));
                        },
                      ),
                    ),
                    RowSessionWithLabel(
                        label: "店仓",
                        child: RowRightQueryIconButton(
                          onTap: () {},
                          child: TextField(
                            autofocus: true,
                            controller: _storeController,
                            focusNode: _storeFocusNote,
                            decoration:
                                InputDecoration(border: InputBorder.none),
                            textInputAction: TextInputAction.done,
                            //内容提交(按回车)的回调
                            onSubmitted: (text) {},
                          ),
                        )),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Theme.of(context).dividerColor)),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3.0, horizontal: 10),
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 3.0, horizontal: 10),
                      child: RaisedButton(
                        onPressed: () {
                          // todo 确定
                        },
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          "确定",
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .caption
                                  .color),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}


