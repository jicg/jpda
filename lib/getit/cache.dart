import 'package:shared_preferences/shared_preferences.dart';

class CacheKeys {
  static const String App_Url = "App_Url";
  static const String App_User = "App_User";
//  static const String App_User_Email = "App_User_Email";
//  static const String App_User_Pwd = "App_User_Pwd";
}

abstract class CacheModel {
  void setString(String key, String value);

  void setInt(String key, int value);

  void setBool(String key, bool value);

  void setDouble(String key, double value);

  void setStringList(String key, List<String> value);

  Future<dynamic> get(String key);
}

class SPCache extends CacheModel {
  Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  void setString(String key, String value) async {
    SharedPreferences _prefs = await getPrefs();
    _prefs.setString(key, value);
  }

  @override
  Future<dynamic> get(String key) async {
    SharedPreferences _prefs = await getPrefs();
    return await _prefs.get(key);
  }

  @override
  void setBool(String key, bool value) async {
    SharedPreferences _prefs = await getPrefs();
    _prefs.setBool(key, value);
  }

  @override
  void setDouble(String key, double value) async {
    SharedPreferences _prefs = await getPrefs();
    _prefs.setDouble(key, value);
  }

  @override
  void setInt(String key, int value) async {
    SharedPreferences _prefs = await getPrefs();
    _prefs.setInt(key, value);
  }

  @override
  void setStringList(String key, List<String> value) async {
    SharedPreferences _prefs = await getPrefs();
    _prefs.setStringList(key, value);
  }
}
