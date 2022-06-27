import 'package:async_executor/async_executor.dart';
import 'package:flutter/material.dart';
import 'package:pf_user_tracking/tools/location.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi/feedback.dart';
import 'package:trufi/tracking/maps/map_tracking_provider.dart';
import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';

import 'package:trufi_core/base/pages/about/about.dart';
import 'package:trufi_core/base/pages/about/translations/about_localizations.dart';
import 'package:trufi_core/base/pages/feedback/translations/feedback_localizations.dart';
import 'package:trufi_core/base/blocs/map_tile_provider/map_tile_provider_cubit.dart';
import 'package:trufi_core/base/pages/home/home.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/maps/map_route_provider.dart';
import 'package:trufi_core/base/pages/saved_places/saved_places.dart';
import 'package:trufi_core/base/pages/saved_places/translations/saved_places_localizations.dart';
import 'package:trufi_core/base/pages/transport_list/transport_list.dart';
import 'package:trufi_core/base/pages/transport_list/transport_list_detail/maps/map_transport_provider.dart';
import 'package:trufi_core/base/widgets/base_maps/i_trufi_map_controller.dart';
import 'package:trufi_core/base/widgets/choose_location/maps/map_choose_location_provider.dart';
import 'package:trufi_core/base/widgets/drawer/menu/default_item_menu.dart';
import 'package:trufi_core/base/widgets/drawer/menu/default_pages_menu.dart';
import 'package:trufi_core/base/widgets/drawer/menu/menu_item.dart';
import 'package:trufi_core/base/widgets/drawer/menu/social_media_item.dart';
import 'package:trufi_core/base/widgets/drawer/trufi_drawer.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';
import 'package:trufi_core/base/blocs/localization/trufi_localization_cubit.dart';
import 'package:trufi_core/base/pages/home/map_route_cubit/map_route_cubit.dart';
import 'package:trufi_core/base/pages/saved_places/repository/search_location/default_search_location.dart';
import 'package:trufi_core/base/pages/saved_places/search_locations_cubit/search_locations_cubit.dart';
import 'package:trufi_core/base/pages/transport_list/route_transports_cubit/route_transports_cubit.dart';
import 'package:trufi_core/base/blocs/map_tile_provider/map_tile_provider.dart';

import 'package:pf_user_tracking/bloc/tracking/service.dart';
import 'package:pf_user_tracking/bloc/tracking/tracking_cubit.dart';
import 'package:pf_user_tracking/translations/user_tracking_localizations.dart';
import 'tracking/tracking_screen.dart';

abstract class DefaultValues {
  static TrufiLocalization trufiLocalization({Locale? currentLocale}) =>
      TrufiLocalization(
        currentLocale: currentLocale ?? const Locale("en"),
        localizationDelegates: const [
          SavedPlacesLocalization.delegate,
          FeedbackLocalization.delegate,
          AboutLocalization.delegate,
          UserTrackingLocalization.delegate,
        ],
        supportedLocales: const [
          Locale('de'),
          Locale('en'),
          Locale('es'),
        ],
      );

  static List<BlocProvider> blocProviders({
    required String otpEndpoint,
    required String otpGraphqlEndpoint,
    required MapConfiguration mapConfiguration,
    required String searchAssetPath,
    required String photonUrl,
    List<MapTileProvider>? mapTileProviders,
    required TypepProviderMap typeProviderMap,
  }) {
    return [
      BlocProvider<RouteTransportsCubit>(
        create: (context) => RouteTransportsCubit(otpGraphqlEndpoint),
      ),
      BlocProvider<SearchLocationsCubit>(
        create: (context) => SearchLocationsCubit(
          searchLocationRepository: DefaultSearchLocation(
            searchAssetPath,
            photonUrl,
          ),
        ),
      ),
      BlocProvider<MapRouteCubit>(
        create: (context) => MapRouteCubit(otpEndpoint),
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
            serverUrl: "https://cbba.trufi.dev/user_tracking_graphql",
          ),
        ),
      ),
      if (typeProviderMap == TypepProviderMap.lealetMap)
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
    required String urlFeedback,
    required String urlWhatsapp,
    required String emailContact,
    UrlSocialMedia? urlSocialMedia,
    required TypepProviderMap typeProviderMap,
  }) {
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
                child: HomePage(
                  drawerBuilder: generateDrawer(HomePage.route),
                  asyncExecutor: asyncExecutor ?? AsyncExecutor(),
                  mapRouteProvider:
                      MapRouteProviderImplementation.providerByTypepProviderMap(
                    typeProviderMap: typeProviderMap,
                    overlapWidget: (_) {
                      return const OverlayGPSButton();
                    },
                  ),
                  mapChooseLocationProvider:
                      MapChooseLocationProviderImplementation
                          .providerByTypepProviderMap(
                              typeProviderMap: typeProviderMap),
                ),
              );
            },
            TrackingScreen.route: (route) => NoAnimationPage(
                  child: TrackingScreen(
                    drawerBuilder: generateDrawer(TrackingScreen.route),
                    mapRouteProvider: MapTrackingProviderImplementation
                        .providerByTypepProviderMap(
                      typeProviderMap: typeProviderMap,
                    ),
                  ),
                ),
            TransportList.route: (route) {
              return NoAnimationPage(
                child: TransportList(
                  drawerBuilder: generateDrawer(TransportList.route),
                  mapTransportProvider: MapTransportProviderImplementation
                      .providerByTypepProviderMap(
                          typeProviderMap: typeProviderMap),
                ),
              );
            },
            SavedPlacesPage.route: (route) {
              return NoAnimationPage(
                child: SavedPlacesPage(
                  drawerBuilder: generateDrawer(SavedPlacesPage.route),
                  mapChooseLocationProvider:
                      MapChooseLocationProviderImplementation
                          .providerByTypepProviderMap(
                    typeProviderMap: typeProviderMap,
                  ),
                ),
              );
            },
            FeedbackPage.route: (route) => NoAnimationPage(
                  child: FeedbackPage(
                    urlFeedback: urlFeedback,
                    urlWhatsapp: urlWhatsapp,
                    drawerBuilder: generateDrawer(FeedbackPage.route),
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

List<List<MenuItem>> defaultMenuItems({
  required UrlSocialMedia? defaultUrls,
}) {
  return [
    [
      DefaultPagesMenu.homePage.toMenuPage(),
      DefaultPagesMenu.transportList.toMenuPage(),
      MenuPageItem(
        id: TrackingScreen.route,
        selectedIcon: (context) => Icon(
          Icons.alt_route,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        notSelectedIcon: (context) => const Icon(
          Icons.alt_route,
          color: Colors.grey,
        ),
        name: (context) {
          return UserTrackingLocalization.of(context).menuTraceRoute;
        },
      ),
      DefaultPagesMenu.savedPlaces.toMenuPage(),
      DefaultPagesMenu.feedback.toMenuPage(),
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
