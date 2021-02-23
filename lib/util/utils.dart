import 'package:wanandroid_client_flutter/common/common.dart';

class Utils {
  static String getImagePath(String name, {String format = '.png'}) {
    return "assets/images/$name$format";
  }

  /// 获取加载状态
  static int getLoadStatus(bool hasError, List data) {
    if (hasError) {
      return LoadStatus.fail;
    }
    if (data == null) {
      return LoadStatus.loading;
    } else if (data.isEmpty) {
      return LoadStatus.empty;
    } else {
      return LoadStatus.success;
    }
  }
}
