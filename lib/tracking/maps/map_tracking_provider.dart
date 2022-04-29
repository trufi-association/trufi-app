import 'package:flutter/material.dart';
import 'package:trufi/tracking/maps/google_map_tracking.dart';
import 'package:trufi/tracking/maps/leaftlet_map_trancking.dart';
import 'package:trufi_core/base/widgets/base_maps/google_maps/google_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/i_trufi_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map_controller.dart';

typedef MapTrackingBuilder = Widget Function(
  BuildContext context,
);

class MapTrackingProvider {
  final ITrufiMapController trufiMapController;
  final MapTrackingBuilder mapChooseLocationBuilder;

  const MapTrackingProvider({
    required this.trufiMapController,
    required this.mapChooseLocationBuilder,
  });

  factory MapTrackingProvider.providerByTypepProviderMap({
    required TypepProviderMap typeProviderMap,
  }) {
    switch (typeProviderMap) {
      case TypepProviderMap.lealetMap:
        return MapTrackingProvider.leaftletMap();
      case TypepProviderMap.googleMap:
        return MapTrackingProvider.googleMap();
      default:
        throw 'error TypeProviderMap not implement in MapChooseLocationProvider';
    }
  }

  factory MapTrackingProvider.googleMap() {
    final trufiMapController = TGoogleMapController();
    return MapTrackingProvider(
      trufiMapController: trufiMapController,
      mapChooseLocationBuilder: (mapContext) {
        return GoogleMapTracking(
          trufiMapController: trufiMapController,
        );
      },
    );
  }
  factory MapTrackingProvider.leaftletMap() {
    final trufiMapController = LeafletMapController();
    return MapTrackingProvider(
      trufiMapController: trufiMapController,
      mapChooseLocationBuilder: (mapContext) {
        return LeaftletMapTracking(
          trufiMapController: trufiMapController,
        );
      },
    );
  }
}
