// Settings: language (AR/FR/EN), unit (°C/°F), theme,
// about section with version, privacy policy entry.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mar_weather/core/utils/temperature.dart';
import 'package:mar_weather/l10n/app_localizations.dart';
import 'package:mar_weather/providers/providers.dart';

/// Displayed in Settings → About. Mirrors pubspec `version: 1.0.0+1`.
const String appVersion = '1.0.0';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String lang = Localizations.localeOf(context).languageCode;
    final TempUnit unit = ref.watch(unitProvider);
    final ThemeMode themeMode = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: <Widget>[
          _SectionTitle(l10n.language),
          RadioGroup<String>(
            groupValue: lang,
            onChanged: (String? value) {
              if (value != null) {
                ref.read(languageProvider.notifier).set(value);
              }
            },
            child: Column(
              children: <Widget>[
                RadioListTile<String>(
                  title: const Text('العربية'),
                  value: 'ar',
                ),
                RadioListTile<String>(
                  title: const Text('Français'),
                  value: 'fr',
                ),
                RadioListTile<String>(
                  title: const Text('English'),
                  value: 'en',
                ),
              ],
            ),
          ),
          _SectionTitle(l10n.unit),
          RadioGroup<TempUnit>(
            groupValue: unit,
            onChanged: (TempUnit? value) {
              if (value != null) {
                ref.read(unitProvider.notifier).set(value);
              }
            },
            child: Column(
              children: <Widget>[
                RadioListTile<TempUnit>(
                  title: Text(l10n.celsius),
                  value: TempUnit.celsius,
                ),
                RadioListTile<TempUnit>(
                  title: Text(l10n.fahrenheit),
                  value: TempUnit.fahrenheit,
                ),
              ],
            ),
          ),
          _SectionTitle(l10n.theme),
          RadioGroup<ThemeMode>(
            groupValue: themeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                ref.read(themeProvider.notifier).set(value);
              }
            },
            child: Column(
              children: <Widget>[
                RadioListTile<ThemeMode>(
                  title: Text(l10n.themeSystem),
                  value: ThemeMode.system,
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.themeLight),
                  value: ThemeMode.light,
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.themeDark),
                  value: ThemeMode.dark,
                ),
              ],
            ),
          ),
          _SectionTitle(l10n.about),
          ListTile(
            title: Text(l10n.version(appVersion)),
            subtitle: Text(l10n.aboutText),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyTitle),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => context.push('/privacy'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
