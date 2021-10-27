import 'package:trufi_core/blocs/configuration/configuration.dart';
import 'package:trufi_core/blocs/configuration/models/animation_configuration.dart';
import 'package:trufi_core/blocs/configuration/models/language_configuration.dart';
import 'package:trufi_core/blocs/configuration/models/map_configuration.dart';
import 'package:trufi_core/blocs/configuration/models/url_collection.dart';

import 'package:latlong2/latlong.dart';
import 'package:trufi_core/models/definition_feedback.dart';
import 'package:trufi_core/models/enums/server_type.dart';

Configuration setupConfiguration() {
  // Urls
  final urls = UrlCollection(
    openTripPlannerUrl: "https://cbba.trufi.dev/otp",
    routeFeedbackUrl: "https://trufifeedback.z15.web.core.windows.net/route.html",
  );

  // Map
  final map = MapConfiguration(
    defaultZoom: 12.0,
    offlineMinZoom: 8.0,
    offlineMaxZoom: 14.0,
    offlineZoom: 13.0,
    onlineMinZoom: 1.0,
    onlineMaxZoom: 19.0,
    onlineZoom: 13.0,
    chooseLocationZoom: 16.0,
    center:LatLng(-17.39000, -66.15400),
    southWest: LatLng(-17.79300, -66.75000),
    northEast: LatLng(-16.90400, -65.67400),
  );

  // Languages
  final languages = [
    LanguageConfiguration("de", "DE", "Deutsch"),
    LanguageConfiguration("en", "US", "English", isDefault: true),
    LanguageConfiguration("es", "ES", "Español"),
    LanguageConfiguration("fr", "FR", "Français"),
    LanguageConfiguration("it", "IT", "Italiano"),
    LanguageConfiguration("qu", "BO", "Quechua simi"),
  ];

  final customTranslations = TrufiCustomLocalizations();
    // ..title = {
    //   const Locale("de"): "BusBoy App",
    //   const Locale("en"): "BusBoy App",
    //   const Locale("es"): "BusBoy App",
    //   const Locale("fr"): "BusBoy App",
    //   const Locale("it"): "BusBoy App",
    //   const Locale("qu"): "BusBoy App",
    // };

  return Configuration(
    appCity: "Cochabamba",
    customTranslations: customTranslations,
    supportedLanguages: languages,
    teamInformationEmail: "info@trufi.app",
    animations: AnimationConfiguration(),
    feedbackDefinition: FeedbackDefinition(
      FeedBackType.email,
      "feedback@trufi.app",
    ),
    serverType: ServerType.graphQLServer,
    // showAdvancedOptions: true,
    map: map,
    urls: urls,
    showWeather: false,
  );
}
