import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/dates.dart';
import '../data/models/daily_steps.dart';
import '../data/models/step_session.dart';
import '../data/repositories/step_repository.dart';
import '../services/pedometer_service.dart';

enum TrackingStatus { loading, running, permissionDenied, sensorUnavailable, error }

class PedometerProvider extends ChangeNotifier {
  PedometerProvider({PedometerService? service, StepRepository? repository})
      : _service = service ?? PedometerService(), _repository = repository ?? StepRepository();

  static const String _keyLastRawSteps = 'last_raw_steps';
  static const String _keyLastRawDate = 'last_raw_date';

  final PedometerService _service;
  final StepRepository _repository;
  StreamSubscription<StepEvent>? _subscription;
  SharedPreferences? _prefs;
  Timer? _sessionTicker;
  bool _initialized = false;

  TrackingStatus _status = TrackingStatus.loading;
  int _todaySteps = 0;
  String _todayDate = dateKey(DateTime.now());
  String? _errorMessage;
  List<DailySteps> _history = const [];
  bool _historyLoading = false;
  List<StepSession> _todaySessions = const [];
  int? _activeSessionId;
  int _activeSessionSteps = 0;
  DateTime? _activeSessionStartedAt;

  TrackingStatus get status => _status;
  int get todaySteps => _todaySteps;
  String get todayDate => _todayDate;
  String? get errorMessage => _errorMessage;
  List<DailySteps> get history => _history;
  bool get historyLoading => _historyLoading;
  List<StepSession> get todaySessions => _todaySessions;
  bool get isSessionActive => _activeSessionId != null;
  int get activeSessionSteps => _activeSessionSteps;

  Duration get activeSessionDuration {
    final start = _activeSessionStartedAt;
    if (start == null) return Duration.zero;
    final diff = DateTime.now().difference(start);
    return diff.isNegative ? Duration.zero : diff;
  }

  Future<SharedPreferences> get _prefsAsync async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> init() async {
    _setStatus(TrackingStatus.loading);
    _todayDate = dateKey(DateTime.now());
    if (!_initialized) {
      try { await _repository.closeOrphanedSessions(); } catch (_) {}
      _initialized = true;
    }
    await _refreshToday();
    await _startTracking();
  }

  Future<void> requestPermission() async => init();

  Future<void> startSession() async {
    if (_activeSessionId != null) return;
    final now = DateTime.now();
    _todayDate = dateKey(now);
    try {
      final id = await _repository.startSession(_todayDate, now);
      _todaySessions = [..._todaySessions, StepSession(id: id, date: _todayDate, startedAt: now.millisecondsSinceEpoch, steps: 0)];
      _activeSessionId = id; _activeSessionSteps = 0; _activeSessionStartedAt = now;
      _startTicker(); notifyListeners();
    } catch (error) { _errorMessage = error.toString(); _setStatus(TrackingStatus.error); }
  }

  Future<void> stopSession() async {
    final id = _activeSessionId;
    if (id == null) return;
    final now = DateTime.now(); final nowMs = now.millisecondsSinceEpoch;
    try { await _repository.endSession(id, now); } catch (_) {}
    _todaySessions = _todaySessions.map((s) => s.id == id ? s.copyWith(endedAt: nowMs) : s).toList();
    _activeSessionId = null; _activeSessionSteps = 0; _activeSessionStartedAt = null;
    _stopTicker(); _todayDate = dateKey(now);
    try { _todaySteps = await _repository.stepsForDate(_todayDate); } catch (_) {}
    notifyListeners();
  }

  Future<List<StepSession>> sessionsForDate(String date) => _repository.sessionsForDate(date);

  Future<void> loadHistory({int days = 14}) async {
    _historyLoading = true; notifyListeners();
    try { _history = await _repository.lastDays(days); } catch (_) { _history = const []; }
    _historyLoading = false; notifyListeners();
  }

  Future<void> clearAllData() async {
    await _repository.clearAll();
    final prefs = await _prefsAsync;
    await prefs.remove(_keyLastRawSteps); await prefs.remove(_keyLastRawDate);
    _todaySteps = 0; _todayDate = dateKey(DateTime.now());
    _history = const []; _todaySessions = const [];
    _activeSessionId = null; _activeSessionSteps = 0; _activeSessionStartedAt = null;
    _stopTicker(); notifyListeners();
  }

  Future<void> _refreshToday() async {
    try {
      _todaySteps = await _repository.stepsForDate(_todayDate);
      _todaySessions = await _repository.sessionsForDate(_todayDate);
    } catch (_) { _todaySteps = 0; _todaySessions = const []; }
  }

  Future<void> _startTracking() async {
    _subscription?.cancel();
    _subscription = _service.eventStream.listen(
      (event) => _handleStep(event),
      onError: (Object error) { _errorMessage = error.toString(); _setStatus(TrackingStatus.error); },
    );
    _errorMessage = null;
    final granted = await _service.startTracking();
    _setStatus(granted ? TrackingStatus.running : TrackingStatus.permissionDenied);
  }

  Future<void> _handleStep(StepEvent event) async {
    final prefs = await _prefsAsync;
    final today = dateKey(DateTime.now());
    
    if (today != _todayDate) {
      if (_activeSessionId != null) { await stopSession(); }
      _todayDate = today; _todaySteps = 0; _todaySessions = const []; notifyListeners();
    }

    final sessionId = _activeSessionId;
    if (sessionId == null) {
      if (event.isHardware) {
         await prefs.setInt(_keyLastRawSteps, event.value);
         await prefs.setString(_keyLastRawDate, today);
      }
      return;
    }

    var delta = 0;
    if (event.isHardware) {
      final lastRaw = prefs.getInt(_keyLastRawSteps);
      final lastDate = prefs.getString(_keyLastRawDate);
      if (lastDate == today && lastRaw != null) {
         delta = event.value >= lastRaw ? event.value - lastRaw : event.value;
      }
      await prefs.setInt(_keyLastRawSteps, event.value);
      await prefs.setString(_keyLastRawDate, today);
    } else { delta = event.value; }

    if (delta <= 0) return;

    try {
      await _repository.addStepsToSession(sessionId, delta);
      _todaySteps += delta; _activeSessionSteps += delta;
      _todaySessions = _todaySessions.map((s) => s.id == sessionId ? s.copyWith(steps: s.steps + delta) : s).toList();
      notifyListeners();
    } catch (_) {}
  }

  void _startTicker() {
    _sessionTicker?.cancel();
    _sessionTicker = Timer.periodic(const Duration(seconds: 1), (_) { if (_activeSessionId != null) notifyListeners(); });
  }

  void _stopTicker() { _sessionTicker?.cancel(); _sessionTicker = null; }
  void _setStatus(TrackingStatus status) { _status = status; notifyListeners(); }

  @override
  void dispose() { _subscription?.cancel(); _service.dispose(); _stopTicker(); super.dispose(); }
}
