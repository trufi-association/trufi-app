import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core/entities/plan_entity/route_entity.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/services/models_otp/stop.dart';

import 'stop_item_tile.dart';

class BottomStopsDetails extends StatelessWidget {
  final RouteEntity routeOtp;
  final List<Stop> stops;
  final Function(LatLng) moveTo;
  const BottomStopsDetails({
    Key key,
    @required this.routeOtp,
    @required this.stops,
    @required this.moveTo,
  })  : assert(routeOtp != null),
        assert(stops != null),
        assert(moveTo != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: stops.length,
            itemBuilder: (contextBuilde, index) {
              final Stop stop = stops[index];
              return Material(
                child: InkWell(
                  onTap: () => moveTo(LatLng(stop.lat, stop.lon)),
                  child: StopItemTile(
                    stop: stop,
                    color: Color(
                      int.tryParse("0xFF${routeOtp.color}") ??
                          routeOtp.mode.color.value,
                    ),
                    isLastElement: index == stops.length - 1,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
