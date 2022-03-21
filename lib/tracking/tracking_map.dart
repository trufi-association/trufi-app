import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pf_user_tracking/bloc/tracking/tracking_cubit.dart';
import 'package:trufi_core/base/widgets/maps/trufi_map.dart';
import 'package:trufi_core/base/widgets/maps/trufi_map_cubit/trufi_map_cubit.dart';

class TrackingMap extends StatelessWidget {
  final TrufiMapController trufiMapController = TrufiMapController();
  TrackingMap({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final trackingCubit = context.watch<TrackingCubit>();
    final trackingCubitState = trackingCubit.state;
    final routes = trackingCubitState.currentRouteId == ""
        ? []
        : [
            trackingCubitState.routes[trackingCubitState.currentRouteId]!.routes
                .map((e) => e.toLatLng())
                .toList()
          ];
    final current = !trackingCubitState.lastTrack.fake
        ? trackingCubitState.lastTrack.toLatLng()
        : null;
    trufiMapController.mapController.onReady.then((value) {
      if (current != null) {
        trufiMapController.mapController.move(current, 16);
      }
    });
    return TrufiMap(
      trufiMapController: trufiMapController,
      layerOptionsBuilder: (context) => [
        ...routes.map((points) => buildRoute(points)).fold<List<LayerOptions>>(
          [],
          (value, element) => [...value, ...element],
        ).toList(),
        if (current != null)
          MarkerLayerOptions(
            markers: [
              Marker(
                width: 10.0,
                height: 10.0,
                point: current,
                builder: (context) => Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  void move({
    required LatLng center,
    required double zoom,
    TickerProvider? tickerProvider,
  }) {
    trufiMapController.move(center: center, zoom: zoom);
  }

  List<LayerOptions> buildRoute(List<LatLng> points) {
    return [
      MarkerLayerOptions(
        markers: [
          ...points
              .map(
                (point) => Marker(
                  width: 5.0,
                  height: 5.0,
                  point: point,
                  builder: (context) => Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )
              .toList(),
        ],
      ),
      PolylineLayerOptions(
        polylineCulling: true,
        polylines: [
          Polyline(
            points: points,
            strokeWidth: 1.0,
            color: Colors.green,
          ),
        ],
      ),
    ];
  }
}
