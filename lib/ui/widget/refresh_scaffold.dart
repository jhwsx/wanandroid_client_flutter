import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'widgets.dart';

typedef OnLoadMore = void Function(bool up);
typedef OnRefreshCallback = Future<void> Function({bool isReload});

class RefreshScaffold extends StatefulWidget {
  const RefreshScaffold(
      {Key key,
      this.labelId,
      this.loadStatus,
      @required this.controller,
      this.enablePullUp = true,
      this.onRefresh,
      this.onLoadMore,
      this.itemCount,
      this.itemBuilder,
      this.child})
      : super(key: key);

  final String labelId;

  /// 加载状态
  final int loadStatus;
  final RefreshController controller;
  final bool enablePullUp;

  final OnRefreshCallback onRefresh;
  final OnLoadMore onLoadMore;
  final Widget child;
  final int itemCount;

  /// 列表项的构建器
  final IndexedWidgetBuilder itemBuilder;

  @override
  _RefreshScaffoldState createState() => _RefreshScaffoldState();
}

class _RefreshScaffoldState extends State<RefreshScaffold>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    // 必须调用 super.build(context);
    super.build(context);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          RefreshIndicator(
            child: SmartRefresher(
                controller: widget.controller,
                enablePullDown: false,
                enablePullUp: widget.enablePullUp,
                enableOverScroll: false,
                onRefresh: widget.onLoadMore,
                child: widget.child ??
                    ListView.builder(
                      itemBuilder: widget.itemBuilder,
                      itemCount: widget.itemCount,
                    )),
            onRefresh: widget.onRefresh,
          ),
          // 加载状态的布局
          StatusViews(
            widget.loadStatus,
            onTap: () {
              widget.onRefresh(isReload: true);
            },
          ),
        ],
      ),
    );
  }

  // 必须重写的函数
  @override
  bool get wantKeepAlive => true;
}
