class TreatmentGuide {
  final String diseaseName;
  final String code;
  final List<String> symptoms;
  final List<String> treatmentSteps;
  final List<String> precautions;
  final List<String> firstAid;
  final bool isSevere;
  final List<String> emergencyContacts;
  final String description;

  TreatmentGuide({
    required this.diseaseName,
    required this.code,
    required this.symptoms,
    required this.treatmentSteps,
    required this.precautions,
    required this.firstAid,
    this.isSevere = false,
    this.emergencyContacts = const [],
    this.description = '',
  });
}

