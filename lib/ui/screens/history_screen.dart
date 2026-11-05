import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/formatting.dart';
import '../../core/utils/step_math.dart';
import '../../data/models/daily_steps.dart';
import '../../providers/pedometer_provider.dart';
import '../../providers/settings_provider.dart';
import 'day_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) context.read<PedometerProvider>().loadHistory(); });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final pedometer = context.watch<PedometerProvider>();
    final strings = AppStrings(settings.language);
    final scheme = Theme.of(context).colorScheme;
    final history = pedometer.history;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: pedometer.loadHistory,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(strings.t('history'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(strings.t('tapForDetails'), style: TextStyle(fontSize: 12, color: scheme.onSurface.withValues(alpha: 0.55))),
            const SizedBox(height: 16),
            if (pedometer.historyLoading && history.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: CircularProgressIndicator()))
            else if (history.isEmpty)
              Padding(padding: const EdgeInsets.symmetric(vertical: 48), child: Center(child: Text(strings.t('noData'), style: TextStyle(color: scheme.onSurfaceVariant))))
            else ...[
              _buildSummary(context, strings, history),
              const SizedBox(height: 20),
              ...history.map((entry) => _buildRow(context, strings, settings, history, entry)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, AppStrings strings, List<DailySteps> history) {
    final total = history.fold<int>(0, (sum, entry) => sum + entry.steps);
    final average = history.isEmpty ? 0 : (total / history.length).round();
    final best = history.fold<int>(0, (max, entry) => entry.steps > max ? entry.steps : max);

    return Row(
      children: [
        Expanded(child: _summaryTile(context, strings.t('average'), formatInt(average))),
        const SizedBox(width: 10),
        Expanded(child: _summaryTile(context, strings.t('best'), formatInt(best))),
      ],
    );
  }

  Widget _summaryTile(BuildContext context, String label, String value) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: muted)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, AppStrings strings, SettingsProvider settings, List<DailySteps> history, DailySteps entry) {
    final scheme = Theme.of(context).colorScheme;
    final faint = scheme.onSurface.withValues(alpha: 0.55);
    final maxSteps = history.fold<int>(1, (max, item) => item.steps > max ? item.steps : max);
    final ratio = (entry.steps / maxSteps).clamp(0.0, 1.0).toDouble();
    final isToday = entry.date == dateKey(DateTime.now());
    final label = isToday ? strings.t('today') : formatDateLabel(parseDateKey(entry.date), urdu: settings.language == AppLanguage.ur);
    final distanceKm = StepMath.distanceKm(entry.steps, settings.heightCm);
    final calories = StepMath.calories(entry.steps, settings.weightKg);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DayDetailScreen(date: entry.date))),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: scheme.outlineVariant)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                    Text('${formatInt(entry.steps)} ${strings.t('steps')}', style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, size: 18, color: faint),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(value: ratio, minHeight: 8, backgroundColor: scheme.onSurface.withValues(alpha: 0.08), color: scheme.primary),
                ),
                const SizedBox(height: 8),
                Text('${distanceKm.toStringAsFixed(2)} km  •  ${calories.toStringAsFixed(0)} kcal', style: TextStyle(fontSize: 12, color: faint)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
