import 'dart:async';
import 'dart:io' show Platform;
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'step_detector.dart';

class StepEvent {
  final bool isHardware;
  final int value;
  StepEvent(this.isHardware, this.value);
}

class PedometerService {
  final _eventController = StreamController<StepEvent>.broadcast();
  Stream<StepEvent> get eventStream => _eventController.stream;

  StreamSubscription<StepCount>? _hardwareSub;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  bool _usingHardware = false;
  late final StepDetector _detector;

  PedometerService() {
    _detector = StepDetector(onStep: (count) => _eventController.add(StepEvent(false, count)));
  }

  Future<void> startTracking() async {
    if (Platform.isAndroid) {
      final status = await Permission.activityRecognition.status;
      if (!status.isGranted) {
        final req = await Permission.activityRecognition.request();
        if (req.isGranted) { _startHardware(); } else { _startSoftware(); }
      } else { _startHardware(); }
    } else { _startHardware(); }
  }

  void _startHardware() {
    try {
      _hardwareSub = Pedometer.stepCountStream.listen(
        (event) { _usingHardware = true; _eventController.add(StepEvent(true, event.steps)); },
        onError: (Object error) => _startSoftware(),
      );
    } catch (e) { _startSoftware(); }
  }

  void _startSoftware() {
    if (_usingHardware) return;
    _accelSub?.cancel();
    _detector.reset();
    _accelSub = accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
        .listen((AccelerometerEvent event) => _detector.onAccelerometer(event.x, event.y, event.z));
  }

  void stopTracking() {
    _hardwareSub?.cancel(); _accelSub?.cancel();
    _hardwareSub = null; _accelSub = null; _usingHardware = false;
  }

  void dispose() { stopTracking(); _eventController.close(); }
}
