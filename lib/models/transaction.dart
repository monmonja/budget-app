class Transaction {
  final String id;
  final DateTime? date;
  final double? amount;
  final String rawText;
  final String? inferredCategory;
  final String? inferredSubCategory;

  Transaction({
    required this.id,
    this.date,
    this.amount,
    required this.rawText,
    this.inferredCategory,
    this.inferredSubCategory,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date?.toIso8601String(),
      'amount': amount,
      'rawText': rawText,
      'inferredCategory': inferredCategory,
      'inferredSubCategory': inferredSubCategory,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      amount: (json['amount'] as num?)?.toDouble(),
      rawText: json['rawText'] as String,
      inferredCategory: json['inferredCategory'] as String?,
      inferredSubCategory: json['inferredSubCategory'] as String?,
    );
  }
}
