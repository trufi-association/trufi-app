import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_about/trufi_core_about.dart';
import 'package:trufi_core_fares/trufi_core_fares.dart';
import 'package:trufi_core_feedback/trufi_core_feedback.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_navigation/trufi_core_navigation.dart';
import 'package:trufi_core_poi_layers/trufi_core_poi_layers.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart'
    show
        RoutingEngineManager,
        IRoutingProvider,
        Otp28RoutingProvider,
        Otp15RoutingProvider,
        TrufiPlannerProvider,
        TrufiPlannerConfig;
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';
import 'package:trufi_core_settings/trufi_core_settings.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';
import 'package:trufi_core_ui/trufi_core_ui.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart' show OverlayManager;

import 'l10n/app_localizations.dart';

// ============ CONFIGURATION ============
// From input/domains.txt
const _photonUrl = 'https://photon.trufi.app';
const _otp281Endpoint = 'https://otp281.trufi.app';
const _otp150Endpoint = 'https://otp150.trufi.app';

// App configuration
const _defaultCenter = LatLng(-17.3988354, -66.1626903);
const _appName = 'Trufi Cochabamba';
const _deepLinkScheme = 'trufiapp';
const _cityName = 'Cochabamba';
const _countryName = 'Bolivia';
const _emailContact = 'feedback@trufi.app';
const _feedbackUrl = 'https://forms.gle/QMLhJT7N44Bh9zBN6';
const _facebookUrl = 'https://www.facebook.com/trufiapp/';
const _instagramUrl = 'https://www.instagram.com/trufi.app';
const _whatsappUrl = 'https://wa.me/59167835296';
const _shareUrl = 'https://www.trufi.app/';

// Routing engines
final List<IRoutingProvider> _routingEngines = [
  // Offline routing via GTFS (mobile) / online via server (web)
  if (!kIsWeb)
    TrufiPlannerProvider(
      config: const TrufiPlannerConfig.local(
        gtfsAsset: 'assets/routing/cochabamba.gtfs.zip',
      ),
    ),
  if (kIsWeb)
    TrufiPlannerProvider(
      config: const TrufiPlannerConfig.remote(
        serverUrl: '/api',
      ),
    ),
  // Online routing via OTP 2.8.1
  Otp28RoutingProvider(
    endpoint: _otp281Endpoint,
    displayName: 'OTP 2.8.1',
    showWheelchairOption: false,
    showBicycleOption: false,
  ),
  // Online routing via OTP 1.5.0
  Otp15RoutingProvider(
    endpoint: _otp150Endpoint,
    displayName: 'OTP 1.5.0',
    showWheelchairOption: false,
  ),
];

