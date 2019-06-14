import 'package:flutter/widgets.dart';
import 'package:jpda/models/user.dart';

abstract class UserModel extends ChangeNotifier {
  set login(User user);

  User get user;

  bool get isLogin;
}

class UserModelImplementation extends UserModel {
  User _user;

  @override
   set login(User user) {
    this._user = user ?? this._user;
    this.notifyListeners();
  }

  @override
  User get user => this._user;

  @override
  // TODO: implement isLogin
  bool get isLogin => this._user != null && this._user.email.isNotEmpty;
}
