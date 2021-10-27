import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:trufi_core/models/map_tile_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedTileProvider extends TileProvider {
  const CachedTileProvider();
  @override
  ImageProvider getImage(Coords<num> coords, TileLayerOptions options) {
    return CachedNetworkImageProvider(getTileUrl(coords, options));
  }
}

enum MapLayerIds {
  streets,
  satellite,
  terrain,
}

extension LayerIdsToString on MapLayerIds {
  String enumToString() {
    final Map<MapLayerIds, String> enumStrings = {
      MapLayerIds.streets: "Streets",
      MapLayerIds.satellite: "Satellite",
      MapLayerIds.terrain: "Terrain",
    };

    return enumStrings[this];
  }
}

Map<MapLayerIds, List<LayerOptions>> mapLayerOptions = {
  MapLayerIds.streets: [
    TileLayerOptions(
      urlTemplate:
          "https://api.trufi.app/tiles/streets/{z}/{x}/{y}@2x.jpg",
      tileProvider: const CachedTileProvider(),
    ),
  ],
  MapLayerIds.satellite: [
    TileLayerOptions(
      urlTemplate: "https://api.trufi.app/tiles/satellite/{z}/{x}/{y}@2x.jpg",
      tileProvider: const CachedTileProvider(),
    ),
  ],
  MapLayerIds.terrain: [
    TileLayerOptions(
      urlTemplate: "https://api.trufi.app/tiles/terrain/{z}/{x}/{y}@2x.jpg",
      tileProvider: const CachedTileProvider(),
    ),
  ],
};
Map<MapLayerIds, String> layerImage = {
  MapLayerIds.streets: "assets/images/maptype-streets.png",
  MapLayerIds.satellite: "assets/images/maptype-satellite.png",
  MapLayerIds.terrain: "assets/images/maptype-terrain.png",
};

class MapLayer extends MapTileProvider {
  final MapLayerIds mapLayerId;
  final String mapKey;

  MapLayer(this.mapLayerId, {this.mapKey}) : super();

  @override
  List<LayerOptions> buildTileLayerOptions() {
    return mapLayerOptions[mapLayerId];
  }

  @override
  String get id => mapLayerId.enumToString();

  @override
  WidgetBuilder get imageBuilder => (context) => Image.asset(
        layerImage[mapLayerId],
        fit: BoxFit.cover,
      );

  @override
  String name(BuildContext context) {
    return mapLayerId.enumToString();
  }
}
