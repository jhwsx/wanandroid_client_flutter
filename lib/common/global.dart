import 'dart:io';

import 'package:base_library/base_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Global {
  // 初始化全局信息
  static Future init(VoidCallback callback) async {
    // 为什么需要这行？
    // https://stackoverflow.com/questions/63873338/what-does-widgetsflutterbinding-ensureinitialized-do
    WidgetsFlutterBinding.ensureInitialized();
    await SpUtil.getInstance();
    callback();
    if (Platform.isAndroid) {
      // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
      SystemUiOverlayStyle systemUiOverlayStyle =
          SystemUiOverlayStyle(statusBarColor: Colors.transparent);
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }
  }
}
