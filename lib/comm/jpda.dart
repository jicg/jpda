import 'package:get_it/get_it.dart';
import 'package:jpda/getit/cache.dart';
import 'package:jpda/getit/database.dart';
import 'package:jpda/getit/dio.dart';
import 'package:jpda/getit/play.dart';
import 'package:jpda/getit/user.dart';
import 'package:jpda/models/user.dart';

class JPda {
  static GetIt getIt = new GetIt();

  static initGetIt() {
    getIt.registerSingleton<CacheModel>(new SPCache());
    DioModelIPhone dioModel = new DioModelIPhone();
//    JPda.cache.get(CacheKeys.App_Url).then((v) {
//      print(v);
//      print("http://".compareTo(v));
//      dioModel.baseUrl = v;
//    });

    UserModel userModel = new UserModelImplementation();
//    JPda.cache.get(CacheKeys.App_User).then((v) {
//      String str = v;
//      Map<String, dynamic> user = json.decode(str);
//      userModel.init = User.fromJson(user);
//    });
    dioModel.baseUrl = "http://192.168.0.160";
    userModel.init = new User("root", "nea@burgeon.com.cn", "bos20");
    getIt.registerSingleton<DioModel>(dioModel);
    getIt.registerSingleton<UserModel>(userModel);
    getIt.registerSingleton<DataBaseModel>(new DataBaseModelImpl());
    getIt.registerSingleton<PlayModel>(new PlayModelImpl());
  }

  static UserModel get user {
    return getIt<UserModel>();
  }

  static CacheModel get cache {
    return getIt<CacheModel>();
  }

  static DioModel get web {
    return getIt<DioModel>();
  }

  static PlayModel get play {
    return getIt<PlayModel>();
  }
}
