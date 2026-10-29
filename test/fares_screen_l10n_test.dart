import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi/l10n/app_localizations.dart';
import 'package:trufi/main.dart';
import 'package:trufi_core_fares/trufi_core_fares.dart';

/// trufi-core#1002: the Cochabamba fare cards and the tips card follow the
/// app language instead of staying in Spanish. Drives the real
/// [cochabambaFaresConfig] through [FaresTrufiScreen].
Widget _host(Locale locale) {
  final screen = FaresTrufiScreen(config: cochabambaFaresConfig);
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: [
      AppLocalizations.delegate,
      ...screen.localizationsDelegates,
      ...GlobalMaterialLocalizations.delegates,
    ],
    home: Scaffold(body: Builder(builder: screen.builder)),
  );
}

/// Every app-provided string on the screen, as the given locale renders it.
List<String> _fareStrings(AppLocalizations l10n) => [
  l10n.faresUrbanCercadoTitle,
  l10n.faresGeneralUsers,
  l10n.faresSecondaryUniversityStudent,
  l10n.faresPrimaryStudent,
  l10n.faresSenior,
  l10n.faresDisability,
  l10n.faresCercadoNotes,
];

void main() {
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('renders every fare string in $locale', (tester) async {
      await tester.pumpWidget(_host(locale));
      await tester.pumpAndSettle();

      for (final text in _fareStrings(lookupAppLocalizations(locale))) {
        expect(find.text(text), findsOneWidget, reason: '$locale: $text');
      }
    });
  }

  testWidgets('English shows none of the Spanish fallbacks', (tester) async {
    await tester.pumpWidget(_host(const Locale('en')));
    await tester.pumpAndSettle();

    final spanish = lookupAppLocalizations(const Locale('es'));
    for (final text in _fareStrings(spanish)) {
      expect(find.text(text), findsNothing, reason: text);
    }
  });
}
