import 'package:test/test.dart';
import 'package:wanandroid_client_flutter/data/protocol/models.dart';
import 'dart:convert' as json;

void main() {
  test("parse_banner.json", () {
    const jsonString =
        """{"desc":"扔物线","id":29,"imagePath":"https://wanandroid.com/blogimgs/04d6f53b-65e8-4eda-89c0-5981e8688576.png","isVisible":1,"order":0,"title":"我用 Jetpack Compose 写了个春节版微信主题，带炸弹特效","type":0,"url":"http://i0k.cn/4KryA"}""";

    expect(parseBanner(jsonString).desc, "扔物线");
  });
}

BannerModel parseBanner(String jsonStr) {
  final parsed = json.jsonDecode(jsonStr);
  return BannerModel.fromJson(parsed);
}
