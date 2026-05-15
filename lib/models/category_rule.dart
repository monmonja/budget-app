class CategoryRule {
  final String id;
  final String keyword;
  final String category;
  final String? subCategory;

  CategoryRule({
    required this.id,
    required this.keyword,
    required this.category,
    this.subCategory,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keyword': keyword,
      'category': category,
      'subCategory': subCategory,
    };
  }

  factory CategoryRule.fromJson(Map<String, dynamic> json) {
    return CategoryRule(
      id: json['id'] as String,
      keyword: json['keyword'] as String,
      category: json['category'] as String,
      subCategory: json['subCategory'] as String?,
    );
  }
}
