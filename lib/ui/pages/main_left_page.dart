import 'dart:ui';

import 'package:base_library/base_library.dart';
import 'package:fluintl/fluintl.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid_client_flutter/res/strings.dart';
import 'package:wanandroid_client_flutter/ui/pages/settings_page.dart';
import 'package:wanandroid_client_flutter/util/navigator_util.dart';
import 'package:wanandroid_client_flutter/util/utils.dart';

import 'about_page.dart';

/// 左侧的抽屉
class MainLeftPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainLeftPageState();
  }
}

class PageInfo {
  PageInfo(this.titleId, this.iconData, this.page, [this.withScaffold = true]);

  String titleId;
  IconData iconData;
  Widget page;
  bool withScaffold;
}

class _MainLeftPageState extends State<MainLeftPage> {
  List<PageInfo> _pageInfo = List();

  @override
  void initState() {
    _pageInfo.add(PageInfo(Ids.titleSettings, Icons.settings, SettingsPage()));
    _pageInfo.add(PageInfo(Ids.titleAbout, Icons.info, AboutPage()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Scaffold(
        body: Column(
          children: <Widget>[
            DrawerHeader(
              margin: const EdgeInsets.all(0.0),
              padding: EdgeInsets.only(
                top: ScreenUtil.getInstance().statusBarHeight,
              ),
              child: Container(
                constraints: BoxConstraints.expand(),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 64.0,
                      height: 64.0,
                      margin: EdgeInsets.only(bottom: 10.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image:
                                AssetImage(Utils.getImagePath("ali_connors"))),
                      ),
                    ),
                    Text(
                      "willwaywang6",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gaps.vGap5,
                    Text(
                      "个人简介",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.all(0.0),
                  // 列表项的数量，如果为 null，则为无限列表
                  itemCount: _pageInfo.length,
                  itemBuilder: (BuildContext context, int index) {
                    PageInfo pageInfo = _pageInfo[index];
                    return ListTile(
                      leading: Icon(pageInfo.iconData),
                      title:
                          Text(IntlUtil.getString(context, pageInfo.titleId)),
                      onTap: () {
                        // if (pageInfo.titleId == Ids.titleSettings) {
                        NavigatorUtil.pushPage(context, pageInfo.page);
                        // }
                      },
                    );
                  }),
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }
}
