class Exercise {
  final int? id;
  final int? dayRecordId;
  final String name;
  final DateTime timestamp;
  final int? durationMinutes;
  final double caloriesBurned;

  const Exercise({
    this.id,
    this.dayRecordId,
    required this.name,
    required this.timestamp,
    this.durationMinutes,
    required this.caloriesBurned,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as int?,
      dayRecordId: json['dayRecordId'] as int?,
      name: (json['name'] as String? ?? '').trim(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      durationMinutes: json['durationMinutes'] as int?,
      caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble() ?? 0,
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
    };
  }

  Exercise copyWith({
    int? id,
    int? dayRecordId,
    String? name,
    DateTime? timestamp,
    int? durationMinutes,
    double? caloriesBurned,
  }) {
    return Exercise(
      id: id ?? this.id,
      dayRecordId: dayRecordId ?? this.dayRecordId,
      name: name ?? this.name,
      timestamp: timestamp ?? this.timestamp,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    );
  }
}
