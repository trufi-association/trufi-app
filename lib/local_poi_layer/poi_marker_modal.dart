import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi/local_poi_layer/poi_marker_enum.dart';
import 'package:trufi/local_poi_layer/poi_layer_data.dart';
import 'package:trufi/translations/trufi_app_localizations.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/custom_location_selector.dart';

class POIMarkerModal extends StatelessWidget {
  final POILayerData element;
  final POILayerIds layerId;
  final LatLng point;
  final int? index;
  final void Function() onFetchPlan;
  const POIMarkerModal({
    Key? key,
    required this.layerId,
    required this.element,
    required this.point,
    required this.onFetchPlan,
    this.index,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final localizationTA = TrufiAppLocalization.of(context);
    return ListView(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                height: 35,
                width: 35,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: layerId.getImage(color: layerId.getColor),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${element.name} ${index ?? ''}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      layerId.getTranslate(localizationTA),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        CustomLocationSelector(
          onFetchPlan: onFetchPlan,
          locationData: LocationDetail(
            element.name,
            "",
            TrufiLatLng.fromLatLng(point),
          ),
        ),
      ],
    );
  }
}
