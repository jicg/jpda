import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:jpda/getit/dio.dart';
import 'package:jpda/getit/user.dart';

class JPda {
  static GetIt getIt = new GetIt();

  static initGetIt() {
    getIt.registerSingleton<UserModel>(new UserModelImplementation());
    getIt.registerSingleton<DioModel>(new DioModelIPhone());
  }

  static UserModel get user {
    return getIt<UserModel>();
  }

  static DioModel get web {
    return getIt<DioModel>();
  }
}
