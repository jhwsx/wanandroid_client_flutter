import 'package:base_library/base_library.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid_client_flutter/data/protocol/models.dart';

class TreeItem extends StatelessWidget {
  const TreeItem(this.model, {Key key}) : super(key: key);

  /// 条目对应的数据模型
  final TreeModel model;

  @override
  Widget build(BuildContext context) {
    final List<Widget> chips = model.children.map((TreeModel e) {
      return Chip(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        // 去掉了 Chip 顶部和底部的空白区域
        backgroundColor: Colors.grey[50],
        shape: RoundedRectangleBorder(),
        label: Text(
          e.name,
          // TODO 这个 key 是什么作用？
          // key: ValueKey(e.name),
          style: TextStyle(fontSize: 12.0),
        ),
      );
    }).toList();
    // InkWell 构建了一个可以触摸的矩形区域
    return InkWell(
      onTap: () {
        print('点击了这个条目：${model.name}');
      },
      child: _ChipsTile(
        label: model.name,
        children: chips,
      ),
    );
  }
}

class _ChipsTile extends StatelessWidget {
  const _ChipsTile({Key key, this.label, this.children}) : super(key: key);

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // 高度是最小的
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyles.listTitle,
                ),
                Gaps.vGap10,
                Wrap(
                  // 主轴方向子 widget 的间距
                  spacing: 3.0,
                  // 相交轴方向的间距
                  runSpacing: 3.0,
                  children: children,
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.grey,),
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(width: 0.33, color: Colours.divider)),
      ),
    );
  }
}
