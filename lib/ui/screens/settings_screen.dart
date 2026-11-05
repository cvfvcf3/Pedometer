import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/app_strings.dart';
import '../../providers/pedometer_provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _goalController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _weightController = TextEditingController(text: settings.weightKg.toStringAsFixed(0));
    _heightController = TextEditingController(text: settings.heightCm.toStringAsFixed(0));
    _goalController = TextEditingController(text: settings.dailyGoal.toString());
  }

  @override
  void dispose() {
    _weightController.dispose(); _heightController.dispose(); _goalController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final settings = context.read<SettingsProvider>();
    final weight = double.tryParse(_weightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final goal = int.tryParse(_goalController.text.trim());

    await settings.updateProfile(weightKg: weight, heightCm: height, dailyGoal: goal);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings(settings.language).t('saved'))));
  }

  Future<void> _confirmClear() async {
    final settings = context.read<SettingsProvider>();
    final pedometer = context.read<PedometerProvider>();
    final strings = AppStrings(settings.language);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.t('clearData')),
        content: Text(strings.t('clearDataConfirm')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(strings.t('cancel'))),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(strings.t('delete'))),
        ],
      ),
    );

    if (confirmed == true) await pedometer.clearAllData();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final strings = AppStrings(settings.language);
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text(strings.t('settings'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _Section(
            title: strings.t('language'),
            children: [
              SegmentedButton<AppLanguage>(
                segments: [
                  ButtonSegment<AppLanguage>(value: AppLanguage.en, label: Text(strings.t('english'))),
                  ButtonSegment<AppLanguage>(value: AppLanguage.ur, label: Text(strings.t('urdu'))),
                ],
                selected: {settings.language},
                onSelectionChanged: (selection) { if (selection.isNotEmpty) settings.setLanguage(selection.first); },
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Section(
            title: strings.t('appearance'),
            children: [
              Row(
                children: [
                  _themeOption(context, settings, ThemeMode.light, Icons.light_mode_outlined, strings.t('themeLight')),
                  const SizedBox(width: 8),
                  _themeOption(context, settings, ThemeMode.dark, Icons.dark_mode_outlined, strings.t('themeDark')),
                  const SizedBox(width: 8),
                  _themeOption(context, settings, ThemeMode.system, Icons.brightness_auto_outlined, strings.t('themeSystem')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Section(
            title: strings.t('profile'),
            children: [
              TextField(controller: _weightController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: strings.t('weight'), border: const OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: _heightController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: strings.t('height'), border: const OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: _goalController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: strings.t('dailyGoal'), helperText: strings.t('stepGoalHint'), border: const OutlineInputBorder())),
              const SizedBox(height: 14),
              SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, child: Text(strings.t('save')))),
            ],
          ),
          const SizedBox(height: 14),
          _Section(
            title: strings.t('about'),
            children: [Text(strings.t('aboutText'), style: TextStyle(fontSize: 13, height: 1.5, color: scheme.onSurfaceVariant))],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _confirmClear,
              icon: const Icon(Icons.delete_outline),
              label: Text(strings.t('clearData')),
              style: OutlinedButton.styleFrom(foregroundColor: scheme.error, side: BorderSide(color: scheme.error.withValues(alpha: 0.4)), padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeOption(BuildContext context, SettingsProvider settings, ThemeMode mode, IconData icon, String label) {
    final scheme = Theme.of(context).colorScheme;
    final selected = settings.themeMode == mode;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => settings.setThemeMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? scheme.primary.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? scheme.primary : scheme.outlineVariant),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: selected ? scheme.primary : scheme.onSurfaceVariant),
              const SizedBox(height: 6),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? scheme.primary : scheme.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: scheme.outlineVariant)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
