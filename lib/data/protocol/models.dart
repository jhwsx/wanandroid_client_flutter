/// 通用的 data 节点数据封装类
class CommonData {
  int size;
  List datas;

  CommonData.fromJson(Map<String, dynamic> json)
      : size = json['size'],
        datas = json['datas'];
}

/// 通用请求封装类
class CommonRequest {
  int cid;

  CommonRequest(this.cid);

  CommonRequest.fromJson(Map<String, dynamic> json) : cid = json['cid'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'cid': cid,
      };
}

/// 项目或文章条目类
class RepoModel {
  /// 列表中文章的 id
  int id;

  /// 代表的是你收藏之前的那篇文章本身的id； 但是收藏支持主动添加，这种情况下，没有originId则为-1
  int originId;

  /// 标题，不会为 null
  String title;

  /// 项目描述
  String desc;

  /// 作者 如果是分享人分享的，author 为 null。
  String author;

  /// 分享人 网站上的文章可能是某位作者author的，也可能是某位分享人shareUser分享的。
  String shareUser;

  /// 项目封面图片
  String envelopePic;

  /// 项目仓库链接
  String projectLink;

  /// 链接，不会为 null
  String link;

  /// 可以直接显示的日期
  String niceDate;

  /// 一级分类名称
  String superChapterName;

  bool collect;

  RepoModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        originId = json['originalId'],
        title = json['title'],
        desc = json['desc'],
        author = json['author'],
        shareUser = json['shareUser'],
        envelopePic = json['envelopePic'],
        projectLink = json['projectLink'],
        link = json['link'],
        niceDate = json['niceDate'],
        superChapterName = json['superChapterName'],
        collect = json['collect'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'originId': originId,
        'title': title,
        'desc': desc,
        'author': author,
        'shareUser': shareUser,
        'envelopePic': envelopePic,
        'projectLink': projectLink,
        'link': link,
        'niceDate': niceDate,
        'superChapterName': superChapterName,
        'collect': collect,
      };

  @override
  String toString() {
    StringBuffer sb = StringBuffer('{')
      ..write("\"id\":$id")
      ..write(",\"originId\":$originId")
      ..write(",\"title\":\"$title\"")
      ..write(",\"desc\":\"$desc\"")
      ..write(",\"author\":\"$author\"")
      ..write(",\"shareUser\":\"$shareUser\"")
      ..write(",\"envelopePic\":\"$envelopePic\"")
      ..write(",\"projectLink\":\"$projectLink\"")
      ..write(",\"link\":\"$link\"")
      ..write(",\"niceDate\":\"$niceDate\"")
      ..write(",\"superChapterName\":\"$superChapterName\"")
      ..write(",\"collect\":$collect")
      ..write("}");
    return sb.toString();
  }
}

/// 体系条目类
class TreeModel {
  String name;
  int id;
  List<TreeModel> children;

  TreeModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        id = json['id'],
        children = (json['children'] as List)
            // 对每个元素进行变换
            ?.map((e) => e == null
                ? null
                : TreeModel.fromJson(e as Map<String, dynamic>))
            // Iterable 转为 List
            ?.toList();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'id': id,
        // TODO 这里直接写 children 就可以了，为什么？
        'children': children,
      };

  @override
  String toString() {
    StringBuffer sb = StringBuffer('{')
      ..write("\"name\":\"$name\"")
      ..write(",\"id\":$id")
      ..write(",\"children\":\"$children\"")
      ..write('}');
    return sb.toString();
  }
}
