import 'package:flutter_test/flutter_test.dart';
import 'package:soutuk/data/services/dot_index_query_manager.dart';

void main() {
  group('DotIndexQueryManager Tests', () {
    late DotIndexQueryManager manager;

    setUp(() {
      manager = DotIndexQueryManager();
    });

    test('Slices correct baseline grammar for English and Spanish', () {
      final payload = manager.sliceActivePayload('Hello world', 'eng', 'spa');
      expect(payload.sourceLanguageIso, equals('eng'));
      expect(payload.targetLanguageIso, equals('spa'));
      expect(payload.sourceCard.content, contains('SVO'));
      expect(payload.targetCard.content, contains('VSO fluid'));
      expect(payload.hazardCard, isNull);
    });

    test('Slices matching vocabulary cards for high-stakes English words', () {
      final payload = manager.sliceActivePayload('I need a doctor at the hospital.', 'eng', 'spa');
      expect(payload.sourceCard.content, contains('Matched Sliced Vocabulary:'));
      expect(payload.sourceCard.content, contains('Doctor (Noun)'));
      expect(payload.sourceCard.content, contains('Hospital (Noun)'));
      
      expect(payload.targetCard.content, contains('Matched Sliced Vocabulary:'));
      expect(payload.targetCard.content, contains('Doctor / Médico (Sustantivo)'));
      expect(payload.targetCard.content, contains('Hospital (Sustantivo)'));
      
      expect(payload.hazardCard, isNotNull);
      expect(payload.hazardCard!.content, contains('SAFETY GATE ACTIVE'));
    });

    test('Slices vocabulary dynamically using token boundaries', () {
      // Test word boundaries and case insensitivity
      final payload = manager.sliceActivePayload('The COURT has summoned a LAWYER.', 'eng', 'lat');
      expect(payload.sourceCard.content, contains('Court (Noun)'));
      expect(payload.sourceCard.content, contains('Lawyer (Noun)'));

      expect(payload.targetCard.content, contains('Tribunal (Nomen)'));
      expect(payload.targetCard.content, contains('Patronus / Advocatus (Nomen)'));
      
      expect(payload.hazardCard, isNotNull);
      expect(payload.hazardCard!.content, contains('LIABILITY SIGNATURE REQUIRED'));
    });

    test('Does not slice unrelated vocabulary', () {
      final payload = manager.sliceActivePayload('The cat sat on the mat.', 'eng', 'spa');
      expect(payload.sourceCard.content, isNot(contains('Matched Sliced Vocabulary:')));
      expect(payload.targetCard.content, isNot(contains('Matched Sliced Vocabulary:')));
      expect(payload.hazardCard, isNull);
    });
  });
}
