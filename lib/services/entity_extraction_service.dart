import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import '../models/transaction.dart';
import '../constants.dart';

class EntityExtractionService {
  final EntityExtractor _entityExtractor =
      EntityExtractor(language: EntityExtractorLanguage.english);

  Future<Transaction> parseTransactionText(String text) async {
    DateTime? extractedDate;
    double? extractedAmount;

    try {
      final List<EntityAnnotation> annotations =
          await _entityExtractor.annotateText(text);

      for (final annotation in annotations) {
        for (final entity in annotation.entities) {
          if (entity.type == EntityType.dateTime) {
            // Note: In a real app we might need to parse the specific date format
            // depending on what ML Kit extracts (e.g. timestamp or string).
            // For now, we take the raw text if possible, or try to interpret it.
            // EntityExtractor gives properties, but as a fallback, we can use the text.
            extractedDate = DateTime.tryParse(annotation.text) ?? DateTime.now(); // Fallback for demonstration
          } else if (entity.type == EntityType.money) {
            // The money entity might contain symbols.
            final cleanAmountString = annotation.text.replaceAll(RegExp(r'[^0-9.]'), '');
            extractedAmount = double.tryParse(cleanAmountString);
          }
        }
      }
    } catch (e) {
      print("Error extracting entities: $e");
    }

    // Attempt simple keyword matching for category
    String? matchedCategory;
    String? matchedSubCategory;

    final lowerText = text.toLowerCase();

    for (final category in initialCategories) {
      if (lowerText.contains(category.name.toLowerCase())) {
        matchedCategory = category.name;
      }
      for (final sub in category.subCategories) {
        if (lowerText.contains(sub.toLowerCase())) {
          matchedCategory = category.name;
          matchedSubCategory = sub;
        }
      }
    }

    return Transaction(
      date: extractedDate,
      amount: extractedAmount,
      rawText: text,
      inferredCategory: matchedCategory,
      inferredSubCategory: matchedSubCategory,
    );
  }

  void dispose() {
    _entityExtractor.close();
  }
}
