class BudgetCategory {
  final String name;
  final List<String> subCategories;
  double budgetAmount;
  String budgetType; // 'Weekly' or 'Fortnightly'

  BudgetCategory({
    required this.name,
    this.subCategories = const [],
    this.budgetAmount = 0.0,
    this.budgetType = 'Weekly',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'subCategories': subCategories,
      'budgetAmount': budgetAmount,
      'budgetType': budgetType,
    };
  }
}
