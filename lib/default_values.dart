import 'package:async_executor/async_executor.dart';
import 'package:flutter/material.dart';
import 'package:pf_user_tracking/tools/location.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi/pages/fares_guidelines/fares_guidelines.dart';

import 'package:trufi/pages/feedback.dart';
import 'package:trufi/pages/tracking/maps/map_tracking_provider.dart';
import 'package:trufi/translations/trufi_app_localizations.dart';
import 'package:trufi_core/base/blocs/map_layer/map_layer.dart';
import 'package:trufi_core/base/blocs/map_layer/map_layers_cubit.dart';
import 'package:trufi_core/base/blocs/panel/panel_cubit.dart';
import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/models/map_provider_collection/leaflet_map_collection.dart';
import 'package:trufi_core/base/models/map_provider_collection/trufi_map_definition.dart';
import 'package:trufi_core/base/pages/about/about.dart';
import 'package:trufi_core/base/pages/about/translations/about_localizations.dart';
import 'package:trufi_core/base/pages/feedback/translations/feedback_localizations.dart';
import 'package:trufi_core/base/blocs/map_tile_provider/map_tile_provider_cubit.dart';
import 'package:trufi_core/base/pages/home/home.dart';
import 'package:trufi_core/base/pages/saved_places/saved_places.dart';
import 'package:trufi_core/base/pages/saved_places/translations/saved_places_localizations.dart';
import 'package:trufi_core/base/pages/transport_list/translations/transport_list_localizations.dart';
import 'package:trufi_core/base/pages/transport_list/transport_list.dart';
import 'package:trufi_core/base/providers/transit_route/route_transports_cubit/route_transports_cubit.dart';
import 'package:trufi_core/base/utils/trufi_app_id.dart';
import 'package:trufi_core/base/widgets/drawer/menu/default_item_menu.dart';
import 'package:trufi_core/base/widgets/drawer/menu/default_pages_menu.dart';
import 'package:trufi_core/base/widgets/drawer/menu/social_media_item.dart';
import 'package:trufi_core/base/widgets/drawer/menu/trufi_menu_item.dart';
import 'package:trufi_core/base/widgets/drawer/trufi_drawer.dart';
import 'package:trufi_core/base/widgets/screen/lifecycle_reactor_wrapper.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';
import 'package:trufi_core/base/blocs/localization/trufi_localization_cubit.dart';
import 'package:trufi_core/base/pages/home/route_planner_cubit/route_planner_cubit.dart';
import 'package:trufi_core/base/pages/saved_places/repository/search_location/default_search_location.dart';
import 'package:trufi_core/base/pages/saved_places/search_locations_cubit/search_locations_cubit.dart';
import 'package:trufi_core/base/blocs/map_tile_provider/map_tile_provider.dart';

import 'package:pf_user_tracking/bloc/tracking/service.dart';
import 'package:pf_user_tracking/bloc/tracking/tracking_cubit.dart';
import 'package:pf_user_tracking/translations/user_tracking_localizations.dart';
import 'pages/tracking/tracking_screen.dart';

abstract class DefaultValues {
  static TrufiLocalization trufiLocalization({Locale? currentLocale}) =>
      TrufiLocalization(
        currentLocale: currentLocale ?? const Locale("en"),
        localizationDelegates: const [
          SavedPlacesLocalization.delegate,
          FeedbackLocalization.delegate,
          AboutLocalization.delegate,
          TransportListLocalization.delegate,
          UserTrackingLocalization.delegate,
          TrufiAppLocalization.delegate,
        ],
        supportedLocales: const [
          Locale('es'),
          Locale('en'),
          Locale('de'),
          Locale('pt'),
        ],
      );

  static List<BlocProvider> blocProviders({
    required String otpEndpoint,
    required String otpGraphqlEndpoint,
    required MapConfiguration mapConfiguration,
    required String searchAssetPath,
    required String photonUrl,
    Map<String, dynamic>? querySearchParameters,
    List<MapLayerContainer>? layersContainer,
    List<MapTileProvider>? mapTileProviders,
    bool useCustomMapProvider = false,
  }) {
    return [
      BlocProvider<RouteTransportsCubit>(
        create: (context) => RouteTransportsCubit(otpGraphqlEndpoint),
      ),
      BlocProvider<SearchLocationsCubit>(
        create: (context) => SearchLocationsCubit(
          searchLocationRepository: DefaultSearchLocation(
            searchAssetPath,
            photonUrl: photonUrl,
            queryParameters: querySearchParameters,
          ),
        ),
      ),
      BlocProvider<RoutePlannerCubit>(
        create: (context) => RoutePlannerCubit(otpEndpoint),
      ),
      BlocProvider<MapConfigurationCubit>(
        create: (context) => MapConfigurationCubit(mapConfiguration),
      ),
      BlocProvider<TrackingCubit>(
        create: (BuildContext context) => TrackingCubit(
          location: LocationRoutingImplementation(
            color: const Color(0xFF4fa6a6),
            iconName: "ic_luncher",
          ),
          userTrackingService: UserTrackingServiceGraphQL(
            serverUrl:
                "https://navigator.trufi.app/user_tracking_graphql",
            uniqueAppId: TrufiAppId.getUniqueId,
          ),
        ),
      ),
      BlocProvider<MapLayersCubit>(
        create: (context) => MapLayersCubit(layersContainer ?? []),
      ),
      BlocProvider<PanelCubit>(
        create: (context) => PanelCubit(),
      ),
      if (!useCustomMapProvider)
        BlocProvider<MapTileProviderCubit>(
          create: (context) => MapTileProviderCubit(
            mapTileProviders: mapTileProviders ?? [OSMDefaultMapTile()],
          ),
        ),
    ];
  }

