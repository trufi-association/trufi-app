import 'package:flutter/material.dart';

import 'package:trufi/local_poi_layer/poi_marker_enum.dart';
import 'package:trufi/local_poi_layer/poi_layer.dart';
import 'package:trufi/translations/trufi_app_localizations.dart';
import 'package:trufi_core/base/blocs/map_layer/map_layer.dart';

final List<MapLayerContainer> customLayersTrufi = [
  MapLayerContainer(
    name: (context) =>
        TrufiAppLocalization.of(context).layerGroupHealthServices,
    icon: (context) => const Icon(
      Icons.health_and_safety_outlined,
    ),
    layers: [
      POILayer(
        POILayerIds.hospitals,
        '3',
      ),
      POILayer(
        POILayerIds.pharmacies,
        '3',
      ),
    ],
  ),
  MapLayerContainer(
    name: (context) => TrufiAppLocalization.of(context).layerGroupLeisure,
    icon: (context) => const Icon(
      Icons.stars,
    ),
    layers: [
      POILayer(
        POILayerIds.museumsAndArtGalleries,
        '3',
      ),
      POILayer(
        // onlyPolygons
        POILayerIds.stadiumsAndSportsComplexes,
        '3',
      ),
      POILayer(
        // onlyPolygons
        POILayerIds.parksAndSquares,
        '3',
      ),
      POILayer(
        POILayerIds.cinemas,
        '3',
      ),
      POILayer(
        POILayerIds.shoppingCentersAndSupermarkets,
        '3',
      ),
      POILayer(
        POILayerIds.attractionsAndMonuments,
        '3',
      ),
    ],
  ),
  MapLayerContainer(
    name: (context) => TrufiAppLocalization.of(context).layerGroupTravel,
    icon: (context) => const Icon(
      Icons.travel_explore,
    ),
    layers: [
      POILayer(
        // Only polygons
        POILayerIds.terminalsAndStations,
        '3',
      ),
      POILayer(
        POILayerIds.interprovincialStops,
        '3',
      ),
    ],
  ),
  MapLayerContainer(
    name: (context) => TrufiAppLocalization.of(context).layerGroupEducation,
    icon: (context) => const Icon(
      Icons.school_outlined,
    ),
    layers: [
      POILayer(
        // Only polygons
        POILayerIds.universities,
        '3',
      ),
      POILayer(
        // Only polygons
        POILayerIds.institutes,
        '3',
      ),
      POILayer(
        POILayerIds.schools,
        '3',
      ),
      POILayer(
        POILayerIds.libraries,
        '3',
      ),
    ],
  ),
];
