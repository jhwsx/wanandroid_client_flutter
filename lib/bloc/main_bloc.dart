import 'dart:collection';

import 'package:base_library/base_library.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/subjects.dart';
import 'package:wanandroid_client_flutter/bloc/bloc_provider.dart';
import 'package:wanandroid_client_flutter/data/protocol/models.dart';
import 'package:wanandroid_client_flutter/data/repository/wan_repository.dart';
import 'package:wanandroid_client_flutter/event/event.dart';
import 'package:wanandroid_client_flutter/res/strings.dart';

class MainBloc implements BlocBase {
  /// ***** ***** ***** *****  System ***** ***** ***** ***** /
  BehaviorSubject<List<TreeModel>> _tree = BehaviorSubject<List<TreeModel>>();

  Sink<List<TreeModel>> get _treeSink => _tree.sink;

  Stream<List<TreeModel>> get treeStream => _tree.stream;

  List<TreeModel> _treeList;

  /// ***** ***** ***** *****  System ***** ***** ***** ***** /

  /// ***** ***** ***** *****  Event ***** ***** ***** ***** /
  BehaviorSubject<RefreshStatusEvent> _refreshStatusEvent =
      BehaviorSubject<RefreshStatusEvent>();

  Sink<RefreshStatusEvent> get _refreshStatusEventSink =>
      _refreshStatusEvent.sink;

  // asBroadcastStream 转换为多订阅流
  Stream<RefreshStatusEvent> get refreshStatusEventStream =>
      _refreshStatusEvent.stream.asBroadcastStream();

  /// ***** ***** ***** *****  Event ***** ***** ***** ***** /
  WanRepository _wanRepository = WanRepository();

  @override
  void dispose() {
    _tree.close();
    _refreshStatusEvent.close();
  }

  @override
  Future getData({String labelId, int page}) {
    switch (labelId) {
      case Ids.titleSystem:
        return getTree(labelId);
        break;
      default:
        return Future.delayed(Duration(seconds: 1));
        break;
    }
  }

  @override
  Future onLoadMore({String labelId}) {
    int _page = 0;
    switch (labelId) {
      case Ids.titleSystem:
        break;
      default:
        break;
    }
    LogUtil.d("onLoadMore labelId: $labelId, _page: $_page");
    return getData(labelId: labelId, page: _page);
  }

  @override
  Future onRefresh({String labelId, bool isReload}) {
    switch (labelId) {
      case Ids.titleSystem:
        break;
      default:
        break;
    }
    LogUtil.d("onRefresh labelId: $labelId");
    return getData(labelId: labelId, page: 0);
  }

  Future getTree(String labelId) {
    return _wanRepository.getTree().then((list) {
      if (_treeList == null) {
        _treeList = List<TreeModel>();
      }
      _treeList.clear();
      _treeList.addAll(list);
      // 向 BLoC 发送数据
      _treeSink.add(UnmodifiableListView<TreeModel>(_treeList));
      // 向 BLoC 发送页面状态数据
      _refreshStatusEventSink.add(RefreshStatusEvent(
          labelId,
          ObjectUtil.isEmpty(list)
              ? RefreshStatus.completed
              : RefreshStatus.idle));
    }).catchError((_) {
      _tree.sink.addError('error');
      _refreshStatusEventSink
          .add(RefreshStatusEvent(labelId, RefreshStatus.failed));
    });
  }
}
