import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = p.join(await getDatabasesPath(), 'step_tracker.db');
    _database = await openDatabase(
      path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade,
    );
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async => _createSessionsTable(db);

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createSessionsTable(db);
      await _migrateV1Totals(db);
    }
  }

  Future<void> _createSessionsTable(Database db) async {
    await db.execute('CREATE TABLE sessions (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT NOT NULL, started_at INTEGER NOT NULL, ended_at INTEGER, steps INTEGER NOT NULL DEFAULT 0)');
    await db.execute('CREATE INDEX idx_sessions_date ON sessions(date)');
  }

  Future<void> _migrateV1Totals(Database db) async {
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='steps'");
    if (tables.isEmpty) return;
    final rows = await db.query('steps');
    for (final row in rows) {
      final date = row['date'] as String?;
      final steps = (row['steps'] as int?) ?? 0;
      if (date == null || steps <= 0) continue;
      final day = DateTime.tryParse(date);
      if (day == null) continue;
      final start = day.millisecondsSinceEpoch;
      await db.insert('sessions', {'date': date, 'started_at': start, 'ended_at': start + 3600000, 'steps': steps});
    }
    await db.execute('DROP TABLE steps');
  }
}
