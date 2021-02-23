import 'package:base_library/base_library.dart';
import 'package:wanandroid_client_flutter/common/common.dart';
import 'package:wanandroid_client_flutter/data/api/apis.dart';
import 'package:wanandroid_client_flutter/data/protocol/models.dart';

class WanRepository {
  // 在函数体前加上 async 关键字，表示在定义一个异步函数
  Future<List<TreeModel>> getTree() async {
    // 使用 await 关键字来得到异步表达式的 completed 结果
    BaseResp<List> baseResp = await DioUtil().request<List>(
        Method.get, WanAndroidApi.getPath(path: WanAndroidApi.TREE));
    List<TreeModel> treeList;
    if (baseResp.code != Constant.status_success) {
      return Future.error(baseResp.msg);
    }
    if (baseResp.data != null) {
      treeList = baseResp.data.map((value) {
        return TreeModel.fromJson(value);
      }).toList();
    }
    return treeList;
  }
}
