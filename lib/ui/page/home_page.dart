import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:fluintl/fluintl.dart';
import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wanandroid_client_flutter/bloc/bloc_provider.dart';
import 'package:wanandroid_client_flutter/bloc/main_bloc.dart';
import 'package:wanandroid_client_flutter/data/protocol/models.dart';
import 'package:wanandroid_client_flutter/res/strings.dart';
import 'package:wanandroid_client_flutter/ui/widget/article_item.dart';
import 'package:wanandroid_client_flutter/ui/widget/refresh_scaffold.dart';
import 'package:wanandroid_client_flutter/ui/widget/widgets.dart';
import 'package:wanandroid_client_flutter/util/navigator_util.dart';
import 'package:wanandroid_client_flutter/util/utils.dart';

class HomePage extends StatelessWidget {
  HomePage({Key key, this.labelId}) : super(key: key);

  final String labelId;

  bool _isHomeInit = true;

  @override
  Widget build(BuildContext context) {
    LogUtil.d("HomePage build");
    RefreshController _refreshController = RefreshController();
    final MainBloc bloc = BlocProvider.of<MainBloc>(context);

    bloc.loadStatusEventStream.listen((event) {
      switch (event.status) {
        case LoadStatus.noMore:
          _refreshController.loadNoData();
          break;
        case LoadStatus.failed:
          _refreshController.loadFailed();
          break;
        case LoadStatus.idle:
          _refreshController.loadComplete();
          break;
        default:
          break;
      }
    });
    bloc.refreshStatusEventStream.listen((event) {
      switch (event.status) {
        case RefreshStatus.completed:
          _refreshController.refreshCompleted();
          break;
        case RefreshStatus.idle:
          _refreshController.refreshToIdle();
          break;
        case RefreshStatus.failed:
          _refreshController.refreshFailed();
          break;
        default:
          break;
      }
    });
    if (_isHomeInit) {
      LogUtil.d("SystemPage init");
      _isHomeInit = false;
      Observable.just(1).delay(Duration(milliseconds: 500)).listen((_) {
        bloc.onRefresh(labelId: labelId);
      });
    }

    return Container(
      color: Colors.grey,
      alignment: Alignment.center,
      child: StreamBuilder(
          stream: bloc.homeArticleStream,
          builder:
              (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            return RefreshScaffold(
              labelId: labelId,
              loadStatus: Utils.getLoadStatus(snapshot.hasError, snapshot.data),
              controller: _refreshController,
              enablePullUp: true,
              onRefresh: ({bool isReload}) {
                return bloc.onRefresh(labelId: labelId);
              },
              onLoadMore: () {
                return bloc.onLoadMore(labelId: labelId);
              },
              itemCount: snapshot.data == null ? 0 : snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  var banners = snapshot.data[0] as List<BannerModel>;
                  return _buildBanner(context, banners);
                  return Text("Banner");
                } else {
                  var repoModel = snapshot.data[index] as RepoModel;
                  return ArticleItem(
                    repoModel,
                    isHome: true,
                  );
                }
              },
            );
          }),
    );
  }

  Widget _buildBanner(BuildContext context, List<BannerModel> banners) {
    return AspectRatio(
      aspectRatio: 16.0 / 9.0,
      child: Swiper(
        indicatorAlignment: AlignmentDirectional.topEnd,
        indicator: DotSwiperIndicator(),
        circular: true,
        interval: const Duration(seconds: 5),
        children: banners.map((model) {
          return InkWell(
            onTap: () {
              NavigatorUtil.pushWeb(context, model.title, model.url);
            },
            child: Stack(
              children: <Widget>[
                CachedNetworkImage(
                  fit: BoxFit.fill,
                  imageUrl: model.imagePath,
                  placeholder: (BuildContext context, String url) {
                    return ProgressView();
                  },
                  errorWidget:
                      (BuildContext context, String url, Object error) {
                    return Icon(Icons.error);
                  },
                ),
                Positioned(
                  bottom: 0.0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black26),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          model.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class DotSwiperIndicator extends SwiperIndicator {
  @override
  Widget build(BuildContext context, int index, int itemCount) {
    var list = List<Widget>();
    for (var i = 0; i < itemCount; ++i) {
      if (i > 0)
      list.add(SizedBox(width: 4.0,));
      list.add(ClipOval(
        child: Container(
          width: 8.0,
          height: 8.0,
          color: i == index ? Colors.black45 : Colors.white,
        ),
      ));
    }
    return Container(
      margin: EdgeInsets.only(top: 10.0, right: 5.0),
      decoration: BoxDecoration(
          color: Colors.black26, borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: list,
        ),
      ),
    );
  }
}
