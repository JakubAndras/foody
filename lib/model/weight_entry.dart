class WeightEntry {
  final int? id;
  final DateTime date;
  final double weight;

  WeightEntry({
    this.id,
    required this.date,
    required this.weight,
  });

  WeightEntry copyWith({
    int? id,
    DateTime? date,
    double? weight,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
    );
  }
}