// Map engines
final List<ITrufiMapEngine> _mapEngines = [
  // Offline maps - disabled on web
  if (!kIsWeb)
    OfflineMapLibreEngine(
      engineId: 'offline_osm_liberty',
      nameBuilder: (ctx) => AppLocalizations.of(ctx)!.mapStandardOffline,
      descriptionBuilder: (ctx) =>
          AppLocalizations.of(ctx)!.mapStandardOfflineDesc,
      config: OfflineMapConfig(
        mbtilesAsset: 'assets/offline/cochabamba.mbtiles',
        styleAsset: 'assets/offline/styles/osm-liberty/style.json',
        spritesAssetDir: 'assets/offline/styles/osm-liberty/',
        fontsAssetDir: 'assets/offline/fonts/',
        fontMapping: {
          'RobotoRegular': 'Roboto Regular',
          'RobotoMedium': 'Roboto Medium',
          'RobotoCondensedItalic': 'Roboto Condensed Italic',
        },
        fontRanges: [
          '0-255',
          '256-511',
          '512-767',
          '768-1023',
          '1024-1279',
          '1280-1535',
          '8192-8447',
          '8448-8703',
        ],
      ),
    ),
  if (!kIsWeb)
    OfflineMapLibreEngine(
      engineId: 'offline_osm_bright',
      nameBuilder: (ctx) => AppLocalizations.of(ctx)!.mapLightOffline,
      descriptionBuilder: (ctx) =>
          AppLocalizations.of(ctx)!.mapLightOfflineDesc,
      config: OfflineMapConfig(
        mbtilesAsset: 'assets/offline/cochabamba.mbtiles',
        styleAsset: 'assets/offline/styles/osm-bright/style.json',
        spritesAssetDir: 'assets/offline/styles/osm-bright/',
        fontsAssetDir: 'assets/offline/fonts/',
        fontMapping: {
          'OpenSansRegular': 'Open Sans Regular',
          'OpenSansBold': 'Open Sans Bold',
          'OpenSansItalic': 'Open Sans Italic',
        },
        fontRanges: [
          '0-255',
          '256-511',
          '512-767',
          '768-1023',
          '1024-1279',
          '1280-1535',
          '8192-8447',
          '8448-8703',
        ],
      ),
    ),
  if (!kIsWeb)
    OfflineMapLibreEngine(
      engineId: 'offline_dark_matter',
      nameBuilder: (ctx) => AppLocalizations.of(ctx)!.mapDarkOffline,
      descriptionBuilder: (ctx) => AppLocalizations.of(ctx)!.mapDarkOfflineDesc,
      config: OfflineMapConfig(
        mbtilesAsset: 'assets/offline/cochabamba.mbtiles',
        styleAsset: 'assets/offline/styles/dark-matter/style.json',
        spritesAssetDir: 'assets/offline/styles/dark-matter/',
        fontsAssetDir: 'assets/offline/fonts/',
        fontMapping: {
          'MetropolisLight': 'Metropolis Light',
          'MetropolisLightItalic': 'Metropolis Light Italic',
          'MetropolisRegular': 'Metropolis Regular',
          'MetropolisMediumItalic': 'Metropolis Medium Italic',
          'NotoSansRegular': 'Noto Sans Regular',
          'NotoSansItalic': 'Noto Sans Italic',
        },
        fontRanges: [
          '0-255',
          '256-511',
          '512-767',
          '768-1023',
          '1024-1279',
          '1280-1535',
          '8192-8447',
          '8448-8703',
        ],
      ),
    ),
  if (!kIsWeb)
    OfflineMapLibreEngine(
      engineId: 'offline_fiord_color',
      nameBuilder: (ctx) => AppLocalizations.of(ctx)!.mapColorfulOffline,
      descriptionBuilder: (ctx) =>
          AppLocalizations.of(ctx)!.mapColorfulOfflineDesc,
      config: OfflineMapConfig(
        mbtilesAsset: 'assets/offline/cochabamba.mbtiles',
        styleAsset: 'assets/offline/styles/fiord-color/style.json',
        spritesAssetDir: 'assets/offline/styles/fiord-color/',
        fontsAssetDir: 'assets/offline/fonts/',
        fontMapping: {
          'MetropolisLight': 'Metropolis Light',
          'MetropolisLightItalic': 'Metropolis Light Italic',
          'MetropolisRegular': 'Metropolis Regular',
          'MetropolisMediumItalic': 'Metropolis Medium Italic',
          'NotoSansRegular': 'Noto Sans Regular',
          'NotoSansItalic': 'Noto Sans Italic',
        },
        fontRanges: [
          '0-255',
          '256-511',
          '512-767',
          '768-1023',
          '1024-1279',
          '1280-1535',
          '8192-8447',
          '8448-8703',
        ],
      ),
    ),
  // Online maps - from input/domains.txt
  MapLibreEngine(
    engineId: 'osm_bright',
    styleString: 'https://maps.trufi.app/styles/osm-bright/style.json',
    nameBuilder: (ctx) => AppLocalizations.of(ctx)!.mapLightOnline,
    descriptionBuilder: (ctx) => AppLocalizations.of(ctx)!.mapLightOnlineDesc,
  ),
  MapLibreEngine(
    engineId: 'osm_liberty',
    styleString: 'https://maps.trufi.app/styles/osm-liberty/style.json',
    nameBuilder: (ctx) => AppLocalizations.of(ctx)!.mapStandardOnline,
    descriptionBuilder: (ctx) =>
        AppLocalizations.of(ctx)!.mapStandardOnlineDesc,
  ),
  MapLibreEngine(
    engineId: 'dark_matter',
    styleString: 'https://maps.trufi.app/styles/dark-matter/style.json',
    nameBuilder: (ctx) => AppLocalizations.of(ctx)!.mapDarkOnline,
    descriptionBuilder: (ctx) => AppLocalizations.of(ctx)!.mapDarkOnlineDesc,
  ),
  MapLibreEngine(
    engineId: 'fiord_color',
    styleString: 'https://maps.trufi.app/styles/fiord-color/style.json',
    nameBuilder: (ctx) => AppLocalizations.of(ctx)!.mapColorfulOnline,
    descriptionBuilder: (ctx) =>
        AppLocalizations.of(ctx)!.mapColorfulOnlineDesc,
  ),
];
// ========================================

