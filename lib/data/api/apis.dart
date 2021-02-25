class WanAndroidApi {
  /// 体系数据 https://www.wanandroid.com/tree/json
  static const String TREE = "tree";

  /// 首页文章列表 https://www.wanandroid.com/article/list/0/json
  /// 知识体系下的文章 https://www.wanandroid.com/article/list/0/json?cid=60
  static const String ARTICLE_LIST = "article/list";

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
