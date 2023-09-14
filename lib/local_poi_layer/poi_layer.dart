import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi/local_poi_layer/poi_marker_enum.dart';
import 'package:trufi/local_poi_layer/poi_marker_modal.dart';
import 'package:trufi/local_poi_layer/markers_from_assets.dart';
import 'package:trufi/translations/trufi_app_localizations.dart';
import 'package:trufi_core/base/blocs/map_layer/map_layer.dart';
import 'package:trufi_core/base/blocs/panel/panel_cubit.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';

import 'poi_layer_data.dart';

class POILayer extends MapLayer {
  List<POILayerData> customMarkers = [];
  final POILayerIds layerId;
  final String? url;
  final String? nameEN;
  final String? nameDE;
  final bool isOnline;
  bool isFetching = false;
  POILayer(
    this.layerId,
    String weight, {
    this.url,
    this.nameEN,
    this.nameDE,
    this.isOnline = false,
  }) : super(layerId.getString, weight) {
    load().catchError((error) {
      log("$error");
    });
  }

  Future<void> load() async {
    if (customMarkers.isNotEmpty) {
      return;
    }
    if (isOnline) {
      // TODO enable online-mode more later
      // try {
      //   if (_isFetching) {
      //     return;
      //   }
      //   _isFetching = true;
      //   customMarkers = await markersFromUrl(url!);
      //   refresh();
      //   _isFetching = false;
      // } catch (e) {
      //   _isFetching = false;
      //   throw Exception(
      //     "Parse error Layer: $e in url:$url",
      //   );
      // }
    } else {
      final fileName = layerId.getFileName;
      customMarkers = await markersFromAssets("assets/data/POIs/$fileName");
      refresh();
    }
  }

  @override
  List<Marker>? buildLayerMarkers(int? zoom) {
    double? markerSize;
    switch (zoom) {
      case 15:
        markerSize = 15;
        break;
      case 16:
        markerSize = 20;
        break;
      case 17:
        markerSize = 25;
        break;
      case 18:
        markerSize = 30;
        break;
      default:
        markerSize = zoom != null && zoom > 18 ? 35 : null;
    }
    final markers = <Marker>[];
    if (markerSize != null) {
      for (final layerData in customMarkers) {
        final isOnlyPoint = layerData.getPoints.length == 1;
        for (var i = 0; i < layerData.getPoints.length; i++) {
          final point = layerData.getPoints[i];
          markers.add(Marker(
            key: Key(
                "$id:${layerData.id}---${layerData.name} ${isOnlyPoint ? "" : i + 1}"),
            height: markerSize,
            width: markerSize,
            point: point,
            anchorPos: AnchorPos.align(AnchorAlign.center),
            builder: (context) => GestureDetector(
              onTap: () {
                final panelCubit = context.read<PanelCubit>();
                panelCubit.setPanel(
                  MarkerPanel(
                    panel: (
                      context,
                      onFetchPlan, {
                      isOnlyDestination,
                    }) =>
                        POIMarkerModal(
                      layerId: layerId,
                      element: layerData,
                      point: point,
                      onFetchPlan: onFetchPlan,
                      index: isOnlyPoint ? null : i + 1,
                    ),
                    positon: TrufiLatLng.fromLatLng(point),
                    minSize: 120,
                  ),
                );
              },
              child: FittedBox(child: layerId.getImage()),
            ),
          ));
        }
      }
    }

    return markers;
  }

  @override
  Widget? buildLayerOptionsBackground(int? zoom) {
    final dataPoligons = customMarkers.where((element) {
      return element.geometry.type == GeometryType.polygon ||
          element.geometry.type == GeometryType.multiPolygon;
    });

    return Stack(
      children: dataPoligons
          .map(
            (polygon) => PolygonLayer(
              polygons: polygon.geometry.coordinates
                  .map(
                    (e) => Polygon(
                      points: e,
                      borderColor: layerId.getBackgroundColor,
                      color: layerId.getBackgroundColor.withOpacity(0.2),
                      isFilled: true,
                      borderStrokeWidth: 2,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget buildLayerOptions(int? zoom) {
    if (customMarkers.isEmpty) {
      load();
    }
    double? markerSize;
    switch (zoom) {
      case 15:
        markerSize = 15;
        break;
      case 16:
        markerSize = 20;
        break;
      case 17:
        markerSize = 25;
        break;
      case 18:
        markerSize = 30;
        break;
      default:
        markerSize = zoom != null && zoom > 18 ? 35 : null;
    }

    final markers = <Marker>[];
    if (markerSize != null) {
      for (final layerData in customMarkers) {
        for (var i = 0; i < layerData.getPoints.length; i++) {
          final point = layerData.getPoints[i];
          final isOnlyPoint = layerData.getPoints.length == 1;
          markers.add(Marker(
            key: Key(
                "$id:${layerData.id}---${layerData.name} ${isOnlyPoint ? "" : i + 1}"),
            height: markerSize,
            width: markerSize,
            point: point,
            anchorPos: AnchorPos.align(AnchorAlign.center),
            builder: (context) => GestureDetector(
              onTap: () {
                final panelCubit = context.read<PanelCubit>();
                panelCubit.setPanel(
                  MarkerPanel(
                    panel: (
                      context,
                      onFetchPlan, {
                      isOnlyDestination,
                    }) =>
                        POIMarkerModal(
                      layerId: layerId,
                      element: layerData,
                      point: point,
                      onFetchPlan: onFetchPlan,
                    ),
                    positon: TrufiLatLng.fromLatLng(point),
                    minSize: 120,
                  ),
                );
              },
              child: FittedBox(child: layerId.getImage()),
            ),
          ));
        }
      }
    } else if (zoom != null && zoom > 11) {
      for (final layerData in customMarkers) {
        for (final point in layerData.getPoints) {
          markers.add(
            Marker(
              height: 7,
              width: 7,
              point: point,
              anchorPos: AnchorPos.align(AnchorAlign.center),
              builder: (context) => Container(
                decoration: BoxDecoration(
                  color: layerId.getBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          );
        }
      }
    }

    return MarkerLayer(
      markers: markers,
    );
  }

  @override
  String name(BuildContext context) {
    final localizationTB = TrufiAppLocalization.of(context);
    return layerId.getTranslate(localizationTB);
  }

  @override
  Widget icon(BuildContext context) => layerId.getImage();
}
