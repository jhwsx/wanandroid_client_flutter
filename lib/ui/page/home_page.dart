import 'package:common_utils/common_utils.dart';
import 'package:fluintl/fluintl.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid_client_flutter/res/strings.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    LogUtil.d("HomePage build");
    return Container(
      color: Colors.grey,
      alignment: Alignment.center,
      child: Text(
        IntlUtil.getString(context, Ids.titleHome),
        style: TextStyle(fontSize: 24.0),
      ),
    );
  }
}
