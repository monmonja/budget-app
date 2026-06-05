import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/models/category_rule.dart';

void main() {
  group('CategoryRule Model', () {
    test('initializes correctly and serializes to JSON', () {
      // Arrange
      final rule = CategoryRule(
        id: 'rule_1',
        keyword: 'woolies',
        category: 'Grocery',
        subCategory: 'Supermarket',
      );

      // Assert state
      expect(rule.id, 'rule_1');
      expect(rule.keyword, 'woolies');
      expect(rule.category, 'Grocery');
      expect(rule.subCategory, 'Supermarket');

      // Act
      final json = rule.toJson();

      // Assert state
      expect(json['id'], 'rule_1');
      expect(json['keyword'], 'woolies');
      expect(json['category'], 'Grocery');
      expect(json['subCategory'], 'Supermarket');
    });

    test('deserializes from JSON correctly', () {
      // Arrange
      final json = {
        'id': 'rule_2',
        'keyword': 'shell',
        'category': 'Petrol',
      };

      // Act
      final rule = CategoryRule.fromJson(json);

      // Assert state
      expect(rule.id, 'rule_2');
      expect(rule.keyword, 'shell');
      expect(rule.category, 'Petrol');
      expect(rule.subCategory, null);
    });
  });
}
