/// Represents the result of a disease classification prediction.
class DiseaseResult {
  /// The predicted disease name (or "Healthy Leaf").
  final String name;

  /// The confidence percentage (0.0 - 100.0).
  final double confidence;

  /// Index in the label list.
  final int classIndex;

  /// All class probabilities from the model output.
  final List<double> probabilities;

  const DiseaseResult({
    required this.name,
    required this.confidence,
    required this.classIndex,
    required this.probabilities,
  });

  /// Whether the prediction is confident enough to be reliable.
  bool get isConfident => confidence >= 60.0;

  /// Whether the leaf is predicted as healthy.
  bool get isHealthy => name == 'Healthy Leaf';

  /// Formatted confidence string.
  String get confidenceText => '${confidence.toStringAsFixed(1)}%';
}

/// Detailed information about a chili leaf disease.
class DiseaseInfo {
  final String name;
  final String description;
  final String cause;
  final List<String> symptoms;
  final List<String> treatments;
  final String severity;

  const DiseaseInfo({
    required this.name,
    required this.description,
    required this.cause,
    required this.symptoms,
    required this.treatments,
    required this.severity,
  });

  /// Get disease info by name.
  static DiseaseInfo getInfo(String diseaseName) {
    return _diseaseDatabase[diseaseName] ?? _unknownDisease;
  }

  /// Database of all known chili leaf diseases.
  static const Map<String, DiseaseInfo> _diseaseDatabase = {
    'Bacterial Spot': DiseaseInfo(
      name: 'Bacterial Spot',
      description:
          'Bacterial spot is a common disease of chili peppers caused by '
          'Xanthomonas species. It causes dark, water-soaked lesions on '
          'leaves, stems, and fruits.',
      cause: 'Xanthomonas campestris pv. vesicatoria bacteria',
      symptoms: [
        'Small, dark, water-soaked spots on leaves',
        'Spots may have a yellow halo',
        'Lesions turn brown and papery with age',
        'Severely affected leaves may drop prematurely',
        'Raised, scab-like spots on fruit',
      ],
      treatments: [
        'Remove and destroy infected plant debris',
        'Apply copper-based bactericides (e.g., copper hydroxide)',
        'Use disease-free seeds and transplants',
        'Practice crop rotation (2-3 year cycle)',
        'Avoid overhead irrigation to reduce leaf wetness',
        'Space plants adequately for air circulation',
      ],
      severity: 'Moderate to High',
    ),
    'Cercospora Leaf Spot': DiseaseInfo(
      name: 'Cercospora Leaf Spot',
      description:
          'Cercospora leaf spot (Frogeye spot) is a fungal disease that '
          'creates circular spots with gray centers and dark borders. '
          'It thrives in warm, humid conditions.',
      cause: 'Cercospora capsici fungus',
      symptoms: [
        'Circular spots with gray/white centers',
        'Dark brown to reddish-brown borders around spots',
        'Spots may coalesce forming large necrotic areas',
        'Lower leaves are usually affected first',
        'Severe defoliation in advanced stages',
      ],
      treatments: [
        'Apply fungicides (Mancozeb, Chlorothalonil)',
        'Remove and destroy infected leaves',
        'Ensure good air circulation between plants',
        'Avoid overhead watering',
        'Use resistant varieties when available',
        'Apply neem oil as an organic alternative',
      ],
      severity: 'Moderate',
    ),
    'Curl Virus': DiseaseInfo(
      name: 'Curl Virus',
      description:
          'Chili leaf curl virus (ChiLCV) causes severe curling, '
          'puckering, and distortion of leaves. It is transmitted by '
          'whiteflies and can cause significant yield loss.',
      cause: 'Begomovirus (Chili Leaf Curl Virus) transmitted by whiteflies',
      symptoms: [
        'Upward or downward curling of leaves',
        'Leaves become thick and leathery',
        'Puckering and crinkling of leaf surface',
        'Stunted plant growth',
        'Reduced fruit size and yield',
        'Yellowing (chlorosis) of affected leaves',
      ],
      treatments: [
        'Control whitefly population with insecticides',
        'Use yellow sticky traps to monitor whiteflies',
        'Remove and destroy infected plants immediately',
        'Use virus-free seedlings',
        'Apply neem-based insecticides',
        'Use reflective mulches to repel whiteflies',
        'Plant resistant varieties',
      ],
      severity: 'High',
    ),
    'Healthy Leaf': DiseaseInfo(
      name: 'Healthy Leaf',
      description:
          'This leaf appears to be healthy with no visible signs of '
          'disease or pest damage. The leaf shows normal color, shape, '
          'and texture.',
      cause: 'No disease detected',
      symptoms: [
        'Uniform green color',
        'Smooth leaf surface',
        'Normal leaf shape and size',
        'No spots, lesions, or discoloration',
      ],
      treatments: [
        'Continue regular watering schedule',
        'Maintain balanced fertilization',
        'Monitor for early signs of disease',
        'Practice preventive pest management',
        'Ensure proper spacing for air circulation',
      ],
      severity: 'None',
    ),
    'Nutrition Deficiency': DiseaseInfo(
      name: 'Nutrition Deficiency',
      description:
          'Nutrient deficiency in chili plants occurs when essential '
          'macro or micronutrients are lacking in the soil. Common '
          'deficiencies include nitrogen, potassium, magnesium, and iron.',
      cause: 'Lack of essential nutrients (N, P, K, Mg, Fe, Ca, etc.)',
      symptoms: [
        'Yellowing of leaves (chlorosis)',
        'Interveinal yellowing (magnesium/iron deficiency)',
        'Purpling of leaves (phosphorus deficiency)',
        'Brown leaf edges (potassium deficiency)',
        'Stunted growth',
        'Poor fruit development',
      ],
      treatments: [
        'Conduct soil testing to identify specific deficiency',
        'Apply balanced NPK fertilizer (10-10-10 or 14-14-14)',
        'Add compost or organic matter to soil',
        'Apply foliar spray of micronutrient mix',
        'Use Epsom salt (magnesium sulfate) for Mg deficiency',
        'Adjust soil pH to 6.0-6.8 for optimal nutrient uptake',
        'Apply chelated iron for iron deficiency',
      ],
      severity: 'Low to Moderate',
    ),
    'White spot': DiseaseInfo(
      name: 'White spot',
      description:
          'White spot disease on chili leaves can be caused by various '
          'factors including fungal infections (powdery mildew), pest '
          'damage, or environmental stress. It appears as white or pale '
          'patches on the leaf surface.',
      cause: 'Fungal pathogens (Powdery mildew - Leveillula taurica) or pest damage',
      symptoms: [
        'White powdery patches on leaf surfaces',
        'Spots may start small and expand',
        'Affected areas may turn yellow and brown',
        'Premature leaf drop',
        'Reduced photosynthesis and plant vigor',
      ],
      treatments: [
        'Apply sulfur-based fungicides',
        'Use potassium bicarbonate spray',
        'Apply neem oil (organic option)',
        'Remove heavily infected leaves',
        'Improve air circulation around plants',
        'Avoid excessive nitrogen fertilization',
        'Apply milk spray (1:9 milk-to-water ratio) as organic treatment',
      ],
      severity: 'Low to Moderate',
    ),
  };

  static const DiseaseInfo _unknownDisease = DiseaseInfo(
    name: 'Unknown',
    description: 'The disease could not be identified with high confidence.',
    cause: 'Unknown',
    symptoms: ['Unable to determine specific symptoms'],
    treatments: [
      'Consult a local agricultural extension officer',
      'Take a clear photo and seek expert diagnosis',
    ],
    severity: 'Unknown',
  );
}
