import 'dart:collection';

import 'package:base_library/base_library.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';
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
  BehaviorSubject<LoadStatusEvent> _loadStatusEvent =
      BehaviorSubject<LoadStatusEvent>();

  Sink<LoadStatusEvent> get _loadStatusEventSink => _loadStatusEvent.sink;

  Stream<LoadStatusEvent> get loadStatusEventStream =>
      _loadStatusEvent.asBroadcastStream();

  BehaviorSubject<RefreshStatusEvent> _refreshStatusEvent =
      BehaviorSubject<RefreshStatusEvent>();

  Sink<RefreshStatusEvent> get _refreshStatusEventSink =>
      _refreshStatusEvent.sink;

  // asBroadcastStream 转换为多订阅流
  Stream<RefreshStatusEvent> get refreshStatusEventStream =>
      _refreshStatusEvent.stream.asBroadcastStream();

  /// ***** ***** ***** *****  Event ***** ***** ***** ***** /

  /// ***** ***** ***** *****  Home ***** ***** ***** ***** /
  BehaviorSubject<List<dynamic>> _homeArticle =
      BehaviorSubject<List<dynamic>>();

  Sink<List<dynamic>> get _homeArticleSink => _homeArticle.sink;

  Stream<List<dynamic>> get homeArticleStream => _homeArticle.stream;

  int _homeArticlePage = 0;

  List<dynamic> _homeArticleList;

  // BehaviorSubject<List<BannerModel>> _homeBanner =
  //     BehaviorSubject<List<BannerModel>>();
  //
  // Sink<List<BannerModel>> get _homeBannerSink => _homeBanner.sink;
  //
  // Stream<List<BannerModel>> get homeBannerStream => _homeBanner.stream;

  /// ***** ***** ***** *****  Home ***** ***** ***** ***** /

  WanRepository _wanRepository = WanRepository();

  @override
  void dispose() {
    _tree.close();
    _refreshStatusEvent.close();
    _homeArticle.close();
    // _homeBanner.close();
    _loadStatusEvent.close();
  }

  @override
  Future getData({String labelId, int page}) {
    switch (labelId) {
      case Ids.titleSystem:
        return getTree(labelId);
        break;
      case Ids.titleHome:
        return getHome(labelId, page);
      default:
        return Future.delayed(Duration(seconds: 1));
        break;
    }
  }

  @override
  Future onLoadMore({String labelId, int page}) {
    int _page = 0;
    switch (labelId) {
      case Ids.titleSystem:
        // 没有 LoadMore
        break;
      case Ids.titleHome:
        _page = ++_homeArticlePage;
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
      case Ids.titleHome:
        _homeArticlePage = 0;
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

  Future getHome(String labelId, int page) {
    if (page == 0) {
      return Future.wait({
        _wanRepository.getBannerList(),
        _wanRepository.getArticleList(page: page)
      }).then((results) {
        debugPrint('MainBloc, getHome: ${results[0]}, ${results[1]}');
        // 两个数据都获取到了
        // 设置刷新状态
        if (ObjectUtil.isEmpty(results[0]) || ObjectUtil.isEmpty(results[1])) {
          _refreshStatusEvent
              .add(RefreshStatusEvent(labelId, RefreshStatus.completed));
        } else {
          _refreshStatusEvent
              .add(RefreshStatusEvent(labelId, RefreshStatus.idle));
          var bannerList = results[0] as List<BannerModel>;
          var articleList = results[1] as List<RepoModel>;
          if (_homeArticleList == null) _homeArticleList = List<dynamic>();
          _homeArticleList.clear();
          _homeArticleList.add(bannerList);
          _homeArticleList.addAll(articleList);
          _homeArticleSink.add(UnmodifiableListView<dynamic>(_homeArticleList));
          // _homeBannerSink.add(UnmodifiableListView<BannerModel>(bannerList));
        }
      }).catchError((e) {
        debugPrint('MainBloc, getHome: $e');
        // _homeBanner.sink.addError('error');
        _homeArticle.sink.addError('error');
        _refreshStatusEvent
            .add(RefreshStatusEvent(labelId, RefreshStatus.failed));
      });
    } else {
      return _getHomeArticleLoadMore(labelId: labelId, page: page);
    }
  }

  Future _getHomeArticleLoadMore({String labelId, int page}) async {
    return _wanRepository.getArticleList(page: page).then((list) {
      if (_homeArticleList == null) _homeArticleList = List<RepoModel>();
      _homeArticleList.addAll(list);
      _homeArticleSink.add(UnmodifiableListView(_homeArticleList));
      _loadStatusEventSink.add(LoadStatusEvent(labelId,
          ObjectUtil.isEmpty(list) ? LoadStatus.noMore : LoadStatus.idle));
    }).catchError((e) {
      _homeArticlePage--;
      _loadStatusEventSink.add(LoadStatusEvent(labelId, LoadStatus.failed));
    });
  }
}
