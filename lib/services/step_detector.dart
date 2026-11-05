import 'dart:math' as math;

class StepDetector {
  StepDetector({required this.onStep});
  final void Function(int count) onStep;

  static const int _minStepIntervalMs = 280;
  static const int _maxStepIntervalMs = 2000;
  static const int _stepsToValidate = 4;
  static const double _minThreshold = 0.9;

  double _gravity = 9.8;
  double _smoothed = 0.0;
  double _avgAbs = 0.0;
  bool _isPeak = false;
  int _lastStepTime = 0;
  int _pendingSteps = 0;
  bool _validated = false;

  void onAccelerometer(double x, double y, double z) {
    final magnitude = math.sqrt(x * x + y * y + z * z);
    _gravity = _gravity * 0.95 + magnitude * 0.05;
    final dynamicAccel = magnitude - _gravity;
    _smoothed = _smoothed * 0.6 + dynamicAccel * 0.4;
    _avgAbs = _avgAbs * 0.98 + _smoothed.abs() * 0.02;
    
    final threshold = math.max(_minThreshold, _avgAbs * 1.6);
    final now = DateTime.now().millisecondsSinceEpoch;
    final gap = now - _lastStepTime;

    if (_smoothed > threshold && !_isPeak && gap > _minStepIntervalMs) {
      _isPeak = true;
      _registerStep(now, gap);
    } else if (_smoothed < threshold * 0.5) {
      _isPeak = false;
    }
  }

  void _registerStep(int now, int gap) {
    if (gap > _maxStepIntervalMs) {
      _pendingSteps = 0;
      _validated = false;
    }
    _lastStepTime = now;
    if (_validated) { onStep(1); return; }
    _pendingSteps++;
    if (_pendingSteps >= _stepsToValidate) {
      _validated = true;
      onStep(_pendingSteps);
      _pendingSteps = 0;
    }
  }

  void reset() {
    _gravity = 9.8; _smoothed = 0; _avgAbs = 0; _isPeak = false;
    _lastStepTime = 0; _pendingSteps = 0; _validated = false;
  }
}
