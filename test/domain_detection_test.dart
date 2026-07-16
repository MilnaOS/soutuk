import 'package:flutter_test/flutter_test.dart';
import 'package:soutuk/data/services/domain_detection_service.dart';

void main() {
  group('DomainDetectionService Tests', () {
    late DomainDetectionService service;

    setUp(() {
      service = DomainDetectionService();
    });

    test('Detects medical domain in modern English', () {
      final assessment = service.analyzeText('Please take me to the hospital, I need a doctor.');
      expect(assessment.isHighStakes, isTrue);
      expect(assessment.activeFlags, contains('MEDICAL_DOMAIN'));
      expect(assessment.activeFlags, isNot(contains('LEGAL_DOMAIN')));
    });

    test('Detects medical domain in Spanish and French', () {
      final assessmentSpa = service.analyzeText('El médico recomendó esta medicina en la clínica.');
      expect(assessmentSpa.activeFlags, contains('MEDICAL_DOMAIN'));

      final assessmentFra = service.analyzeText('Le médecin travaille dans un grand hôpital.');
      expect(assessmentFra.activeFlags, contains('MEDICAL_DOMAIN'));
    });

    test('Detects medical domain in ancient languages', () {
      final assessmentGrc = service.analyzeText('He visited the asklepieion to consult the iatros.');
      expect(assessmentGrc.activeFlags, contains('MEDICAL_DOMAIN'));

      final assessmentEgy = service.analyzeText('The swnw searched the papyrus for a phrt.');
      expect(assessmentEgy.activeFlags, contains('MEDICAL_DOMAIN'));
    });

    test('Detects legal domain in modern English', () {
      final assessment = service.analyzeText('The lawyer and the judge arrived at the court.');
      expect(assessment.isHighStakes, isTrue);
      expect(assessment.activeFlags, contains('LEGAL_DOMAIN'));
    });

    test('Detects legal domain in Spanish and French', () {
      final assessmentSpa = service.analyzeText('El abogado habló ante el juez del tribunal.');
      expect(assessmentSpa.activeFlags, contains('LEGAL_DOMAIN'));

      final assessmentFra = service.analyzeText('Le juge a ordonné son arrestation au tribunal.');
      expect(assessmentFra.activeFlags, contains('LEGAL_DOMAIN'));
    });

    test('Detects legal domain in ancient languages', () {
      final assessmentGrc = service.analyzeText('The synegoros spoke on the bema of the dikasterion.');
      expect(assessmentGrc.activeFlags, contains('LEGAL_DOMAIN'));

      final assessmentLat = service.analyzeText('Iudex in tribunali sententiam pronuntiavit.');
      expect(assessmentLat.activeFlags, contains('LEGAL_DOMAIN'));
    });

    test('No domains triggered for general conversations', () {
      final assessment = service.analyzeText('Hello, my friend! How are you doing today?');
      expect(assessment.isHighStakes, isFalse);
      expect(assessment.activeFlags, isEmpty);
      expect(assessment.warnings, isEmpty);
    });

    test('Dual domains triggered when both sets of keywords are present', () {
      final assessment = service.analyzeText('The doctor was arrested and taken to prison.');
      expect(assessment.isHighStakes, isTrue);
      expect(assessment.activeFlags, contains('MEDICAL_DOMAIN'));
      expect(assessment.activeFlags, contains('LEGAL_DOMAIN'));
      expect(assessment.warnings.length, equals(2));
    });
  });
}
