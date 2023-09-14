import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trufi/local_poi_layer/markers_from_assets.dart';
import 'package:trufi/translations/trufi_app_localizations.dart';

enum POILayerIds {
  attractionsAndMonuments,
  parksAndSquares,
  cinemas,
  pharmacies,
  hospitals,
  schools,
  institutes,
  shoppingCentersAndSupermarkets,
  interprovincialStops,
  stadiumsAndSportsComplexes,
  libraries,
  terminalsAndStations,
  museumsAndArtGalleries,
  universities,
}

extension LayerIdsToString on POILayerIds {
  static final Map<POILayerIds, String> _enumStrings = {
    POILayerIds.attractionsAndMonuments: "LayerIds.attractionsAndMonuments",
    POILayerIds.parksAndSquares: "LayerIds.parksAndSquares",
    POILayerIds.cinemas: "LayerIds.cinemas",
    POILayerIds.pharmacies: "LayerIds.pharmacies",
    POILayerIds.hospitals: "LayerIds.hospitals",
    POILayerIds.schools: "LayerIds.schools",
    POILayerIds.institutes: "LayerIds.institutes",
    POILayerIds.shoppingCentersAndSupermarkets:
        "LayerIds.shoppingCentersAndSupermarkets",
    POILayerIds.interprovincialStops: "LayerIds.interprovincialStops",
    POILayerIds.stadiumsAndSportsComplexes:
        "LayerIds.stadiumsAndSportsComplexes",
    POILayerIds.libraries: "LayerIds.libraries",
    POILayerIds.terminalsAndStations: "LayerIds.terminalsAndStations",
    POILayerIds.museumsAndArtGalleries: "LayerIds.museumsAndArtGalleries",
    POILayerIds.universities: "LayerIds.universities",
  };

  static final Map<POILayerIds, String> _layerFileNames = {
    POILayerIds.attractionsAndMonuments: "attractions&Monuments.geojson",
    POILayerIds.parksAndSquares: "parks&Squares.geojson",
    POILayerIds.cinemas: "cinemas.geojson",
    POILayerIds.pharmacies: "pharmacies.geojson",
    POILayerIds.hospitals: "hospitals.geojson",
    POILayerIds.schools: "schools.geojson",
    POILayerIds.institutes: "institutes.geojson",
    POILayerIds.shoppingCentersAndSupermarkets:
        "shoppingCenters&Supermarkets.geojson",
    POILayerIds.interprovincialStops: "interprovincialStops.geojson",
    POILayerIds.stadiumsAndSportsComplexes: "stadiums&SportsComplexes.geojson",
    POILayerIds.libraries: "libraries.geojson",
    POILayerIds.terminalsAndStations: "terminals&Stations.geojson",
    POILayerIds.museumsAndArtGalleries: "museums&ArtGalleries.geojson",
    POILayerIds.universities: "universities.geojson",
  };

  static String? _translates(
      POILayerIds enumData, TrufiAppLocalization localization) {
    return {
      POILayerIds.attractionsAndMonuments:
          localization.layerAttractionsAndMonuments,
      POILayerIds.parksAndSquares: localization.layerParksAndSquares,
      POILayerIds.cinemas: localization.layerCinemas,
      POILayerIds.pharmacies: localization.layerPharmacies,
      POILayerIds.hospitals: localization.layerHospitals,
      POILayerIds.schools: localization.layerSchools,
      POILayerIds.institutes: localization.layerInstitutes,
      POILayerIds.shoppingCentersAndSupermarkets:
          localization.layerShoppingCentersAndSupermarkets,
      POILayerIds.interprovincialStops: localization.layerInterprovincialStops,
      POILayerIds.stadiumsAndSportsComplexes:
          localization.layerStadiumsAndSportsComplexes,
      POILayerIds.libraries: localization.layerLibraries,
      POILayerIds.terminalsAndStations: localization.layerTerminalsAndStations,
      POILayerIds.museumsAndArtGalleries:
          localization.layerMuseumsAndArtGalleries,
      POILayerIds.universities: localization.layerUniversities,
    }[enumData];
  }

