import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jpda/comm/jpda.dart';

class BaseUrlPage extends StatefulWidget {
  Map<String, String> arguments;

  BaseUrlPage(this.arguments);

  @override
  _BaseUrlPageState createState() => _BaseUrlPageState();
}

class _BaseUrlPageState extends State<BaseUrlPage> {
  TextEditingController _userEtController = TextEditingController();
  String errmsg = "";
  String _prex = "http://";
  String _prex1 = "http://";
  String _prex2 = "https://";
  bool _flag = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置地址"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.cached,
                  color: Colors.grey,
                ),
              ),
              onTap: () {
                setState(() {
                  _flag = !_flag;
                  _prex = _flag ? _prex1 : _prex2;
                });
              },
            ),
            Expanded(
              child: TextField(
                controller: _userEtController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                    labelText: "输入地址", prefixText: _prex, errorText: errmsg),
                autofocus: true,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String url = _prex + _userEtController.text;
          print(url);

          JPda.web.baseUrl = url.trim();
          print(JPda.web.hasBaseUrl);
          Navigator.of(context).pop();
//          if (!JPda.user.isLogin) {
//            Navigator.pushReplacementNamed(context, '/login');
//            return;
//          }

//
//          String nextpage = this.widget.arguments == null
//              ? ""
//              : (this.widget.arguments["nextpage"] ?? "");
//          if (nextpage.isNotEmpty) {
//            Navigator.pushReplacementNamed(context, nextpage);
//          } else {
//            Navigator.pop(context);
//          }
        },
        child: Text("保存"),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    String url = JPda.web.baseUrl;
    if (url != null) {
      if (url.startsWith(_prex1)) {
        url = url.replaceFirst(_prex1, "");
        _flag = true;
      } else if (url.startsWith(_prex2)) {
        url = url.replaceFirst(_prex2, "");
        _flag = false;
      }
      _userEtController.text = url;
      setState(() {});
    }
  }
}
