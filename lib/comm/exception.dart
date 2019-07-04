class WebException implements Exception {
  final message;

  WebException(this.message);

  String toString() {
    if (message == null) return "网络异常: 未知错误！";
    return "$message";
  }
}

class NotLoginException implements Exception {
  String toString() {
    return "请先登录";
  }
}