  static RouterDelegate<Object> routerDelegate({
    required String appName,
    required String cityName,
    required String countryName,
    WidgetBuilder? backgroundImageBuilder,
    AsyncExecutor? asyncExecutor,
    required String urlShareApp,
    required String urlWhatsapp,
    required String emailContact,
    UrlSocialMedia? urlSocialMedia,
    ITrufiMapProvider? trufiMapProvider,
    Uri? shareBaseUri,
    LifecycleReactorHandler? lifecycleReactorHandler,
  }) {
    final _trufiMapProvider = trufiMapProvider ?? LeafletMapCollection();
    generateDrawer(String currentRoute) {
      return (BuildContext _) => TrufiDrawer(
            currentRoute,
            appName: appName,
            countryName: countryName,
            cityName: cityName,
            backgroundImageBuilder: backgroundImageBuilder,
            urlShareApp: urlShareApp,
            menuItems: defaultMenuItems(defaultUrls: urlSocialMedia),
          );
    }

    return RoutemasterDelegate(
      routesBuilder: (routeContext) {
        return RouteMap(
          onUnknownRoute: (_) => const Redirect(HomePage.route),
          routes: {
            HomePage.route: (route) {
              return NoAnimationPage(
                lifecycleReactorHandler: lifecycleReactorHandler,
                child: HomePage(
                  drawerBuilder: generateDrawer(HomePage.route),
                  asyncExecutor: asyncExecutor ?? AsyncExecutor(),
                  mapRouteProvider: _trufiMapProvider.mapRouteProvider(
                    shareBaseItineraryUri: shareBaseUri?.replace(
                      path: "/app/Home",
                    ),
                    overlapWidget: (_) {
                      return const OverlayGPSButton();
                    },
                  ),
                  mapChooseLocationProvider:
                      _trufiMapProvider.mapChooseLocationProvider(),
                ),
              );
            },
            TrackingScreen.route: (route) => NoAnimationPage(
                  child: TrackingScreen(
                    drawerBuilder: generateDrawer(TrackingScreen.route),
                    mapRouteProvider: LeafletMapTrackingProvider.create(),
                  ),
                ),
            TransportList.route: (route) {
              return NoAnimationPage(
                child: TransportList(
                  drawerBuilder: generateDrawer(TransportList.route),
                  mapTransportProvider: _trufiMapProvider.mapTransportProvider(
                    shareBaseRouteUri: shareBaseUri?.replace(
                      path: "/app/TransportList",
                    ),
                  ),
                  mapRouteEditorProvider:
                      _trufiMapProvider.mapRouteEditorProvider(),
                ),
              );
            },
            SavedPlacesPage.route: (route) {
              return NoAnimationPage(
                child: SavedPlacesPage(
                  drawerBuilder: generateDrawer(SavedPlacesPage.route),
                  mapChooseLocationProvider:
                      _trufiMapProvider.mapChooseLocationProvider(),
                ),
              );
            },
            FeedbackPage.route: (route) => NoAnimationPage(
                  child: FeedbackPage(
                    email: emailContact,
                    urlWhatsapp: urlWhatsapp,
                    drawerBuilder: generateDrawer(FeedbackPage.route),
                  ),
                ),
            FaresGuideLinesPage.route: (route) => NoAnimationPage(
                  child: FaresGuideLinesPage(
                    drawerBuilder: generateDrawer(FaresGuideLinesPage.route),
                  ),
                ),
            AboutPage.route: (route) => NoAnimationPage(
                  child: AboutPage(
                    appName: appName,
                    cityName: cityName,
                    countryName: countryName,
                    emailContact: emailContact,
                    drawerBuilder: generateDrawer(AboutPage.route),
                  ),
                ),
          },
        );
      },
    );
  }
}

List<List<TrufiMenuItem>> defaultMenuItems({
  required UrlSocialMedia? defaultUrls,
}) {
  return [
    [
      DefaultPagesMenu.homePage.toMenuPage(),
      DefaultPagesMenu.transportList.toMenuPage(),
      TrackingScreen.menuPage,
      DefaultPagesMenu.savedPlaces.toMenuPage(),
      DefaultPagesMenu.feedback.toMenuPage(),
      FaresGuideLinesPage.menuPage,
      DefaultPagesMenu.about.toMenuPage(),
    ],
    [
      if (defaultUrls != null && defaultUrls.existUrl)
        defaultSocialMedia(defaultUrls),
      ...DefaultItemsMenu.values
          .map((menuPage) => menuPage.toMenuItem())
          .toList(),
    ]
  ];
}
