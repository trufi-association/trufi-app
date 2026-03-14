import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
  ];

  /// Display name for the standard offline map style
  ///
  /// In en, this message translates to:
  /// **'Standard (offline)'**
  String get mapStandardOffline;

  /// Description for the standard offline map style
  ///
  /// In en, this message translates to:
  /// **'Standard offline map'**
  String get mapStandardOfflineDesc;

  /// Display name for the light offline map style
  ///
  /// In en, this message translates to:
  /// **'Light (offline)'**
  String get mapLightOffline;

  /// Description for the light offline map style
  ///
  /// In en, this message translates to:
  /// **'Light offline map'**
  String get mapLightOfflineDesc;

  /// Display name for the dark offline map style
  ///
  /// In en, this message translates to:
  /// **'Dark (offline)'**
  String get mapDarkOffline;

  /// Description for the dark offline map style
  ///
  /// In en, this message translates to:
  /// **'Dark offline map'**
  String get mapDarkOfflineDesc;

  /// Display name for the colorful offline map style
  ///
  /// In en, this message translates to:
  /// **'Colorful (offline)'**
  String get mapColorfulOffline;

  /// Description for the colorful offline map style
  ///
  /// In en, this message translates to:
  /// **'Colorful offline map'**
  String get mapColorfulOfflineDesc;

  /// Display name for the light online map style
  ///
  /// In en, this message translates to:
  /// **'Light (online)'**
  String get mapLightOnline;

  /// Description for the light online map style
  ///
  /// In en, this message translates to:
  /// **'Light online map'**
  String get mapLightOnlineDesc;

  /// Display name for the standard online map style
  ///
  /// In en, this message translates to:
  /// **'Standard (online)'**
  String get mapStandardOnline;

  /// Description for the standard online map style
  ///
  /// In en, this message translates to:
  /// **'Standard online map'**
  String get mapStandardOnlineDesc;

  /// Display name for the dark online map style
  ///
  /// In en, this message translates to:
  /// **'Dark (online)'**
  String get mapDarkOnline;

  /// Description for the dark online map style
  ///
  /// In en, this message translates to:
  /// **'Dark online map'**
  String get mapDarkOnlineDesc;

  /// Display name for the colorful online map style
  ///
  /// In en, this message translates to:
  /// **'Colorful (online)'**
  String get mapColorfulOnline;

  /// Description for the colorful online map style
  ///
  /// In en, this message translates to:
  /// **'Colorful online map'**
  String get mapColorfulOnlineDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
