class StepMath {
  const StepMath._();
  static const double _strideFactor = 0.415;
  static const double _caloriesPerStepPerKg = 0.0005;

  static double distanceKm(int steps, double heightCm) {
    if (steps <= 0 || heightCm <= 0) return 0;
    return steps * (heightCm * _strideFactor / 100) / 1000;
  }

  static double calories(int steps, double weightKg) {
    if (steps <= 0 || weightKg <= 0) return 0;
    return steps * weightKg * _caloriesPerStepPerKg;
  }
}
