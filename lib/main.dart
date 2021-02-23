import 'package:base_library/base_library.dart';
import 'package:dio/dio.dart';
import 'package:fluintl/fluintl.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid_client_flutter/bloc/bloc_provider.dart';
import 'package:wanandroid_client_flutter/common/common.dart';
import 'package:wanandroid_client_flutter/res/strings.dart';
import 'package:wanandroid_client_flutter/ui/page/main_page.dart';

import 'bloc/main_bloc.dart';
import 'common/global.dart';

void main() {
  Global.init(() {
    runApp(BlocProvider(child: MyApp(), bloc: MainBloc()));
  });
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    setLocalizedValues(localizedValues);
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: [
        CustomLocalizations.delegate,
      ],
      home: MainPage(),
    );
  }

  void init() {
    _init();
  }

  void _init() {
    DioUtil.openDebug();
    Options options = DioUtil.getDefOptions();
    // 配置 base url
    options.baseUrl = Constant.server_address;
    // 获取并配置 cookie
    String cookie = SpUtil.getString(BaseConstant.keyAppToken);
    if (ObjectUtil.isNotEmpty(cookie)) {
      Map<String, dynamic> headers = new Map();
      headers['Cookie'] = cookie;
      options.headers = headers;
    }
    // 配置 httpconfig
    DioUtil().setConfig(HttpConfig(options: options));
  }
}
