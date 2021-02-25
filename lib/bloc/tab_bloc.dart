import 'dart:collection';

import 'package:rxdart/rxdart.dart';
import 'package:wanandroid_client_flutter/data/protocol/models.dart';
import 'package:wanandroid_client_flutter/res/strings.dart';

import 'bloc_provider.dart';
import 'package:rxdart/subjects.dart';

/// 用于获取 tab 数据的 BLoC
/// 知识体系的 tab
/// 项目的 tab
/// 公众号的 tab
class TabBloc implements BlocBase {
  BehaviorSubject<List<TreeModel>> _tabTree =
      BehaviorSubject<List<TreeModel>>();

  Sink<List<TreeModel>> get _tabTreeSink => _tabTree.sink;

  Stream<List<TreeModel>> get tabTreeStream => _tabTree.stream;

  List<TreeModel> _treeList;

  @override
  Future getData({String labelId, int page}) {
    switch (labelId) {
      case Ids.titleSystemTree:
        return getSystemTree(labelId);
      default:
        return Future.delayed(Duration(seconds: 1));
        break;
    }
  }

  @override
  Future onLoadMore({String labelId}) {
    // 不需要这个方法
    return null;
  }

  @override
  Future onRefresh({String labelId}) {
    return getData(labelId: labelId);
  }

  // 绑定知识体系的二级分类 tab 数据，不需要再去请求了
  void bindSystemData(TreeModel model) {
    if (model != null) {
      _treeList = model.children;
    }
  }

  Future getSystemTree(String labelId) {
    return Future.delayed(Duration(milliseconds: 500)).then((_) {
      _tabTreeSink.add(UnmodifiableListView(_treeList));
    });
  }

  @override
  void dispose() {
    _tabTree.close();
  }
}
