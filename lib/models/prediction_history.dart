class PredictionHistory {
  final String id;
  final String type; // 'disease' or 'breed'
  final String result;
  final double confidence;
  final DateTime timestamp;
  final String? imagePath;
  final String? notes;

  PredictionHistory({
    required this.id,
    required this.type,
    required this.result,
    required this.confidence,
    required this.timestamp,
    this.imagePath,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'result': result,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
      'notes': notes,
    };
  }

  factory PredictionHistory.fromMap(Map<String, dynamic> map) {
    return PredictionHistory(
      id: map['id'] as String,
      type: map['type'] as String,
      result: map['result'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
      imagePath: map['imagePath'] as String?,
      notes: map['notes'] as String?,
    );
  }
}

