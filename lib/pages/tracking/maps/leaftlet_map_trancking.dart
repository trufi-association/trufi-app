import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map_controller.dart';

import 'package:pf_user_tracking/bloc/tracking/tracking_cubit.dart';

class LeaftletMapTracking extends StatelessWidget {
  final LeafletMapController trufiMapController;

  const LeaftletMapTracking({
    Key? key,
    required this.trufiMapController,
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
    trufiMapController.onReady.then((value) {
      if (current != null) {
        trufiMapController.mapController.move(current, 16);
      }
    });
    return LeafletMap(
      trufiMapController: trufiMapController,
      bottomPaddingButtons: 120,
      layerOptionsBuilder: (context) => [
        ...routes.map((points) => buildRoute(points)).fold<List<Widget>>(
          [],
          (value, element) => [...value, ...element],
        ).toList(),
        if (current != null)
          MarkerLayer(
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

  List<Widget> buildRoute(List<LatLng> points) {
    return [
      MarkerLayer(
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
      PolylineLayer(
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
