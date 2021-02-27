import 'dart:collection';

import 'package:base_library/base_library.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wanandroid_client_flutter/data/protocol/models.dart';
import 'package:wanandroid_client_flutter/data/repository/wan_repository.dart';
import 'package:wanandroid_client_flutter/event/event.dart';
import 'package:wanandroid_client_flutter/res/strings.dart';

import 'bloc_provider.dart';

/// 用于获取体系，项目，公众号的文章或者项目列表数据的 BLoC
class CommonListBloc implements BlocBase {
  /// ***** ***** ***** *****  Common List ***** ***** ***** ***** /
  BehaviorSubject<List<RepoModel>> _commonListData =
      BehaviorSubject<List<RepoModel>>();

  Sink<List<RepoModel>> get _commonListSink => _commonListData.sink;

  Stream<List<RepoModel>> get commonListStream => _commonListData.stream;

  /// ***** ***** ***** *****  Common List ***** ***** ***** ***** /
  /// ***** ***** ***** *****  Event ***** ***** ***** ***** /
  BehaviorSubject<LoadStatusEvent> _commonListLoadStatusEvent =
      BehaviorSubject<LoadStatusEvent>();

  Sink<LoadStatusEvent> get _commonListLoadStatusEventSink =>
      _commonListLoadStatusEvent.sink;

  Stream<LoadStatusEvent> get commonListLoadStatusEventStream =>
      _commonListLoadStatusEvent.asBroadcastStream();

  BehaviorSubject<RefreshStatusEvent> _commonListRefreshStatusEvent =
      BehaviorSubject<RefreshStatusEvent>();

  Sink<RefreshStatusEvent> get _commonListRefreshStatusEventSink =>
      _commonListRefreshStatusEvent.sink;

  Stream<RefreshStatusEvent> get commonListRefreshStatusEventStream =>
      _commonListRefreshStatusEvent.asBroadcastStream();

  /// ***** ***** ***** *****  Event ***** ***** ***** ***** /

  WanRepository _wanRepository = WanRepository();
  int _currentCommonListPage = 0;
  List<RepoModel> _commonList;

  @override
  Future getData({String labelId, int cid, int page}) {
    switch (labelId) {
      case Ids.titleSystemTree:
        return _getArticle(labelId, cid, page);
        break;
      default:
        return Future.delayed(Duration(seconds: 1));
        break;
    }
  }

  @override
  Future onLoadMore({String labelId, int cid}) {
    int page = 0;
    page = ++_currentCommonListPage;
    return getData(labelId: labelId, cid: cid, page: page);
  }

  @override
  Future onRefresh({String labelId, int cid}) {
    switch (labelId) {
      case Ids.titleSystemTree:
        // 从 0 开始
        _currentCommonListPage = 0;
        break;
      default:
        break;
    }
    return getData(labelId: labelId, cid: cid, page: _currentCommonListPage);
  }

  @override
  void dispose() {
    _commonListData.close();
    _commonListLoadStatusEvent.close();
    _commonListRefreshStatusEvent.close();
  }

  Future _getArticle(String labelId, int cid, int page) async {
    CommonRequest commonRequest = CommonRequest(cid);
    return _wanRepository
        .getArticleList(
            page: page, data: commonRequest.toJson() /*一定要调用 toJson() 啊*/)
        .then((list) {
      if (_commonList == null) _commonList = List();
      // 是刷新，清除一下数据列表
      if (page == 0) {
        _commonList.clear();
      }
      // 把请求到的数据添加到数据列表中
      _commonList.addAll(list);
      // 向 BLoC 发送数据
      _commonListSink.add(UnmodifiableListView<RepoModel>(_commonList));
      // 向 BLoC 发送页面状态数据, 区分是刷新还是加载更多
      if (page == 0) {
        _commonListRefreshStatusEventSink.add(RefreshStatusEvent(
            labelId,
            ObjectUtil.isEmpty(list)
                ? RefreshStatus.completed
                : RefreshStatus.idle,
            cid: cid));
      } else {
        _commonListLoadStatusEventSink.add(LoadStatusEvent(labelId,
            ObjectUtil.isEmpty(list) ? LoadStatus.noMore : LoadStatus.idle,
            cid: cid));
      }
    }).catchError((e) {
      debugPrint(e);
      // TODO Unhandled Exception: Bad state: Cannot add new events after calling close
      // https://stackoverflow.com/questions/55536461/flutter-unhandled-exception-bad-state-cannot-add-new-events-after-calling-clo
      _commonListData.sink.addError('error');
      _currentCommonListPage--;
      if (page == 0) {
        _commonListRefreshStatusEventSink
            .add(RefreshStatusEvent(labelId, RefreshStatus.failed, cid: cid));
      } else {
        _commonListLoadStatusEventSink
            .add(LoadStatusEvent(labelId, LoadStatus.failed, cid: cid));
      }
    });
  }
}
