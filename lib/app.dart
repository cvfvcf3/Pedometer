import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/l10n/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'ui/screens/history_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/settings_screen.dart';

class PedometerApp extends StatelessWidget {
  const PedometerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final strings = AppStrings(settings.language);

    return MaterialApp(
      title: strings.t('appTitle'),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      locale: Locale(settings.language.code),
      supportedLocales: const [Locale('en'), Locale('ur')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: settings.language.isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(context.watch<SettingsProvider>().language);

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [HomeScreen(), HistoryScreen(), SettingsScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.directions_walk), label: strings.t('home')),
          NavigationDestination(icon: const Icon(Icons.bar_chart), label: strings.t('history')),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), label: strings.t('settings')),
        ],
      ),
    );
  }
}
