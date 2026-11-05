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
import '../widgets/permission_banner.dart';
import '../widgets/progress_ring.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final pedometer = context.watch<PedometerProvider>();
    final strings = AppStrings(settings.language);
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;

    final totalSteps = pedometer.todaySteps;
    final goal = settings.dailyGoal;
    final progress = goal > 0 ? totalSteps / goal : 0.0;
    final distanceKm = StepMath.distanceKm(totalSteps, settings.heightCm);
    final calories = StepMath.calories(totalSteps, settings.weightKg);

    final displayedSteps = pedometer.isSessionActive
        ? pedometer.activeSessionSteps
        : (pedometer.todaySessions.isNotEmpty ? pedometer.todaySessions.last.steps : 0);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: pedometer.init,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(strings.t('today'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(formatDateLabel(DateTime.now(), urdu: settings.language == AppLanguage.ur), style: TextStyle(fontSize: 13, color: muted)),
                    ],
                  ),
                ),
                Icon(Icons.directions_walk, size: 28, color: scheme.primary),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusBanner(context, strings, pedometer),
            Center(
              child: ProgressRing(
                progress: progress,
                progressColor: scheme.primary,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(formatInt(displayedSteps), style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w700, height: 1.0)),
                    ),
                    const SizedBox(height: 6),
                    Text(strings.t('steps'), style: TextStyle(fontSize: 14, color: muted)),
                    const SizedBox(height: 10),
                    Text('${strings.t('total')}: ${formatInt(totalSteps)} / ${formatInt(goal)}', style: TextStyle(fontSize: 12, color: scheme.onSurface.withValues(alpha: 0.55))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSessionCard(context, strings, pedometer),
            _buildTodaySessions(context, strings, settings, pedometer),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: StatCard(label: strings.t('totalSteps'), value: formatInt(totalSteps), unit: '', icon: Icons.directions_walk)),
                const SizedBox(width: 10),
                Expanded(child: StatCard(label: strings.t('distance'), value: distanceKm.toStringAsFixed(2), unit: 'km', icon: Icons.route)),
                const SizedBox(width: 10),
                Expanded(child: StatCard(label: strings.t('calories'), value: calories.toStringAsFixed(0), unit: 'kcal', icon: Icons.local_fire_department)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, AppStrings strings, PedometerProvider pedometer) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;
    final active = pedometer.isSessionActive;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(active ? Icons.play_circle_fill : Icons.pause_circle_outline, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(active ? strings.t('sessionInProgress') : strings.t('noActiveSession'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: muted)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (active) ...[
            Row(
              children: [
                Expanded(child: _miniStat(context, strings.t('duration'), formatDuration(pedometer.activeSessionDuration))),
                const SizedBox(width: 10),
                Expanded(child: _miniStat(context, strings.t('steps'), formatInt(pedometer.activeSessionSteps))),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => pedometer.stopSession(),
                icon: const Icon(Icons.stop_rounded),
                label: Text(strings.t('stopSession')),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), foregroundColor: scheme.error, side: BorderSide(color: scheme.error.withValues(alpha: 0.5))),
              ),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => pedometer.startSession(),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(strings.t('startSession')),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTodaySessions(BuildContext context, AppStrings strings, SettingsProvider settings, PedometerProvider pedometer) {
    final sessions = pedometer.todaySessions;
    if (sessions.isEmpty) return const SizedBox.shrink();
    final now = DateTime.now();
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(strings.t('sessions'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: muted)),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < sessions.length; i++) _sessionTile(context, strings, settings, index: i + 1, session: sessions[i], now: now),
      ],
    );
  }

  Widget _sessionTile(BuildContext context, AppStrings strings, SettingsProvider settings, {required int index, required StepSession session, required DateTime now}) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;
    final faint = scheme.onSurface.withValues(alpha: 0.55);
    final active = session.isActive;

    final startLabel = formatTimeOfDay(session.startTime);
    final endLabel = active ? strings.t('live') : formatTimeOfDay(session.endTime ?? session.startTime);
    final distanceKm = StepMath.distanceKm(session.steps, settings.heightCm);
    final calories = StepMath.calories(session.steps, settings.weightKg);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: AppTheme.cardDecoration(context, radius: 14, borderColor: active ? scheme.primary : null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${strings.t('session')} $index', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              if (active) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: scheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(strings.t('live'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: scheme.primary)),
                ),
              ],
              const Spacer(),
              Text('${formatInt(session.steps)} ${strings.t('steps')}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.schedule, size: 13, color: faint),
              const SizedBox(width: 4),
              Text('$startLabel → $endLabel', style: TextStyle(fontSize: 11, color: muted)),
              const Spacer(),
              Text(formatDuration(session.durationUntil(now)), style: TextStyle(fontSize: 11, color: faint)),
            ],
          ),
          const SizedBox(height: 6),
          Text('${distanceKm.toStringAsFixed(2)} km  •  ${calories.toStringAsFixed(0)} kcal', style: TextStyle(fontSize: 11, color: faint)),
        ],
      ),
    );
  }

  Widget _miniStat(BuildContext context, String label, String value) {
    final faint = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: faint)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildStatusBanner(BuildContext context, AppStrings strings, PedometerProvider pedometer) {
    switch (pedometer.status) {
      case TrackingStatus.permissionDenied:
        return PermissionBanner(title: strings.t('permissionTitle'), message: strings.t('permissionBody'), actionLabel: strings.t('grantPermission'), onAction: () => pedometer.requestPermission());
      case TrackingStatus.sensorUnavailable:
        return PermissionBanner(title: strings.t('sensorUnavailable'), message: strings.t('sensorUnavailableBody'));
      case TrackingStatus.error:
        return PermissionBanner(title: strings.t('trackingError'), message: pedometer.errorMessage ?? strings.t('trackingError'), actionLabel: strings.t('retry'), onAction: () => pedometer.init());
      case TrackingStatus.loading:
      case TrackingStatus.running:
        return const SizedBox.shrink();
    }
  }
}
