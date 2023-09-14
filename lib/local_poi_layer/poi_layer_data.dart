import 'package:latlong2/latlong.dart';

enum GeometryType {
  point,
  polygon,
  multiPolygon,
  unknow,
}

extension GeometryTypeExtension on GeometryType {
  static final Map<GeometryType, String> enumStrings = {
    GeometryType.point: "Point",
    GeometryType.polygon: "Polygon",
    GeometryType.multiPolygon: "MultiPolygon",
  };

  static GeometryType fromString(String name) =>
      GeometryTypeExtension.enumStrings.keys.firstWhere(
        (key) => key.getString == name,
        orElse: () {
          return GeometryType.unknow;
        },
      );

  String get getString => enumStrings[this] ?? '';
}

class POILayerData {
  final String? id;
  final Geometry geometry;
  final String name;
  final String? nameEn;
  final String? nameDe;
  final String? popupContent;
  final String? popupContentEn;
  final String? popupContentDe;

  POILayerData({
    required this.id,
    required this.geometry,
    required this.name,
    required this.nameEn,
    required this.nameDe,
    required this.popupContent,
    required this.popupContentEn,
    required this.popupContentDe,
  });

  List<LatLng> get getPoints => geometry.centroides;
}

class Geometry {
  final GeometryType type;
  final List<List<LatLng>> coordinates;
  final List<LatLng> centroides;

  const Geometry({
    required this.type,
    required this.coordinates,
    required this.centroides,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) {
    final geometryType = GeometryTypeExtension.fromString(json["type"]);
    List<List<LatLng>> points = [];
    if (geometryType == GeometryType.unknow) {
    } else if (geometryType == GeometryType.point) {
      final point = json["coordinates"];
      points.add([LatLng(point[1] as double, point[0] as double)]);
    } else if (geometryType == GeometryType.polygon) {
      points = List<List<LatLng>>.from(
        (json['coordinates'] as List<dynamic>).map(
          (x) {
            return List<LatLng>.from((x as List<dynamic>).map(
              (y) => LatLng(y[1] as double, y[0] as double),
            ));
          },
        ),
      );
    } else if (geometryType == GeometryType.multiPolygon) {
      points = List<List<LatLng>>.from(
        (json['coordinates'] as List<dynamic>).map(
          (x) {
            return List<LatLng>.from(((x as List<dynamic>)[0]).map(
              (y) => LatLng(y[1] as double, y[0] as double),
            ));
          },
        ),
      );
    }

    return Geometry(
      type: geometryType,
      coordinates: points,
      centroides: geometryType == GeometryType.unknow
          ? []
          : points.map((e) => calculateCentroids(e)).toList(),
    );
  }
}

LatLng calculateCentroids(List<LatLng> vertices) {
  if (vertices.length < 2) {
    return vertices.first;
  }

  double area = 0.0;
  double cx = 0.0;
  double cy = 0.0;
  int vertexCount = vertices.length;

  for (int i = 0; i < vertexCount; i++) {
    LatLng current = vertices[i];
    LatLng next =
        vertices[(i + 1) % vertexCount]; // Wrap around for the last vertex
    double crossProduct = (current.latitude * next.longitude) -
        (next.latitude * current.longitude);
    area += crossProduct;
    cx += (current.latitude + next.latitude) * crossProduct;
    cy += (current.longitude + next.longitude) * crossProduct;
  }

  area /= 2.0;
  cx /= (6.0 * area);
  cy /= (6.0 * area);

  return LatLng(cx, cy);
}
