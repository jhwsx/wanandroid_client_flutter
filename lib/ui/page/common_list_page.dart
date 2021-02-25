import 'package:base_library/base_library.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wanandroid_client_flutter/bloc/bloc_provider.dart';
import 'package:wanandroid_client_flutter/bloc/common_list_bloc.dart';
import 'package:wanandroid_client_flutter/common/common.dart';
import 'package:wanandroid_client_flutter/data/protocol/models.dart';
import 'package:wanandroid_client_flutter/ui/widget/article_item.dart';
import 'package:wanandroid_client_flutter/ui/widget/refresh_scaffold.dart';
import 'package:wanandroid_client_flutter/util/utils.dart';

class CommonListPage extends StatelessWidget {
  const CommonListPage({Key key, this.labelId, this.cid}) : super(key: key);

  final String labelId;
  final int cid;

  @override
  Widget build(BuildContext context) {
    LogUtil.e("CommonListPage build()");
    RefreshController controller = RefreshController();
    final CommonListBloc bloc = BlocProvider.of<CommonListBloc>(context);
    // TODO 这是什么意思啊？
    bloc.commonListEventStream.listen((event) {
      if (cid == event.cid) {
        controller.sendBack(false, event.status);
      }
    });
    return StreamBuilder(
        stream: bloc.commonListStream,
        builder:
            (BuildContext context, AsyncSnapshot<List<RepoModel>> snapshot) {
          int loadStatus =
              Utils.getLoadStatus(snapshot.hasError, snapshot.data);
          if (loadStatus == LoadStatus.loading) {
            bloc.onRefresh(labelId: labelId, cid: cid);
          }
          return RefreshScaffold(
            labelId: cid.toString(),
            loadStatus: Utils.getLoadStatus(snapshot.hasError, snapshot.data),
            controller: controller,
            enablePullUp: true,
            onRefresh: ({bool isReload}) {
              return bloc.onRefresh(labelId: labelId, cid: cid);
            },
            onLoadMore: (bool up) {
              return bloc.onLoadMore(labelId: labelId, cid: cid);
            },
            itemCount: snapshot.data == null ? 0 : snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              RepoModel repoModel = snapshot.data[index];
              return ArticleItem(
                repoModel,
                isHome: false,
              );
            },
          );
        });
  }
}
