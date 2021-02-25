import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wanandroid_client_flutter/bloc/bloc_provider.dart';
import 'package:wanandroid_client_flutter/bloc/common_list_bloc.dart';
import 'package:wanandroid_client_flutter/bloc/tab_bloc.dart';
import 'package:wanandroid_client_flutter/data/protocol/models.dart';
import 'package:wanandroid_client_flutter/ui/widget/widgets.dart';

import 'common_list_page.dart';

class TabPage extends StatefulWidget {
  const TabPage({Key key, this.labelId, this.title, this.treeModel})
      : super(key: key);

  final String labelId;
  final String title;
  final TreeModel treeModel;

  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  @override
  Widget build(BuildContext context) {
    final TabBloc bloc = BlocProvider.of<TabBloc>(context);
    bloc.bindSystemData(widget.treeModel);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: StreamBuilder(
          stream: bloc.tabTreeStream,
          builder:
              (BuildContext context, AsyncSnapshot<List<TreeModel>> snapshot) {
            if (snapshot.data == null) {
              Observable.just(1).delay(Duration(milliseconds: 500)).listen((_) {
                bloc.getData(labelId: widget.labelId);
              });
              return ProgressView();
            }
            return DefaultTabController(
                length: snapshot.data == null ? 0 : snapshot.data.length,
                child: Column(
                  children: <Widget>[
                    Material(
                      color: Theme.of(context).primaryColor,
                      child: ConstrainedBox(
                        // 强制 child 的宽度占满屏幕
                        constraints: BoxConstraints(minWidth: double.infinity),
                        child: TabBar(
                          isScrollable: true,
                          indicatorSize: TabBarIndicatorSize.label,
                          tabs: snapshot.data
                              ?.map((TreeModel model) => Tab(
                                    text: model.name,
                                  ))
                              ?.toList(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: snapshot.data
                            .map((TreeModel model) => BlocProvider(
                                  // 添加列表页面
                                  child: CommonListPage(
                                      labelId: widget.labelId, cid: model.id),
                                  bloc: CommonListBloc(),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ));
          }),
    );
  }
}
