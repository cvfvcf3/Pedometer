class StepSession {
  const StepSession({this.id, required this.date, required this.startedAt, this.endedAt, required this.steps});
  final int? id;
  final String date;
  final int startedAt;
  final int? endedAt;
  final int steps;

  bool get isActive => endedAt == null;
  DateTime get startTime => DateTime.fromMillisecondsSinceEpoch(startedAt);
  DateTime? get endTime => endedAt == null ? null : DateTime.fromMillisecondsSinceEpoch(endedAt!);

  Duration durationUntil(DateTime now) {
    final end = endTime ?? now;
    final diff = end.difference(startTime);
    return diff.isNegative ? Duration.zero : diff;
  }

  StepSession copyWith({int? id, String? date, int? startedAt, int? endedAt, int? steps, bool clearEndedAt = false}) {
    return StepSession(
      id: id ?? this.id, date: date ?? this.date, startedAt: startedAt ?? this.startedAt,
      endedAt: clearEndedAt ? null : (endedAt ?? this.endedAt), steps: steps ?? this.steps,
    );
  }

  factory StepSession.fromMap(Map<String, Object?> map) {
    return StepSession(
      id: map['id'] as int?, date: (map['date'] as String?) ?? '',
      startedAt: (map['started_at'] as int?) ?? 0, endedAt: map['ended_at'] as int?,
      steps: (map['steps'] as int?) ?? 0,
    );
  }
}
