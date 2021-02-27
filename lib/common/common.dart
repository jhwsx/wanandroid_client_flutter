/// 常量类
class Constant {
  /// 返回成功的响应码
  static const int status_success = 0;

  static const String server_address = wan_android;

  static const String wan_android = "https://www.wanandroid.com/";
}

/// 加载状态类
class LoadState {
  static const int fail = -1;
  static const int loading = 0;
  static const int success = 1;
  static const int empty = 2;
}
