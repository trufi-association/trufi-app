import 'package:flutter/material.dart';
import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/utils/graphql_client/hive_init.dart';
import 'package:trufi_core/base/widgets/drawer/menu/social_media_item.dart';
import 'package:trufi_core/trufi_core.dart';
import 'package:trufi_core/trufi_router.dart';
import 'package:latlong2/latlong.dart';

import 'default_values.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  runApp(
    TrufiApp(
      appNameTitle: 'TrufiApp',
      trufiLocalization: DefaultValues.trufiLocalization(
        currentLocale: const Locale("es"),
      ),
      blocProviders: [
        ...DefaultValues.blocProviders(
          otpEndpoint: "https://cbba.trufi.dev/otp",
          otpGraphqlEndpoint: "https://cbba.trufi.dev/otp/index/graphql",
          mapConfiguration: MapConfiguration(
            center: LatLng(-17.392600, -66.158787),
          ),
          searchAssetPath: "assets/data/search.json",
          photonUrl: "https://cbba.trufi.dev/photon",
        ),
      ],
      trufiRouter: TrufiRouter(
        routerDelegate: DefaultValues.routerDelegate(
          appName: 'TrufiApp',
          cityName: 'Cochabamba - Bolivia',
          backgroundImageBuilder: (_) {
            return Image.asset(
              'assets/images/drawer-bg.jpg',
              fit: BoxFit.cover,
            );
          },
          urlFeedback: 'https://example/feedback',
          urlShareApp: 'https://example/share',
          urlSocialMedia: const UrlSocialMedia(
            urlFacebook: 'https://www.facebook.com/Example',
          ),
          mapTilesUrl:
              "https://cbba.trufi.dev/static-maps/trufi-liberty/{z}/{x}/{y}@2x.jpg",
        ),
      ),
    ),
  );
}
