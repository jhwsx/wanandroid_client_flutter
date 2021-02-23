import 'package:fluintl/fluintl.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid_client_flutter/res/strings.dart';

class NavigationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      alignment: Alignment.center,
      child: Text(
        IntlUtil.getString(context, Ids.titleNavigation),
        style: TextStyle(fontSize: 24.0),
      ),
    );
  }
}
