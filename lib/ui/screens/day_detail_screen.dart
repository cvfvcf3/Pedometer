import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/formatting.dart';
import '../../core/utils/step_math.dart';
import '../../data/models/step_session.dart';
import '../../providers/pedometer_provider.dart';
import '../../providers/settings_provider.dart';

class DayDetailScreen extends StatefulWidget {
  const DayDetailScreen({super.key, required this.date});
  final String date;
  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  late Future<List<StepSession>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<PedometerProvider>().sessionsForDate(widget.date);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final strings = AppStrings(settings.language);
    final scheme = Theme.of(context).colorScheme;
    final label = formatDateLabel(parseDateKey(widget.date), urdu: settings.language == AppLanguage.ur);

    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: FutureBuilder<List<StepSession>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          final sessions = snapshot.data ?? const <StepSession>[];
          if (sessions.isEmpty) return Center(child: Text(strings.t('noSessions'), style: TextStyle(color: scheme.onSurfaceVariant)));

          final now = DateTime.now();
          final totalSteps = sessions.fold<int>(0, (sum, s) => sum + s.steps);
          final totalDuration = sessions.fold<Duration>(Duration.zero, (sum, s) => sum + s.durationUntil(now));
          final distanceKm = StepMath.distanceKm(totalSteps, settings.heightCm);
          final calories = StepMath.calories(totalSteps, settings.weightKg);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              _summaryCard(context, strings, totalSteps: totalSteps, totalDuration: totalDuration, distanceKm: distanceKm, calories: calories, count: sessions.length),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(strings.t('sessions'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant)),
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < sessions.length; i++) _sessionCard(context, strings, index: i + 1, session: sessions[i], now: now),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryCard(BuildContext context, AppStrings strings, {required int totalSteps, required Duration totalDuration, required double distanceKm, required double calories, required int count}) {
    final scheme = Theme.of(context).colorScheme;
    final faint = scheme.onSurface.withValues(alpha: 0.55);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.t('dayTotal'), style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(formatInt(totalSteps), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
              const SizedBox(width: 6),
              Text(strings.t('steps'), style: TextStyle(fontSize: 13, color: faint)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _tiny(context, strings.t('totalTime'), formatDuration(totalDuration))),
              Expanded(child: _tiny(context, strings.t('sessions'), '$count')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _tiny(context, strings.t('distance'), '${distanceKm.toStringAsFixed(2)} km')),
              Expanded(child: _tiny(context, strings.t('calories'), '${calories.toStringAsFixed(0)} kcal')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tiny(BuildContext context, String label, String value) {
    final faint = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: faint)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _sessionCard(BuildContext context, AppStrings strings, {required int index, required StepSession session, required DateTime now}) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;
    final faint = scheme.onSurface.withValues(alpha: 0.55);
    final startLabel = formatTimeOfDay(session.startTime);
    final endLabel = session.isActive ? strings.t('live') : formatTimeOfDay(session.endTime ?? session.startTime);
    final duration = session.durationUntil(now);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(context, radius: 14, borderColor: session.isActive ? scheme.primary : null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${strings.t('session')} $index', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              if (session.isActive) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: scheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(strings.t('live'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: scheme.primary)),
                ),
              ],
              const Spacer(),
              Text('${formatInt(session.steps)} ${strings.t('steps')}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: faint),
              const SizedBox(width: 4),
              Text('$startLabel  →  $endLabel', style: TextStyle(fontSize: 12, color: muted)),
              const Spacer(),
              Text(formatDuration(duration), style: TextStyle(fontSize: 12, color: faint)),
            ],
          ),
        ],
      ),
    );
  }
}
