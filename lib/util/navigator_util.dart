import 'package:flutter/material.dart';
import 'package:wanandroid_client_flutter/bloc/bloc_provider.dart';
import 'package:wanandroid_client_flutter/bloc/tab_bloc.dart';
import 'package:wanandroid_client_flutter/data/protocol/models.dart';
import 'package:wanandroid_client_flutter/ui/page/tab_page.dart';

class NavigatorUtil {
  static void pushPage(
    BuildContext context,
    Widget page, {
    String pageName,
    bool needLogin = false,
  }) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return page;
    }));
  }

  static void pushTabPage(BuildContext context,
      {String labelId, String title, TreeModel treeModel}) {
    if (context == null) {
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      // todo BlocProvider 后面的泛型是啥意思？
      return BlocProvider<TabBloc>(
        child: TabPage(
          labelId: labelId,
          title: title,
          treeModel: treeModel,
        ),
        bloc: TabBloc(),
      );
    }));
  }
}
