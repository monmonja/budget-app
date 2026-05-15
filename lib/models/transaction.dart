class Transaction {
  final DateTime? date;
  final double? amount;
  final String rawText;
  final String? inferredCategory;
  final String? inferredSubCategory;

  Transaction({
    this.date,
    this.amount,
    required this.rawText,
    this.inferredCategory,
    this.inferredSubCategory,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date?.toIso8601String(),
      'amount': amount,
      'rawText': rawText,
      'inferredCategory': inferredCategory,
      'inferredSubCategory': inferredSubCategory,
    };
  }
}
