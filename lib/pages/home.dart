import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jpda/comm/func.dart';
import 'package:jpda/comm/jpda.dart';
import 'package:jpda/comm/widget.dart';
import 'package:jpda/getit/cache.dart';
import 'package:jpda/models/user.dart';
import 'package:permission_handler/permission_handler.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _loading = true;

  @override
  void initState() {
    initPerms();

    loadData();

    super.initState();
  }

  void loadData() async {
    try {
      JPda.web.baseUrl = await JPda.cache.get(CacheKeys.App_Url);
      String str = await JPda.cache.get(CacheKeys.App_User);
      Map<String, dynamic> user = json.decode(str);
      JPda.user.init = User.fromJson(user);
      if ((JPda.user.user?.email ?? "").isNotEmpty) {
        await JPda.web.login(JPda.user.user.email, JPda.user.user.pwd);
        JPda.user.login = JPda.user.user;
      }
    } catch (e) {
      UIUtils.ToaskError("$e");
    } finally {
      setState(() {
        _loading = false;
      });
    }
    JPda.user.addListener(update);
  }

  @override
  void dispose() {
    JPda.user.removeListener(update);
    super.dispose();
  }

  update() => setState(() => print('update user'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("采集器"),
        centerTitle: true,
      ),
      body: LoadingWidget(
        loading: _loading,
        child:
            !JPda.user.isLogin ? _buildNoLogin(context) : _buildMain(context),
      ),
      drawer: !JPda.user.isLogin ? null : _buildDrawer(context),
    );
  }

  Widget _buildMain(BuildContext context) {
    return Container(
      child: GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        children: <Widget>[
          _buildCell("images/pandian.png", "盘点", () {}),
//          _buildCell("images/in.png", "入库", () {}),
//          _buildCell("images/out.png", "出库", () {}),
//          _buildCell("images/product.png", "商品管理", () {
//            Navigator.of(context).pushNamed("/product/home");
//          }),
          _buildCell("images/stock.png", "库存查询", () {
            Navigator.of(context).pushNamed("/stock/home");
          }),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: UserAccountsDrawerHeader(
                  accountName: Text("${JPda.user.user.name}"),
                  accountEmail: Text("${JPda.user.user.email}"),
                ),
              )
            ],
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("设置"),
            onTap: () => {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text("关于"),
            onTap: () => {
                  showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) {
                        return new SimpleDialog(
                          contentPadding: EdgeInsets.all(16),
                          title: Text("关于"),
                          children: <Widget>[
                            Container(child: Text("版本：beta版")),
                            Container(child: Text("功能：Pda采集器")),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("退出"),
                                )
                              ],
                            )
                          ],
                        );
                      })
                },
          ),
          Divider(),
          ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("重新登陆"),
              onTap: () async {
                final result = await Navigator.pushNamed(context, "/login");
              }),
          Divider(),
        ],
      ),
    );
  }

  Widget _buildNoLogin(BuildContext context) {
    return Container(
        child: Center(
      child: RaisedButton(
        onPressed: () {
          Navigator.pushNamed(context, "/login");
        },
        child: Text("请先登陆 ,-> 点我哦！"),
      ),
    ));
  }

  Widget _buildCell(String imgurl, String text, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              imgurl,
              fit: BoxFit.cover,
              width: 60.0,
              height: 60.0,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              text,
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }

  Future initPerms() async {
    Map<PermissionGroup, PermissionStatus> perms =
        await PermUtils.requestPermissionList([
      PermissionGroup.storage,
      PermissionGroup.camera,
      PermissionGroup.phone
    ]);
    perms.forEach((key, value) async {
      if (value != PermissionStatus.granted) {
        await UIUtils.jpdaShowMessageDialog(context,
            barrierDismissible: false,
            title: "权限不足",
            desc: "程序即将退出",
            onTap: () => exit(0),
            onWillPop: () => new Future.value(false),
            actions: [
              FlatButton(
                child: Text("系统权限"),
                onPressed: () async {
                  if (!await PermUtils.openAppSettings()) {
                    UIUtils.ToaskError("系统应用权限，打开失败");
                  }
                },
              )
            ]);
      }
    });
  }
}
