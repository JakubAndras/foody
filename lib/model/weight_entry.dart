class WeightEntry {
  final int? id;
  final DateTime date;
  final double weight;
  final String? photoPath;

  WeightEntry({
    this.id,
    required this.date,
    required this.weight,
    this.photoPath,
  });

  WeightEntry copyWith({
    int? id,
    DateTime? date,
    double? weight,
    String? photoPath,
    bool clearPhotoPath = false,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      photoPath: clearPhotoPath ? null : (photoPath ?? this.photoPath),
    );
  }
}
