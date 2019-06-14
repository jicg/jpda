class User {
  String _name = "";
  String _email = "";
  String _url = "";
  String _pwd = "";

  User(this._name, this._email, this._url, this._pwd);

  String get pwd => _pwd;

  set pwd(String value) {
    _pwd = value;
  }

  String get url => _url;

  set url(String value) {
    _url = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }
}
