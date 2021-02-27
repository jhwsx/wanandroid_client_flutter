import 'package:base_library/base_library.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid_client_flutter/data/protocol/models.dart';
import 'package:wanandroid_client_flutter/util/navigator_util.dart';

class ArticleItem extends StatelessWidget {
  const ArticleItem(this.model, {Key key, this.isHome}) : super(key: key);

  final RepoModel model;
  final bool isHome;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        NavigatorUtil.pushWeb(context, model.title, model.link);
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: double.infinity),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(ObjectUtil.isEmpty(model.author) ? model.shareUser: model.author),
                  Text(model.niceDate),
                ],
              ),
              Gaps.vGap5,
              Text(
                model.title,
                style: TextStyles.listTitle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Gaps.vGap5,
              isHome ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(model.superChapterName),
                  Icon(Icons.camera),
                ],
              ): Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Icon(Icons.camera),
                ],
              ),
            ],
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(width: 0.33, color: Colours.divider)),
        ),
      ),
    );
  }
}
