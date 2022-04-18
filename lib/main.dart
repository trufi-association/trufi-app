import 'package:flutter/material.dart';
import 'package:trufi/custom_async_executor.dart';
import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/utils/certificates_letsencrypt_android.dart';
import 'package:trufi_core/base/utils/graphql_client/hive_init.dart';
import 'package:trufi_core/base/widgets/drawer/menu/social_media_item.dart';
import 'package:trufi_core/trufi_core.dart';
import 'package:trufi_core/trufi_router.dart';
import 'package:latlong2/latlong.dart';

import 'default_values.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CertificatedLetsencryptAndroid.workAroundCertificated();
  await initHiveForFlutter();
  runApp(
    TrufiApp(
      appNameTitle: 'TrufiApp',
      trufiLocalization: DefaultValues.trufiLocalization(
        currentLocale: const Locale("es"),
      ),
      blocProviders: [
        ...DefaultValues.blocProviders(
          otpEndpoint: "https://cbba.trufi.app/otp",
          otpGraphqlEndpoint: "https://cbba.trufi.app/otp/index/graphql",
          mapConfiguration: MapConfiguration(
            center: LatLng(-17.392600, -66.158787),
          ),
          searchAssetPath: "assets/data/search.json",
          photonUrl: "https://cbba.trufi.app/photon",
          mapTilesUrl:
              "https://cbba.trufi.app/static-maps/trufi-liberty/{z}/{x}/{y}@2x.jpg",
        ),
      ],
      trufiRouter: TrufiRouter(
        routerDelegate: DefaultValues.routerDelegate(
          appName: 'Trufi App',
          cityName: 'Cochabamba',
          countryName: 'Bolivia',
          backgroundImageBuilder: (_) {
            return Image.asset(
              'assets/images/drawer-bg.jpg',
              fit: BoxFit.cover,
            );
          },
          urlFeedback:
              'https://trufifeedback.z15.web.core.windows.net/route.html',
          emailContact: 'feedback@trufi.app',
          urlShareApp: 'https://appurl.io/BOPP7QnKX',
          urlSocialMedia: const UrlSocialMedia(
            urlFacebook: 'https://www.facebook.com/trufiapp/',
          ),
          asyncExecutor: customAsyncExecutor,
        ),
      ),
    ),
  );
}
