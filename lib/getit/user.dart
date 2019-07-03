import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:jpda/comm/jpda.dart';
import 'package:jpda/getit/cache.dart';
import 'package:jpda/models/user.dart';

abstract class UserModel extends ChangeNotifier {
  set init(User user);

  set login(User user);

  User get user;

  bool get isLogin;
}

class UserModelImplementation extends UserModel {
  User _user;
  bool _islogin =false;

  @override
  set login(User user) {
    this._user = user ?? this._user;
    _islogin = true;
    JPda.cache
        .setString(CacheKeys.App_User, json.encode(user.toJson()));
    this.notifyListeners();
  }

  @override
  User get user => this._user;

  @override
  bool get isLogin => _islogin;

  @override
  set init(User user) {
    if (user != null) {
      this._user = user ?? this._user;
      this.notifyListeners();
    }
  }
}
