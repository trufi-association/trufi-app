import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'trufi_app_localizations_de.dart';
import 'trufi_app_localizations_en.dart';
import 'trufi_app_localizations_es.dart';
import 'trufi_app_localizations_pt.dart';

/// Callers can lookup localized strings with an instance of TrufiAppLocalization
/// returned by `TrufiAppLocalization.of(context)`.
///
/// Applications need to include `TrufiAppLocalization.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'translations/trufi_app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: TrufiAppLocalization.localizationsDelegates,
///   supportedLocales: TrufiAppLocalization.supportedLocales,
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
/// be consistent with the languages listed in the TrufiAppLocalization.supportedLocales
/// property.
abstract class TrufiAppLocalization {
  TrufiAppLocalization(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static TrufiAppLocalization of(BuildContext context) {
    return Localizations.of<TrufiAppLocalization>(context, TrufiAppLocalization)!;
  }

  static const LocalizationsDelegate<TrufiAppLocalization> delegate = _TrufiAppLocalizationDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
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
    Locale('pt')
  ];

  /// No description provided for @menuFaresGuidelines.
  ///
  /// In pt, this message translates to:
  /// **'Tarifas e diretrizes'**
  String get menuFaresGuidelines;

  /// No description provided for @guidelinesTypePassengerOlder.
  ///
  /// In pt, this message translates to:
  /// **'Pessoas idosas'**
  String get guidelinesTypePassengerOlder;

  /// No description provided for @guidelinesTypePassengerSeniorCitizen.
  ///
  /// In pt, this message translates to:
  /// **'Cidadão sênior'**
  String get guidelinesTypePassengerSeniorCitizen;

  /// No description provided for @guidelinesTypePassengerDisabled.
  ///
  /// In pt, this message translates to:
  /// **'Deficientes'**
  String get guidelinesTypePassengerDisabled;

  /// No description provided for @guidelinesTypePassengerUniversityStudents.
  ///
  /// In pt, this message translates to:
  /// **'Estudantes universitários'**
  String get guidelinesTypePassengerUniversityStudents;

  /// No description provided for @guidelinesTypePassengerPrimarySecondaryStudents.
  ///
  /// In pt, this message translates to:
  /// **'Estudantes do ensino fundamental e médio'**
  String get guidelinesTypePassengerPrimarySecondaryStudents;

  /// No description provided for @guidelinesTypePassengerMeritorious.
  ///
  /// In pt, this message translates to:
  /// **'Meritórios'**
  String get guidelinesTypePassengerMeritorious;

  /// No description provided for @guidelinesTypePassengerChildrenUnderFive.
  ///
  /// In pt, this message translates to:
  /// **'Crianças com menos de 5 anos de idade'**
  String get guidelinesTypePassengerChildrenUnderFive;

  /// No description provided for @guidelinesTypePassengerStudents.
  ///
  /// In pt, this message translates to:
  /// **'Estudantes'**
  String get guidelinesTypePassengerStudents;

  /// No description provided for @guidelinesExemptPay.
  ///
  /// In pt, this message translates to:
  /// **'Isento de pagamento'**
  String get guidelinesExemptPay;

  /// No description provided for @guidelinesIntroduction.
  ///
  /// In pt, this message translates to:
  /// **'Aqui você encontrará informações importantes e dicas úteis para ajudá-lo a aproveitar ao máximo sua experiência com o transporte público.'**
  String get guidelinesIntroduction;

  /// No description provided for @guidelinesClarification.
  ///
  /// In pt, this message translates to:
  /// **'É importante observar que, como o transporte público em Cochabamba é principalmente informal e não tem horários fixos, o aplicativo fornece dados com base em horários pré-estabelecidos. O aplicativo fornece dados com base em horários e rotas pré-estabelecidos, que podem ter variações nos horários de chegada e nas rotas.'**
  String get guidelinesClarification;

  /// No description provided for @guidelinesFareCost.
  ///
  /// In pt, this message translates to:
  /// **'Custo da tarifa'**
  String get guidelinesFareCost;

