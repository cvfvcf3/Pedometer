class DailySteps {
  const DailySteps({required this.date, required this.steps});
  final String date;
  final int steps;

  factory DailySteps.fromMap(Map<String, Object?> map) {
    final raw = map['steps'];
    return DailySteps(date: (map['date'] as String?) ?? '', steps: raw is int ? raw : (raw is num ? raw.toInt() : 0));
  }
}