  static Widget? _images(POILayerIds transportMode, Color? color) {
    switch (transportMode) {
      case POILayerIds.attractionsAndMonuments:
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: SvgPicture.string(attractionsAndMonumentsIcon),
        );
      case POILayerIds.parksAndSquares:
        return Icon(Icons.park_outlined, color: color);
      case POILayerIds.cinemas:
        return Icon(Icons.theaters_outlined, color: color);
      case POILayerIds.pharmacies:
        return Icon(Icons.local_pharmacy_outlined, color: color);
      case POILayerIds.hospitals:
        return Icon(Icons.local_hospital_outlined, color: color);
      case POILayerIds.schools:
        return Padding(
          padding: const EdgeInsets.all(1.0),
          child: SvgPicture.string(schoolsIcon),
        );
      case POILayerIds.institutes:
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: SvgPicture.string(institutesIcon),
        );
      case POILayerIds.shoppingCentersAndSupermarkets:
        return Icon(Icons.shopping_cart_outlined, color: color);
      case POILayerIds.interprovincialStops:
        return Padding(
          padding: const EdgeInsets.all(2),
          child: SvgPicture.string(interprovincialStopsIcon),
        );
      case POILayerIds.stadiumsAndSportsComplexes:
        return Padding(
          padding: const EdgeInsets.all(1.0),
          child: SvgPicture.string(stadiumsAndSportsComplexesIcon),
        );
      case POILayerIds.libraries:
        return Icon(Icons.local_library_outlined, color: color);
      case POILayerIds.terminalsAndStations:
        return Icon(Icons.train_outlined, color: color);
      case POILayerIds.museumsAndArtGalleries:
        return Icon(Icons.museum_outlined, color: color);
      case POILayerIds.universities:
        return Padding(
          padding: const EdgeInsets.all(1.0),
          child: SvgPicture.string(universitiesIcon),
        );
      default:
        return null;
    }
  }

  static final Map<POILayerIds, Color> _colors = {
    POILayerIds.attractionsAndMonuments: Colors.white,
    POILayerIds.parksAndSquares: Colors.white,
    POILayerIds.cinemas: Colors.white,
    POILayerIds.pharmacies: Colors.white,
    POILayerIds.hospitals: Colors.white,
    POILayerIds.schools: Colors.white,
    POILayerIds.institutes: Colors.white,
    POILayerIds.shoppingCentersAndSupermarkets: Colors.white,
    POILayerIds.interprovincialStops: Colors.white,
    POILayerIds.stadiumsAndSportsComplexes: Colors.white,
    POILayerIds.libraries: Colors.white,
    POILayerIds.terminalsAndStations: Colors.white,
    POILayerIds.museumsAndArtGalleries: Colors.white,
    POILayerIds.universities: Colors.white,
  };

  static final Map<POILayerIds, Color> _backgroundColors = {
    POILayerIds.attractionsAndMonuments: const Color(0xFF16510B),
    POILayerIds.parksAndSquares: const Color(0xFF67AD5B),
    POILayerIds.cinemas: const Color(0xFFF6A224),
    POILayerIds.pharmacies: const Color(0xFF66A4A5),
    POILayerIds.hospitals: const Color(0xFFC63361),
    POILayerIds.schools: const Color(0xFF67AD5B),
    POILayerIds.institutes: const Color(0xFF66A4A5),
    POILayerIds.shoppingCentersAndSupermarkets: const Color(0xFF712893),
    POILayerIds.interprovincialStops: const Color(0xFF66A4A5),
    POILayerIds.stadiumsAndSportsComplexes: const Color(0xFF66A4A5),
    POILayerIds.libraries: const Color(0xFFF6A224),
    POILayerIds.terminalsAndStations: const Color(0xFFC63361),
    POILayerIds.museumsAndArtGalleries: const Color(0xFFC63361),
    POILayerIds.universities: const Color(0xFFC63361),
  };
  static final Map<POILayerIds, double> _circularRadius = {
    POILayerIds.attractionsAndMonuments: 20,
    POILayerIds.parksAndSquares: 20,
    POILayerIds.cinemas: 20,
    POILayerIds.pharmacies: 20,
    POILayerIds.hospitals: 20,
    POILayerIds.schools: 20,
    POILayerIds.institutes: 20,
    POILayerIds.shoppingCentersAndSupermarkets: 20,
    POILayerIds.interprovincialStops: 20,
    POILayerIds.stadiumsAndSportsComplexes: 20,
    POILayerIds.libraries: 20,
    POILayerIds.terminalsAndStations: 20,
    POILayerIds.museumsAndArtGalleries: 20,
    POILayerIds.universities: 20,
  };

  String getTranslate(TrufiAppLocalization localization) =>
      _translates(this, localization) ?? 'LayerIds type not found';

  Color get getColor => _colors[this] ?? Colors.red;

  Color get getBackgroundColor => _backgroundColors[this] ?? Colors.red;

  String get getString => _enumStrings[this] ?? '';

  String get getFileName => _layerFileNames[this] ?? '';

  Widget getImage({Color? color, double size = 24}) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all((_circularRadius[this] ?? 5) > 10 ? 3 : 2),
      decoration: BoxDecoration(
        color: _backgroundColors[this],
        borderRadius: BorderRadius.circular(_circularRadius[this] ?? 5),
        border: Border.all(
          color: color ?? _colors[this] ?? Colors.transparent,
          width: 0.7,
        ),
      ),
      child: FittedBox(
        child: _images(this, color ?? _colors[this]) ??
            const Icon(
              Icons.error,
              color: Colors.red,
            ),
      ),
    );
  }
}