  /// No description provided for @guidelinesTransitFare.
  ///
  /// In pt, this message translates to:
  /// **'Tarifa de Trufis, Micros e Microônibus'**
  String get guidelinesTransitFare;

  /// No description provided for @guidelinesTransitFareIntroduction.
  ///
  /// In pt, this message translates to:
  /// **'De acordo com o Decreto Municipal nº 003/2014, você tem a seguinte tabela de tarifas:'**
  String get guidelinesTransitFareIntroduction;

  /// No description provided for @guidelinesTransitFareClarification.
  ///
  /// In pt, this message translates to:
  /// **'Entretanto, em algumas ocasiões, essa tarifa não é respeitada e é arredondada para 2 Bs.'**
  String get guidelinesTransitFareClarification;

  /// No description provided for @guidelinesMetropolitanFare.
  ///
  /// In pt, this message translates to:
  /// **'Tarifa para o eixo metropolitano'**
  String get guidelinesMetropolitanFare;

  /// No description provided for @guidelinesMetropolitanFareIntroduction.
  ///
  /// In pt, this message translates to:
  /// **'Para seções intermunicipais do eixo metropolitano, aplicam-se as tarifas estabelecidas pelo Decreto Departamental 1399:'**
  String get guidelinesMetropolitanFareIntroduction;

  /// No description provided for @guidelinesMetropolitanFareClarification.
  ///
  /// In pt, this message translates to:
  /// **'Exceções: A partir das 22h, o horário noturno está em vigor, com um aumento de Bs 0,50 tanto no eixo urbano quanto no intermunicipais. Em alguns casos, a tarifa também varia dependendo da seção da rota, aumentando ou diminuindo em Bs 0,50, conforme detalhado nas tabelas. Em todo caso, se não tiver certeza, pergunte ao motorista ou a outro passageiro.'**
  String get guidelinesMetropolitanFareClarification;

  /// No description provided for @guidelinesPublicTransportation.
  ///
  /// In pt, this message translates to:
  /// **'Como usar o transporte público '**
  String get guidelinesPublicTransportation;

  /// No description provided for @guidelinesPublicTransportationDescription.
  ///
  /// In pt, this message translates to:
  /// **'Se você for de trufi, pagará quando descer e quando subir. Você pode descer ou parar onde quiser, mas tente fazê-lo quando o semáforo estiver vermelho para evitar congestionamentos e avise o motorista com antecedência.'**
  String get guidelinesPublicTransportationDescription;

  /// No description provided for @guidelinesStops.
  ///
  /// In pt, this message translates to:
  /// **'Paradas'**
  String get guidelinesStops;

  /// No description provided for @guidelinesStopsDescription.
  ///
  /// In pt, this message translates to:
  /// **'Os trufis têm paradas de rota nos destinos finais (localidades), paradas no centro da cidade que podem ser intermediárias (ruas do centro) ou circuitos. Os ônibus intermunicipais têm paradas fixas (Chapare, Tarata, Cliza, Punata, etc.).'**
  String get guidelinesStopsDescription;

  /// No description provided for @guidelinesRouteIdentifiers.
  ///
  /// In pt, this message translates to:
  /// **'Identificadores de rota'**
  String get guidelinesRouteIdentifiers;

  /// No description provided for @typeOfVehicleMicro.
  ///
  /// In pt, this message translates to:
  /// **'Ônibus'**
  String get typeOfVehicleMicro;

  /// No description provided for @typeOfVehicleMinibus.
  ///
  /// In pt, this message translates to:
  /// **'Microônibus'**
  String get typeOfVehicleMinibus;

  /// No description provided for @layerGroupLeisure.
  ///
  /// In pt, this message translates to:
  /// **'Lazer e Entretenimento'**
  String get layerGroupLeisure;

  /// No description provided for @layerGroupTravel.
  ///
  /// In pt, this message translates to:
  /// **'Viagens'**
  String get layerGroupTravel;

  /// No description provided for @layerGroupEducation.
  ///
  /// In pt, this message translates to:
  /// **'Educação'**
  String get layerGroupEducation;

