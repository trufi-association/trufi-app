import 'package:flutter/material.dart';
import 'package:trufi/tracking/maps/google_map_tracking.dart';
import 'package:trufi/tracking/maps/leaftlet_map_trancking.dart';
import 'package:trufi_core/base/widgets/base_maps/google_maps/google_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/i_trufi_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map_controller.dart';

typedef MapTrackingBuilder = Widget Function(
  BuildContext context,
);

abstract class MapTrackingProvider {
  ITrufiMapController get trufiMapController;
  MapTrackingBuilder get mapChooseLocationBuilder;
}

class MapTrackingProviderImplementation implements MapTrackingProvider {
  @override
  final ITrufiMapController trufiMapController;
  @override
  final MapTrackingBuilder mapChooseLocationBuilder;

  const MapTrackingProviderImplementation({
    required this.trufiMapController,
    required this.mapChooseLocationBuilder,
  });

  factory MapTrackingProviderImplementation.providerByTypepProviderMap({
    required TypepProviderMap typeProviderMap,
  }) {
    switch (typeProviderMap) {
      case TypepProviderMap.lealetMap:
        return MapTrackingProviderImplementation.leaftletMap();
      case TypepProviderMap.googleMap:
        return MapTrackingProviderImplementation.googleMap();
      default:
        throw 'error TypeProviderMap not implement in MapChooseLocationProvider';
    }
  }

  factory MapTrackingProviderImplementation.googleMap() {
    final trufiMapController = TGoogleMapController();
    return MapTrackingProviderImplementation(
      trufiMapController: trufiMapController,
      mapChooseLocationBuilder: (mapContext) {
        return GoogleMapTracking(
          trufiMapController: trufiMapController,
        );
      },
    );
  }
  factory MapTrackingProviderImplementation.leaftletMap() {
    final trufiMapController = LeafletMapController();
    return MapTrackingProviderImplementation(
      trufiMapController: trufiMapController,
      mapChooseLocationBuilder: (mapContext) {
        return LeaftletMapTracking(
          trufiMapController: trufiMapController,
        );
      },
    );
  }
}
