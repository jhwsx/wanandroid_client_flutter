import 'package:base_library/base_library.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wanandroid_client_flutter/bloc/bloc_provider.dart';
import 'package:wanandroid_client_flutter/bloc/main_bloc.dart';
import 'package:wanandroid_client_flutter/data/protocol/models.dart';
import 'package:wanandroid_client_flutter/ui/widget/refresh_scaffold.dart';
import 'package:wanandroid_client_flutter/ui/widget/tree_item.dart';
import 'package:wanandroid_client_flutter/util/utils.dart';

bool isSystemInit = true;

class SystemPage extends StatelessWidget {
  const SystemPage({Key key, this.labelId}) : super(key: key);

  final String labelId;

  @override
  Widget build(BuildContext context) {
    LogUtil.e("SystemPage build()");
    RefreshController controller = RefreshController();
    final MainBloc bloc = BlocProvider.of<MainBloc>(context);
    bloc.refreshStatusEventStream.listen((event) {
      switch (event.status) {
        case RefreshStatus.failed:
          controller.refreshFailed();
          break;
        case RefreshStatus.completed:
          controller.refreshCompleted();
          break;
        case RefreshStatus.idle:
          controller.refreshToIdle();
          break;
        default:
          break;
      }
    });

    if (isSystemInit) {
      LogUtil.d("SystemPage init");
      isSystemInit = false;
      Observable.just(1).delay(Duration(milliseconds: 500)).listen((_) {
        bloc.onRefresh(labelId: labelId);
      });
    }
    return StreamBuilder(
      stream: bloc.treeStream,
      builder: (BuildContext context, AsyncSnapshot<List<TreeModel>> snapshot) {
        return RefreshScaffold(
          labelId: labelId,
          loadStatus: Utils.getLoadStatus(snapshot.hasError, snapshot.data),
          controller: controller,
          enablePullUp: false,
          onRefresh: ({bool isReload}) {
            return bloc.onRefresh(labelId: labelId, isReload: isReload);
          },
          onLoadMore: () {},
          itemCount: snapshot.data == null ? 0 : snapshot.data.length,
          itemBuilder: (BuildContext context, int index) {
            TreeModel model = snapshot.data[index];
            return TreeItem(model);
          },
        );
      },
    );
  }
}
