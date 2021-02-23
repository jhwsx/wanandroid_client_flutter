class WanAndroidApi {
  /// 体系数据 https://www.wanandroid.com/tree/json
  static const String TREE = "tree";

  static String getPath({String path: '', int page, String resType: 'json'}) {
    StringBuffer sb = StringBuffer(path);
    if (page != null) {
      sb.write('/$page');
    }
    if (resType != null && resType.isNotEmpty) {
      sb.write('/$resType');
    }
    return sb.toString();
  }
}
