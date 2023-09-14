import 'package:flutter/material.dart';
import 'package:trufi/custom_async_executor.dart';
import 'package:trufi/local_poi_layer/static_layer.dart';
import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/blocs/map_tile_provider/map_tile_provider.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/utils/certificates_letsencrypt_android.dart';
import 'package:trufi_core/base/utils/graphql_client/hive_init.dart';
import 'package:trufi_core/base/utils/trufi_app_id.dart';
import 'package:trufi_core/base/widgets/drawer/menu/social_media_item.dart';
import 'package:trufi_core/base/widgets/screen/lifecycle_reactor_notification.dart';
import 'package:trufi_core/trufi_core.dart';
import 'package:trufi_core/trufi_router.dart';

import 'default_values.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CertificatedLetsencryptAndroid.workAroundCertificated();
  await initHiveForFlutter();
  await TrufiAppId.initialize();
  runApp(
    TrufiApp(
      appNameTitle: 'TrufiApp',
      trufiLocalization: DefaultValues.trufiLocalization(
        currentLocale: const Locale("es"),
      ),
      blocProviders: [
        ...DefaultValues.blocProviders(
          otpEndpoint: "https://navigator.trufi.app/otp",
          otpGraphqlEndpoint: "https://navigator.trufi.app/otp/index/graphql",
          mapConfiguration: MapConfiguration(
            center: const TrufiLatLng(-17.392600, -66.158787),
            feedbackForm: "https://forms.gle/QMLhJT7N44Bh9zBN6",
          ),
          searchAssetPath: "assets/data/search.json",
          photonUrl: "https://navigator.trufi.app/photon",
          mapTileProviders: [
            OSMMapLayer(
              mapTilesUrl:
                  "http://navigator.trufi.app/static-maps/trufi-liberty/{z}/{x}/{y}@2x.jpg",
            ),
          ],
          layersContainer: customLayersTrufi,
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
          urlWhatsapp: 'https://wa.me/message/U2SDYC6R55WCM1',
          emailContact: 'feedback@trufi.app',
          urlShareApp: 'https://www.trufi.app/',
          urlSocialMedia: const UrlSocialMedia(
            urlFacebook: 'https://www.facebook.com/trufiapp/',
            urlInstagram: 'https://www.instagram.com/trufi.app',
          ),
          asyncExecutor: customAsyncExecutor,
          shareBaseUri: Uri(
            scheme: "https",
            host: "navigator.trufi.app",
          ),
          lifecycleReactorHandler: LifecycleReactorNotifications(
            url:
                'https://navigator.trufi.app/static_files/notification.json',
          ),
        ),
      ),
    ),
  );
}