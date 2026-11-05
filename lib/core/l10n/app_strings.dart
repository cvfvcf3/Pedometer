enum AppLanguage {
  en('en'),
  ur('ur');

  const AppLanguage(this.code);
  final String code;
  bool get isRtl => this == AppLanguage.ur;
  static AppLanguage fromCode(String? code) => code == 'ur' ? AppLanguage.ur : AppLanguage.en;
}

class AppStrings {
  const AppStrings(this.language);
  final AppLanguage language;

  static const Map<String, List<String>> _data = {
    'appTitle': ['Step Tracker', 'سٹیپ ٹریکر'],
    'home': ['Home', 'ہوم'],
    'history': ['History', 'تاریخ'],
    'settings': ['Settings', 'ترتیبات'],
    'today': ['Today', 'آج'],
    'steps': ['Steps', 'قدم'],
    'distance': ['Distance', 'فاصلہ'],
    'calories': ['Calories', 'کیلوریز'],
    'goal': ['Goal', 'ہدف'],
    'dailyGoal': ['Daily goal', 'روزانہ ہدف'],
    'stepGoalHint': ['Steps per day', 'روزانہ قدم'],
    'permissionTitle': ['Activity permission needed', 'سرگرمی کی اجازت درکار ہے'],
    'permissionBody': ['Allow physical activity access so the app can count your steps.', 'قدم گننے کے لیے فزیکل ایکٹیویٹی کی اجازت دیں۔'],
    'grantPermission': ['Allow', 'اجازت دیں'],
    'sensorUnavailable': ['Sensor not available', 'سینسر دستیاب نہیں'],
    'sensorUnavailableBody': ['This device has no step counter sensor.', 'اس ڈیوائس میں قدم گننے والا سینسر نہیں ہے۔'],
    'trackingError': ['Could not read the step sensor.', 'قدم سینسر پڑھا نہیں جا سکا۔'],
    'retry': ['Retry', 'دوبارہ کوشش'],
    'noData': ['No data yet', 'ابھی کوئی ڈیٹا نہیں'],
    'average': ['Average', 'اوسط'],
    'best': ['Best', 'بہترین'],
    'weight': ['Weight (kg)', 'وزن (کلوگرام)'],
    'height': ['Height (cm)', 'قد (سینٹی میٹر)'],
    'language': ['Language', 'زبان'],
    'appearance': ['Appearance', 'ظاہری شکل'],
    'themeLight': ['Light', 'روشن'],
    'themeDark': ['Dark', 'تاریک'],
    'themeSystem': ['System', 'سسٹم'],
    'english': ['English', 'انگریزی'],
    'urdu': ['Urdu', 'اردو'],
    'save': ['Save', 'محفوظ کریں'],
    'saved': ['Saved', 'محفوظ ہو گیا'],
    'clearData': ['Clear all data', 'تمام ڈیٹا صاف کریں'],
    'clearDataConfirm': ['Delete all step history?', 'تمام قدم کی تاریخ حذف کریں؟'],
    'cancel': ['Cancel', 'منسوخ'],
    'delete': ['Delete', 'حذف کریں'],
    'profile': ['Profile', 'پروفائل'],
    'about': ['About', 'متعلق'],
    'aboutText': ['Steps, distance and calories are estimated from your device motion sensor. All data stays on this device.', 'قدم، فاصلہ اور کیلوریز کا اندازہ ڈیوائس کے موشن سینسر سے لگایا جاتا ہے۔ تمام ڈیٹا اسی ڈیوائس پر رہتا ہے۔'],
    'startSession': ['Start', 'شروع کریں'],
    'stopSession': ['Stop', 'روکیں'],
    'sessionInProgress': ['Session in progress', 'سیشن جاری ہے'],
    'noActiveSession': ['Press start to begin a session', 'سیشن شروع کرنے کے لیے اسٹارٹ دبائیں'],
    'sessions': ['Sessions', 'سیشنز'],
    'session': ['Session', 'سیشن'],
    'noSessions': ['No sessions for this day', 'اس دن کوئی سیشن نہیں'],
    'dayTotal': ['Day total', 'دن کا کل'],
    'duration': ['Duration', 'دورانیہ'],
    'tapForDetails': ['Tap a day to see sessions', 'سیشن دیکھنے کے لیے دن پر ٹیپ کریں'],
    'totalTime': ['Total time', 'کل وقت'],
    'live': ['Live', 'لائیو'],
    'total': ['Total', 'کل'],
    'totalSteps': ['Total Steps', 'کل قدم'],
  };

  String t(String key) {
    final entry = _data[key];
    if (entry == null) return key;
    return language == AppLanguage.ur ? entry[1] : entry[0];
  }
}