void main() {
  runTrufiApp(
    AppConfiguration(
      appName: _appName,
      deepLinkScheme: _deepLinkScheme,
      defaultLocale: const Locale('es'),
      // Cochabamba's bus network only runs roughly 06:00–22:00.
      // Pinning the routing request to midday avoids "0 routes" when
      // the user opens the app late at night, and the picker UI is
      // hidden because the value is fixed.
      routingTimeOverride: const TimeOfDay(hour: 12, minute: 0),
      extraLocalizationsDelegates: [AppLocalizations.delegate],
      themeConfig: TrufiThemeConfig(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE1306C)),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE1306C),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
      ),
      socialMediaLinks: [
        SocialMediaLink(
          url: _facebookUrl,
          icon: SocialMediaPreset.facebook.icon,
          label: 'Facebook',
        ),
        SocialMediaLink(
          url: _instagramUrl,
          icon: SocialMediaPreset.instagram.icon,
          label: 'Instagram',
        ),
        SocialMediaLink(
          url: _whatsappUrl,
          icon: SocialMediaPreset.whatsapp.icon,
          label: 'WhatsApp',
        ),
      ],
      providers: [
        ChangeNotifierProvider(
          create: (_) => MapEngineManager(
            engines: _mapEngines,
            defaultCenter: _defaultCenter,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RoutingEngineManager(engines: _routingEngines),
        ),
        ChangeNotifierProvider(
          create: (_) => OverlayManager(
            managers: [
              OnboardingManager(
                overlayBuilder: (onComplete) =>
                    OnboardingSheet(onComplete: onComplete),
              ),
              PrivacyConsentManager(
                overlayBuilder: (onAccept, onDecline) => PrivacyConsentSheet(
                  onAccept: onAccept,
                  onDecline: onDecline,
                ),
              ),
            ],
          ),
        ),
        BlocProvider(
          create: (_) => SearchLocationsCubit(
            searchLocationService: PhotonSearchService(
              baseUrl: _photonUrl,
              biasLatitude: _defaultCenter.latitude,
              biasLongitude: _defaultCenter.longitude,
            ),
          ),
        ),
      ],
      screens: [
        HomeScreenTrufiScreen(
          config: HomeScreenConfig(
            appName: _appName,
            deepLinkScheme: _deepLinkScheme,
            poiLayersManager: POILayersManager(assetsBasePath: 'assets/pois'),
          ),
          onStartNavigation: (context, itinerary, locationService) {
            NavigationScreen.showFromItinerary(
              context,
              itinerary: itinerary,
              locationService: locationService,
              mapEngineManager: MapEngineManager.read(context),
            );
          },
          onRouteTap: (context, routeCode) {
            TransportDetailScreen.show(context, routeCode: routeCode);
          },
        ),
        SavedPlacesTrufiScreen(),
        TransportListTrufiScreen(),
        FaresTrufiScreen(
          config: FaresConfig(
            currency: 'Bs.',
            lastUpdated: DateTime(2026, 5, 6),
            additionalNotes:
                'Tarifa provisional vigente para servicios urbanos dentro '
                'del Cercado. El monto cobrado en algunos operadores puede '
                'diferir.',
            fares: const [
              FareInfo(
                title: 'Pasaje urbano (Cercado)',
                icon: Icons.directions_bus_rounded,
                primary: FareCategory(
                  label: 'Usuarios en general',
                  price: '3.00',
                  icon: Icons.person_rounded,
                ),
                additional: [
                  FareCategory(
                    label: 'Estudiante sec./universitario',
                    price: '2.00',
                    icon: Icons.school_rounded,
                  ),
                  FareCategory(
                    label: 'Estudiante de primaria',
                    price: '1.00',
                    icon: Icons.child_care_rounded,
                  ),
                  FareCategory(
                    label: 'Adulto mayor',
                    price: '2.50',
                    icon: Icons.elderly_rounded,
                  ),
                  FareCategory(
                    label: 'Persona con discapacidad',
                    price: '2.50',
                    icon: Icons.accessible_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
        FeedbackTrufiScreen(config: FeedbackConfig(feedbackUrl: _feedbackUrl)),
        SettingsTrufiScreen(),
        AboutTrufiScreen(
          config: AboutScreenConfig(
            appName: _appName,
            cityName: _cityName,
            countryName: _countryName,
            emailContact: _emailContact,
          ),
        ),
      ],
    ),
  );
}
