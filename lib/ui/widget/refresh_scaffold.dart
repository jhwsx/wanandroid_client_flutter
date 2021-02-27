import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'widgets.dart';

typedef OnLoadMore = void Function();
typedef OnRefreshCallback = Future<void> Function({bool isReload});

/// 带刷新，上拉加载，状态页面的脚手架
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
          SmartRefresher(
              enablePullDown: true,
              enablePullUp: widget.enablePullUp,
              controller: widget.controller,
              onRefresh: widget.onRefresh,
              onLoading: widget.onLoadMore,
              header: MaterialClassicHeader(),
              footer: CustomFooter(
                  builder: (BuildContext context, LoadStatus mode) {
                Widget body;
                if (mode == LoadStatus.idle) {
                  body = Text("pull up load");
                } else if (mode == LoadStatus.loading) {
                  body = CupertinoActivityIndicator();
                } else if (mode == LoadStatus.failed) {
                  body = Text("Load Failed!Click retry!");
                } else if (mode == LoadStatus.canLoading) {
                  body = Text("release to load more");
                } else {
                  body = Text("No more Data");
                }
                return Container(
                  height: 55.0,
                  child: Center(
                    child: body,
                  ),
                );
              }),
              child: widget.child ??
                  ListView.builder(
                    itemBuilder: widget.itemBuilder,
                    itemCount: widget.itemCount,
                  )),
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
