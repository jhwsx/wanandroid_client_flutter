import 'package:base_library/base_library.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wanandroid_client_flutter/bloc/bloc_provider.dart';
import 'package:wanandroid_client_flutter/bloc/tab_bloc.dart';
import 'package:wanandroid_client_flutter/data/protocol/models.dart';
import 'package:wanandroid_client_flutter/ui/page/tab_page.dart';
import 'package:wanandroid_client_flutter/ui/widget/web_scaffold.dart';

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
      return BlocProvider<TabBloc>(
        // 指定类型参数为 TabBloc
        child: TabPage(
          labelId: labelId,
          title: title,
          treeModel: treeModel,
        ),
        bloc: TabBloc(),
      );
    }));
  }

  static void pushWeb(BuildContext context, String title, String url) {
    if (context == null || ObjectUtil.isEmpty(url)) return;
    if (url.endsWith(".apk")) {
      launchInBrowser(url);
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return WebScaffold(
          title: title,
          url: url,
        );
      }));
    }
  }

  static void launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
