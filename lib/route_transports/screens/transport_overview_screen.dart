import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi/route_transports/route_transports_cubit/route_transports_cubit.dart';
import 'package:trufi/route_transports/screens/widgets/bottom_stops_detail.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/services/models_otp/pattern.dart';
import 'package:trufi_core/widgets/custom_scrollable_container.dart';
import 'package:trufi_core/widgets/fetch_error_handler.dart';
import 'package:trufi_core/widgets/map/buttons/crop_button.dart';
import 'package:trufi_core/widgets/map/buttons/your_location_button.dart';
import 'package:trufi_core/widgets/map/trufi_map.dart';
import 'package:trufi_core/widgets/map/trufi_map_controller.dart';
import 'package:trufi_core/widgets/map/utils/trufi_map_utils.dart';

class TransportOverviewScreen extends StatefulWidget {
  final PatternOtp transport;
  const TransportOverviewScreen({
    Key key,
    @required this.transport,
  }) : super(key: key);

  @override
  _TransportOverviewScreenState createState() =>
      _TransportOverviewScreenState();
}

class _TransportOverviewScreenState extends State<TransportOverviewScreen>
    with TickerProviderStateMixin {
  final TrufiMapController _trufiMapController = TrufiMapController();
  final _cropButtonKey = GlobalKey<CropButtonState>();

  final LatLngBounds _selectedBounds = LatLngBounds();
  bool needsCameraUpdate = true;
  LatLng stopPointSelected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      if (!mounted) return;
      context
          .read<RouteTransportsCubit>()
          .fetchDataPattern(widget.transport)
          .then(
        (value) {
          if (mounted) {
            setState(() {
              decodePolyline(value.patternGeometry.points).forEach((point) {
                _selectedBounds.extend(point);
              });
            });
          }
        },
      ).catchError((error) => onFetchError(context, error as Exception));
    });
  }

  @override
  void dispose() {
    _trufiMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trufiConfiguration = context.read<ConfigurationCubit>().state;
    final localization = TrufiLocalization.of(context);
    if (needsCameraUpdate && _selectedBounds.isValid) {
      _trufiMapController.fitBounds(
        bounds: _selectedBounds,
        tickerProvider: this,
      );
      needsCameraUpdate = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.transport.route.mode.getTranslate(localization)),
            Text(' - ${widget.transport.route?.shortName ?? ''}'),
          ],
        ),
      ),
      body: BlocBuilder<RouteTransportsCubit, RouteTransportsState>(
        builder: (context, state) {
          final transport = state.transports.singleWhere(
              (element) => element.code == widget.transport.code,
              orElse: null);
          final points = transport?.patternGeometry?.points != null
              ? decodePolyline(transport.patternGeometry.points)
              : null;

          return CustomScrollableContainer(
            openedPosition: 200,
            bottomPadding: 100,
            body: Stack(
              children: [
                if (points == null)
                  LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  ),
                TrufiMap(
                  key: const ValueKey("TransportMap"),
                  controller: _trufiMapController,
                  onPositionChanged: _handleOnMapPositionChanged,
                  layerOptionsBuilder: (context) => points != null
                      ? [
                          PolylineLayerOptions(
                            polylines: [
                              Polyline(
                                points: points,
                                color: Color(
                                  int.tryParse(
                                          "0xFF${widget.transport.route?.color}") ??
                                      widget.transport.route.mode.color.value,
                                ),
                                strokeWidth: 6.0,
                              ),
                            ],
                          ),
                          if (stopPointSelected != null)
                            MarkerLayerOptions(
                              markers: [buildTransferMarker(stopPointSelected)],
                            ),
                          MarkerLayerOptions(markers: [
                            trufiConfiguration.map.markersConfiguration
                                .buildFromMarker(points[0]),
                            trufiConfiguration.map.markersConfiguration
                                .buildToMarker(points[points.length - 1]),
                          ]),
                        ]
                      : [],
                ),
                Positioned(
                  bottom: 0,
                  left: 10,
                  child: trufiConfiguration.map.mapAttributionBuilder(
                    context,
                  ),
                ),
                Positioned(
                  top: 16.0,
                  right: 16.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      YourLocationButton(
                        trufiMapController: _trufiMapController,
                      ),
                      const Padding(padding: EdgeInsets.all(4.0)),
                      CropButton(
                        key: _cropButtonKey,
                        onPressed: () => setState(() {
                          needsCameraUpdate = true;
                        }),
                      ),
                    ],
                  ),
                )
              ],
            ),
            panel: points != null
                ? BottomStopsDetails(
                    routeOtp: transport.route,
                    stops: transport.stops ?? [],
                    
                    moveTo: (point) {
                      setState(() {
                        stopPointSelected = point;
                      });
                      _trufiMapController.move(
                        center: point,
                        zoom: 15,
                        tickerProvider: this,
                      );
                    },
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          );
        },
      ),
    );
  }

  void _handleOnMapPositionChanged(
    MapPosition position,
    bool hasGesture,
  ) {
    if (_selectedBounds != null && _selectedBounds.isValid) {
      _cropButtonKey.currentState.setVisible(
        visible: !position.bounds.containsBounds(_selectedBounds),
      );
    }
  }
}
