class Exercise {
  final int? id;
  final int? dayRecordId;
  final String name;
  final DateTime timestamp;
  final int? durationMinutes;
  final double caloriesBurned;
  final bool isFavorite;
  final String? source;

  const Exercise({
    this.id,
    this.dayRecordId,
    required this.name,
    required this.timestamp,
    this.durationMinutes,
    required this.caloriesBurned,
    this.isFavorite = false,
    this.source,
  });

  bool get isFromHealthSync => source == 'apple_health' || source == 'health_connect';

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as int?,
      dayRecordId: json['dayRecordId'] as int?,
      name: (json['name'] as String? ?? '').trim(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      durationMinutes: json['durationMinutes'] as int?,
      caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble() ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
      source: json['source'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dayRecordId': dayRecordId,
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'isFavorite': isFavorite,
      'source': source,
    };
  }

  Exercise copyWith({
    int? id,
    int? dayRecordId,
    String? name,
    DateTime? timestamp,
    int? durationMinutes,
    double? caloriesBurned,
    bool? isFavorite,
    String? source,
  }) {
    return Exercise(
      id: id ?? this.id,
      dayRecordId: dayRecordId ?? this.dayRecordId,
      name: name ?? this.name,
      timestamp: timestamp ?? this.timestamp,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      isFavorite: isFavorite ?? this.isFavorite,
      source: source ?? this.source,
    );
  }
}
