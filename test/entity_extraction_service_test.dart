import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:budget_app/services/entity_extraction_service.dart';
import 'package:budget_app/models/category_rule.dart';
import 'package:budget_app/services/data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('EntityExtractionService', () {
    late EntityExtractionService service;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();

      // Mock the method channels for Google ML Kit Entity Extraction
      const MethodChannel channel1 = MethodChannel('google_mlkit_entity_extraction');
      const MethodChannel channel2 = MethodChannel('google_mlkit_entity_extractor');

      Future<dynamic> mockHandler(MethodCall methodCall) async {
        if (methodCall.method == 'nlp#startEntityExtractor') {
          return null;
        } else if (methodCall.method == 'nlp#closeEntityExtractor') {
          return null;
        } else if (methodCall.method == 'nlp#annotateText') {
          return <dynamic>[]; // Return empty list instead of null to prevent TypeError
        }
        return null;
      }

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel1, mockHandler
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel2, mockHandler
      );
    });

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = EntityExtractionService();
    });

    test('categorizes based on user-defined rules', () async {
      // Arrange
      final rule = CategoryRule(id: '1', keyword: 'woolworths', category: 'Grocery', subCategory: 'Supermarket');
      await DataService.addCategoryRule(rule);

      final text = 'Payment to Woolworths 50.00';

      // Act
      final transaction = await service.parseTransactionText(text);

      // Assert
      expect(transaction.inferredCategory, 'Grocery');
      expect(transaction.inferredSubCategory, 'Supermarket');
    });

    test('falls back to initial categories if no rule matches', () async {
      // Arrange
      final text = 'Payment for Petrol 30.00'; // "Petrol" is an initial category

      // Act
      final transaction = await service.parseTransactionText(text);

      // Assert
      expect(transaction.inferredCategory, 'Petrol');
    });

    test('falls back to initial sub-categories if no rule matches', () async {
      // Arrange
      final text = 'Payment for Electricity 100.00'; // "Electricity" is an initial sub-category of "Utilities"

      // Act
      final transaction = await service.parseTransactionText(text);

      // Assert
      expect(transaction.inferredCategory, 'Utilities');
      expect(transaction.inferredSubCategory, 'Electricity');
    });

    test('returns null category if no rules or initial categories match', () async {
      // Arrange
      final text = 'Payment for RandomThing 50.00';

      // Act
      final transaction = await service.parseTransactionText(text);

      // Assert
      expect(transaction.inferredCategory, isNull);
      expect(transaction.inferredSubCategory, isNull);
    });

    test('extracts raw text correctly', () async {
      // Arrange
      final text = 'Some raw transaction text';

      // Act
      final transaction = await service.parseTransactionText(text);

      // Assert
      expect(transaction.rawText, text);
    });
  });
}
