import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jpda/comm/func.dart';
import 'package:jpda/comm/jpda.dart';
import 'package:dio/dio.dart';
import 'package:jpda/models/user.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  String _name = "";

  String _password;

  void _forSubmitted(BuildContext context) async {
    var _form = _formKey.currentState;
    if (!JPda.web.hasBaseUrl) {
      Navigator.pushNamed(context, "/baseurl");
      UIUtils.toaskError("请设置地址！");
      return;
    }

    if (_form.validate()) {
      _form.save();
      UIUtils.showDialogWait(context, title: "登录中。。。");
      try {
        Response<Map> da = await JPda.web.login(_name, _password);
        JPda.user.login = new User(da.data["name"], _name, _password);
        UIUtils.toaskSuccess("登录成功");
        Navigator.pop(context);
        Navigator.pop(context);
      } catch (err) {
        Navigator.pop(context);
        UIUtils.toaskError(err.toString());
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('登陆'),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            _forSubmitted(context);
          },
          child: new Text('登陆'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.all(16.0),
                  child: new Form(
                    key: _formKey,
                    child: new Column(
                      children: <Widget>[
                        new TextFormField(
                          decoration: new InputDecoration(
                            labelText: '邮箱',
                          ),
                          autofocus: true,
                          initialValue: JPda.user.user?.email,
                          onSaved: (val) {
                            _name = val;
                          },
                        ),
                        new TextFormField(
                          decoration: new InputDecoration(
                            labelText: '密码',
                          ),
                          obscureText: true,
                          validator: (val) {
                            return val.length < 4 ? "密码长度错误" : null;
                          },
                          onSaved: (val) {
                            _password = val;
                          },
                        ),
                      ],
                    ),
                  )),
              Container(
                padding: EdgeInsets.only(top: 8.0, right: 20),
                child: Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, "/baseurl");
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          new Text("${JPda.web.baseUrl}"),
                          new Text(" >> 点我修改"),
                        ],
                      ),
                    )),
              ),
            ],
          ),
        ));
  }

//  Widget _buildUrlDialog(BuildContext context) {
//    return new SimpleDialog(
//      children: <Widget>[new Text("dsafdasdf")],
//    );
//  }
}
