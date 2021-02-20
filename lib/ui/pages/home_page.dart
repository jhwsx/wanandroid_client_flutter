import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    LogUtil.d("HomePage build");
    return Container(
      color: Colors.grey,
      alignment: Alignment.center,
      child: Text(
        '首页',
        style: TextStyle(fontSize: 24.0),
      ),
    );
  }
}
