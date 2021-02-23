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
}
