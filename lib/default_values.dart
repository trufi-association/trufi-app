import 'package:async_executor/async_executor.dart';
import 'package:flutter/material.dart';
import 'package:pf_user_tracking/tools/location.dart';
import 'package:pf_user_tracking/utils/custom_button.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';

import 'package:trufi_core/base/pages/about/about.dart';
import 'package:trufi_core/base/pages/about/translations/about_localizations.dart';
import 'package:trufi_core/base/pages/feedback/feedback.dart';
import 'package:trufi_core/base/pages/feedback/translations/feedback_localizations.dart';
import 'package:trufi_core/base/pages/home/home.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/trufi_map_route.dart';
import 'package:trufi_core/base/pages/saved_places/saved_places.dart';
import 'package:trufi_core/base/pages/saved_places/translations/saved_places_localizations.dart';
import 'package:trufi_core/base/pages/transport_list/transport_list.dart';
import 'package:trufi_core/base/pages/transport_list/transport_list_detail/transport_list_detail.dart';
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

import 'package:pf_user_tracking/bloc/tracking/service.dart';
import 'package:pf_user_tracking/bloc/tracking/tracking_cubit.dart';
import 'package:pf_user_tracking/translations/user_tracking_localizations.dart';
import 'tracking/TrackingScreen.dart';

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
            // serverUrl: "http://192.168.100.3:3000/user_tracking_graphql",
          ),
        ),
      ),
    ];
  }

  static RouterDelegate<Object> routerDelegate({
    required String appName,
    required String cityName,
    WidgetBuilder? backgroundImageBuilder,
    AsyncExecutor? asyncExecutor,
    required String urlShareApp,
    required String urlFeedback,
    UrlSocialMedia? urlSocialMedia,
    required String mapTilesUrl,
  }) {
    generateDrawer(String currentRoute) {
      return (BuildContext _) => TrufiDrawer(
            currentRoute,
            appName: appName,
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
            HomePage.route: (route) => NoAnimationPage(
                  child: HomePage(
                    mapTilesUrl: mapTilesUrl,
                    asyncExecutor: asyncExecutor ?? AsyncExecutor(),
                    mapBuilder: (
                      mapContext,
                      trufiMapController,
                    ) {
                      return TrufiMapRoute(
                        mapTilesUrl: mapTilesUrl,
                        asyncExecutor: asyncExecutor ?? AsyncExecutor(),
                        trufiMapController: trufiMapController,
                        overlapWidget: (_) {
                          return const OverlayGPSButton();
                        },
                      );
                    },
                    drawerBuilder: generateDrawer(HomePage.route),
                  ),
                ),
            TransportList.route: (route) => NoAnimationPage(
                  child: TransportList(
                    drawerBuilder: generateDrawer(TransportList.route),
                  ),
                ),
            TrackingScreen.route: (route) => NoAnimationPage(
                  child: TrackingScreen(
                    mapTilesUrl: mapTilesUrl,
                    drawerBuilder: generateDrawer(TrackingScreen.route),
                  ),
                ),
            TransportListDetail.route: (route) => NoAnimationPage(
                  child: TransportListDetail(
                    mapTilesUrl: mapTilesUrl,
                    id: Uri.decodeQueryComponent(route.pathParameters['id']!),
                  ),
                ),
            SavedPlacesPage.route: (route) => NoAnimationPage(
                  child: SavedPlacesPage(
                    mapTilesUrl: mapTilesUrl,
                    drawerBuilder: generateDrawer(SavedPlacesPage.route),
                  ),
                ),
            FeedbackPage.route: (route) => NoAnimationPage(
                  child: FeedbackPage(
                    urlFeedback: urlFeedback,
                    drawerBuilder: generateDrawer(FeedbackPage.route),
                  ),
                ),
            AboutPage.route: (route) => NoAnimationPage(
                  child: AboutPage(
                    appName: appName,
                    cityName: cityName,
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
          return "UserTrackingScreen";
        },
      )
    ],
    DefaultPagesMenu.values.map((menuPage) => menuPage.toMenuPage()).toList(),
    [
      if (defaultUrls != null && defaultUrls.existUrl)
        defaultSocialMedia(defaultUrls),
      ...DefaultItemsMenu.values
          .map((menuPage) => menuPage.toMenuItem())
          .toList(),
    ]
  ];
}

class OverlayGPSButton extends StatelessWidget {
  const OverlayGPSButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 5,
      child: FloatingActionButton(
        backgroundColor: const Color(0xFF4fa6a6),
        child: const Icon(Icons.alt_route),
        onPressed: () {
          Navigator.pop(context);
          Routemaster.of(context).push(TrackingScreen.route);
        },
      ),
    );
  }
}