  /// No description provided for @layerGroupHealthServices.
  ///
  /// In pt, this message translates to:
  /// **'Serviços de Saúde'**
  String get layerGroupHealthServices;

  /// No description provided for @layerAttractionsAndMonuments.
  ///
  /// In pt, this message translates to:
  /// **'Atrações e Monumentos'**
  String get layerAttractionsAndMonuments;

  /// No description provided for @layerParksAndSquares.
  ///
  /// In pt, this message translates to:
  /// **'Parques e Praças'**
  String get layerParksAndSquares;

  /// No description provided for @layerCinemas.
  ///
  /// In pt, this message translates to:
  /// **'Cinemas'**
  String get layerCinemas;

  /// No description provided for @layerPharmacies.
  ///
  /// In pt, this message translates to:
  /// **'Farmácias'**
  String get layerPharmacies;

  /// No description provided for @layerHospitals.
  ///
  /// In pt, this message translates to:
  /// **'Hospitais'**
  String get layerHospitals;

  /// No description provided for @layerSchools.
  ///
  /// In pt, this message translates to:
  /// **'Escolas'**
  String get layerSchools;

  /// No description provided for @layerInstitutes.
  ///
  /// In pt, this message translates to:
  /// **'Institutos'**
  String get layerInstitutes;

  /// No description provided for @layerShoppingCentersAndSupermarkets.
  ///
  /// In pt, this message translates to:
  /// **'Centros Comerciais e Supermercados'**
  String get layerShoppingCentersAndSupermarkets;

  /// No description provided for @layerInterprovincialStops.
  ///
  /// In pt, this message translates to:
  /// **'Paragens Interprovinciais'**
  String get layerInterprovincialStops;

  /// No description provided for @layerStadiumsAndSportsComplexes.
  ///
  /// In pt, this message translates to:
  /// **'Estádios e Complexos Desportivos'**
  String get layerStadiumsAndSportsComplexes;

  /// No description provided for @layerLibraries.
  ///
  /// In pt, this message translates to:
  /// **'Bibliotecas'**
  String get layerLibraries;

  /// No description provided for @layerTerminalsAndStations.
  ///
  /// In pt, this message translates to:
  /// **'Terminais e Estações'**
  String get layerTerminalsAndStations;

  /// No description provided for @layerMuseumsAndArtGalleries.
  ///
  /// In pt, this message translates to:
  /// **'Museus e Galerias de Arte'**
  String get layerMuseumsAndArtGalleries;

  /// No description provided for @layerUniversities.
  ///
  /// In pt, this message translates to:
  /// **'Universidades'**
  String get layerUniversities;

  /// No description provided for @guidelinesRouteIdentifiersDescription.
  ///
  /// In pt, this message translates to:
  /// **'Há muitas linhas que têm variantes e, para diferenciá-las, adicionam mais um identificador: uma bandeira colorida, um painel de cor diferente, um número de cor diferente, uma letra extra e a rota final inscrita no painel. Por exemplo: 108 com bandeira branca tem como destino a Av. Humberto Asín, na divisa com o Barrio Entre Rios, e 108 Pisiga com bandeira amarela tem como destino a Av. Humberto Asín, na divisa com o Barrio Entre Rios. Pisiga.'**
  String get guidelinesRouteIdentifiersDescription;
}

class _TrufiAppLocalizationDelegate extends LocalizationsDelegate<TrufiAppLocalization> {
  const _TrufiAppLocalizationDelegate();

  @override
  Future<TrufiAppLocalization> load(Locale locale) {
    return SynchronousFuture<TrufiAppLocalization>(lookupTrufiAppLocalization(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_TrufiAppLocalizationDelegate old) => false;
}

TrufiAppLocalization lookupTrufiAppLocalization(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return TrufiAppLocalizationDe();
    case 'en': return TrufiAppLocalizationEn();
    case 'es': return TrufiAppLocalizationEs();
    case 'pt': return TrufiAppLocalizationPt();
  }

  throw FlutterError(
    'TrufiAppLocalization.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
