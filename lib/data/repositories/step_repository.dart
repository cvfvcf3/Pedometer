import '../local/app_database.dart';
import '../models/daily_steps.dart';
import '../models/step_session.dart';

class StepRepository {
  StepRepository({AppDatabase? database}) : _database = database ?? AppDatabase.instance;
  final AppDatabase _database;
  static const String _table = 'sessions';

  Future<int> startSession(String date, DateTime startedAt) async {
    final db = await _database.database;
    return db.insert(_table, {'date': date, 'started_at': startedAt.millisecondsSinceEpoch, 'ended_at': null, 'steps': 0});
  }

  Future<void> addStepsToSession(int sessionId, int delta) async {
    if (delta <= 0) return;
    final db = await _database.database;
    await db.rawUpdate('UPDATE $_table SET steps = steps + ? WHERE id = ?', [delta, sessionId]);
  }

  Future<void> endSession(int sessionId, DateTime endedAt) async {
    final db = await _database.database;
    await db.update(_table, {'ended_at': endedAt.millisecondsSinceEpoch}, where: 'id = ?', whereArgs: [sessionId]);
  }

  Future<void> closeOrphanedSessions() async {
    final db = await _database.database;
    await db.update(_table, {'ended_at': DateTime.now().millisecondsSinceEpoch}, where: 'ended_at IS NULL');
  }

  Future<int> stepsForDate(String date) async {
    final db = await _database.database;
    final rows = await db.rawQuery('SELECT COALESCE(SUM(steps), 0) AS total FROM $_table WHERE date = ?', [date]);
    if (rows.isEmpty) return 0;
    final total = rows.first['total'];
    return total is int ? total : (total is num ? total.toInt() : 0);
  }

  Future<List<StepSession>> sessionsForDate(String date) async {
    final db = await _database.database;
    final rows = await db.query(_table, where: 'date = ?', whereArgs: [date], orderBy: 'started_at ASC');
    return rows.map(StepSession.fromMap).toList();
  }

  Future<List<DailySteps>> lastDays(int count) async {
    final db = await _database.database;
    final rows = await db.rawQuery('SELECT date, SUM(steps) AS steps FROM $_table GROUP BY date ORDER BY date DESC LIMIT ?', [count]);
    return rows.map(DailySteps.fromMap).toList();
  }

  Future<void> clearAll() async {
    final db = await _database.database;
    await db.delete(_table);
  }
}
