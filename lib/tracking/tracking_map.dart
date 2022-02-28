import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pf_user_tracking/bloc/tracking/tracking_cubit.dart';

class TrackingMap extends StatelessWidget {
  final String mapTilesUrl;
  const TrackingMap({
    Key? key,
    required this.mapTilesUrl,
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
    return FlutterMap(
      options: MapOptions(
        center: LatLng(-17.39000, -66.15400),
        zoom: 13.0,
        maxZoom: 18,
        interactiveFlags: InteractiveFlag.drag |
            InteractiveFlag.flingAnimation |
            InteractiveFlag.pinchMove |
            InteractiveFlag.pinchZoom |
            InteractiveFlag.doubleTapZoom,
      ),
      layers: [
        TileLayerOptions(
          fastReplace: true,
          urlTemplate: mapTilesUrl,
        ),
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
