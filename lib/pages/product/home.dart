import 'package:flutter/material.dart';
import 'package:jpda/comm/jpda.dart';

class ProductHome extends StatefulWidget {
  @override
  _ProductHomeState createState() => _ProductHomeState();
}

class _ProductHomeState extends State<ProductHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("商品资料")),
      body: Container(
        child: FlatButton(
            onPressed: () {
//              JPda.web.downloadProduct();
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.cloud_download,size: 80,),
                  Text("点我下载商品资料"),
                ],
              ),
            )),
      ),
    );
  }
}
