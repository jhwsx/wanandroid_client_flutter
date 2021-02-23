import 'package:base_library/base_library.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid_client_flutter/common/common.dart';

class StatusViews extends StatelessWidget {
  const StatusViews(this.status, {Key key, this.onTap}) : super(key: key);
  final int status;

  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case LoadStatus.fail:
        return Container(
          // 为什么设置 width 为这样呢？为了使 Column 宽度上占用足够的空间
          width: double.infinity,
          // Material 类似于 Android 中的 CardView
          child: Material(
            color: Colors.white,
            // InkWell 构建一个响应触摸事件的矩形区域
            child: InkWell(
              onTap: () {
                onTap();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'ic_network_error',
                    package: BaseConstant.packageBase,
                    width: 100,
                    height: 100,
                  ),
                  Gaps.vGap10,
                  Text('网络出问题了~请您查看网络设置'),
                  Gaps.vGap5,
                  Text('点击屏幕，重新加载'),
                ],
              ),
            ),
          ),
        );
      // break; // todo 这个还要吗？
      case LoadStatus.loading:
        return Container(
          alignment: Alignment.center,
          color: Colours.gray_f0,
          child: ProgressView(),
        );
      case LoadStatus.empty:
        return Container(
          width: double.infinity,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'ic_data_empty',
                package: BaseConstant.packageBase,
              ),
              Gaps.vGap10,
              Text('空空如也~'),
            ],
          ),
        );
        default:
          return Container();
    }
  }
}

class ProgressView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 24.0,
        height: 24.0,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
        ),
      ),
    );
  }
}
