import '../datasources/linguistics_memory_alpha.dart';

class DomainAssessment {
  final List<String> activeFlags;
  final List<String> warnings;

  DomainAssessment({
    required this.activeFlags,
    required this.warnings,
  });

  bool get isHighStakes => activeFlags.isNotEmpty;
}

class DomainDetectionService {
  final Set<String> _medicalKeywords = {
    'hospital', 'doctor', 'medicine', 'physician', 'clinic', 'pharmacy', 'patient', 'nurse', 'emergency',
    'ambulance', 'surgery', 'prescription', 'medication', 'hospitales', 'médico', 'medicina', 'clínica',
    'médicos', 'farmacia', 'paciente', 'enfermera', 'emergencia', 'ambulancia', 'hôpital', 'médecin',
    'médicament', 'médicaments', 'clinique', 'pharmacie', 'infirmière', 'urgence',
    'valetudinarium', 'medicus', 'medicamentum', 'apotheca', 'aegrotus', 'asclepeion', 'asklepieion', 'iatros',
    'pharmakon', 'iatreion', 'swnw', 'phrt', 'asya', 'asyo', 'samona', 'samo'
  };

  final Set<String> _legalKeywords = {
    'court', 'lawyer', 'arrest', 'prison', 'judge', 'tribunal', 'courts', 'lawyers', 'arrests', 'prisons', 'judges',
    'abogado', 'abogados', 'arrestar', 'detener', 'prisión', 'cárcel', 'juez', 'jueces', 'tribunales',
    'avocat', 'avocats', 'arrestation', 'arrestations', 'magistrat', 'juge',
    'patronus', 'advocatus', 'prehendere', 'carcer', 'iudex', 'iudices', 'iudicium',
    'dikasterion', 'synegoros', 'synegoroi', 'syneborein', 'syneborei', 'syneghra',
    'desmoterion', 'dikastes', 'dikastai', 'bema', 'praetor', 'hwt-wrt', 'hnrt', 'sab', 'djadjat',
    'dayana', 'dayano'
  };

  DomainAssessment analyzeText(String text) {
    final normalized = text.toLowerCase();
    
    // Tokenize text using word boundaries and standard characters (retains accents)
    final tokens = normalized
        .split(RegExp(r'[^a-zA-Z\u00C0-\u017F]+'))
        .where((t) => t.isNotEmpty)
        .toSet();

    final List<String> activeFlags = [];
    final List<String> warnings = [];

    // Check medical domain matches
    final hasMedicalMatch = tokens.any((t) => _medicalKeywords.contains(t));
    if (hasMedicalMatch) {
      activeFlags.add('MEDICAL_DOMAIN');
      warnings.add(LinguisticsMemoryAlpha.highStakesWarnings['MEDICAL_DOMAIN']!);
    }

    // Check legal domain matches
    final hasLegalMatch = tokens.any((t) => _legalKeywords.contains(t));
    if (hasLegalMatch) {
      activeFlags.add('LEGAL_DOMAIN');
      warnings.add(LinguisticsMemoryAlpha.highStakesWarnings['LEGAL_DOMAIN']!);
    }

    return DomainAssessment(
      activeFlags: activeFlags,
      warnings: warnings,
    );
  }
}
