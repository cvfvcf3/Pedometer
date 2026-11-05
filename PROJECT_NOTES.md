# Step Tracker — Pedometer App (Hybrid)

## Features
- Hybrid Step Counting (Hardware + Software fallback)
- **Software Fallback updated with Dynamic Threshold & Rhythm validation**
- Ring shows current session steps, total steps shown below
- Session-based tracking
- History, dark mode, EN/UR

## Files
| File | Purpose |
|---|---|
| `lib/services/step_detector.dart` | New: Advanced accelerometer step detector with rhythm check |
| `lib/services/pedometer_service.dart` | Updated: Uses StepDetector for software fallback |
