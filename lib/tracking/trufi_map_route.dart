import 'dart:async';
import 'package:async_executor/async_executor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/blocs/providers/app_review_provider.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/pages/home/map_route_cubit/map_route_cubit.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/load_location.dart';
import 'package:trufi_core/base/widgets/maps/buttons/crop_button.dart';
import 'package:trufi_core/base/widgets/maps/trufi_map.dart';
import 'package:trufi_core/base/widgets/maps/trufi_map_cubit/trufi_map_cubit.dart';
import 'package:trufi_core/base/widgets/maps/utils/trufi_map_utils.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

import 'package:pf_user_tracking/bloc/tracking/service.dart';
import 'package:pf_user_tracking/bloc/tracking/tracking_cubit.dart';
import 'package:pf_user_tracking/screens/tracking_home_screen.dart';
import 'package:pf_user_tracking/screens/tracking_route_screen.dart';
import 'package:pf_user_tracking/translations/user_tracking_localizations.dart';

typedef MapRouteBuilder = Widget Function(
  BuildContext,
  TrufiMapController,
);

class TrufiMapRoute extends StatefulWidget {
  final TrufiMapController trufiMapController;
  final AsyncExecutor asyncExecutor;
  final String mapTilesUrl;
  const TrufiMapRoute({
    Key? key,
    required this.trufiMapController,
    required this.asyncExecutor,
    required this.mapTilesUrl,
  }) : super(key: key);

  @override
  State<TrufiMapRoute> createState() => _TrufiMapRouteState();
}

class _TrufiMapRouteState extends State<TrufiMapRoute>
    with TickerProviderStateMixin {
  final _cropButtonKey = GlobalKey<CropButtonState>();
  Marker? tempMarker;

  @override
  Widget build(BuildContext context) {
    final mapRouteState = context.read<MapRouteCubit>().state;
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    return Stack(
      children: [
        BlocBuilder<TrufiMapController, TrufiMapState>(
          bloc: widget.trufiMapController,
          builder: (context, state) {
            return TrufiMap(
              mapTilesUrl: widget.mapTilesUrl,
              trufiMapController: widget.trufiMapController,
              layerOptionsBuilder: (context) => [
                if (state.unselectedPolylinesLayer != null)
                  state.unselectedPolylinesLayer!,
                if (state.selectedPolylinesLayer != null)
                  state.selectedPolylinesLayer!,
                if (state.unselectedMarkersLayer != null)
                  state.unselectedMarkersLayer!,
                if (state.selectedMarkersLayer != null)
                  state.selectedMarkersLayer!,
                if (state.fromMarkerLayer != null) state.fromMarkerLayer!,
                if (state.toMarkerLayer != null) state.toMarkerLayer!,
                MarkerLayerOptions(markers: [
                  if (mapRouteState.fromPlace != null)
                    mapConfiguratiom.markersConfiguration
                        .buildFromMarker(mapRouteState.fromPlace!.latLng),
                  if (mapRouteState.toPlace != null)
                    mapConfiguratiom.markersConfiguration
                        .buildToMarker(mapRouteState.toPlace!.latLng),
                  if (tempMarker != null) tempMarker!,
                ]),
              ],
              onTap: (_, point) {
                if (widget.trufiMapController.state.unselectedPolylinesLayer !=
                    null) {
                  _handleOnMapTap(context, point);
                } else {
                  onMapPress(point);
                }
              },
              onLongPress: (_, point) => onMapPress(point),
              onPositionChanged: _handleOnMapPositionChanged,
              floatingActionButtons: Column(
                children: [
                  CropButton(
                    key: _cropButtonKey,
                    onPressed: _handleOnCropPressed,
                  ),
                ],
              ),
            );
          },
        ),
        const TrackingModal(),
      ],
    );
  }

  void _handleOnCropPressed() {
    widget.trufiMapController.moveCurrentBounds(tickerProvider: this);
  }

  void _handleOnMapPositionChanged(
    MapPosition position,
    bool hasGesture,
  ) {
    if (widget.trufiMapController.selectedBounds.isValid &&
        position.bounds != null) {
      _cropButtonKey.currentState?.setVisible(
        visible: !position.bounds!
            .containsBounds(widget.trufiMapController.selectedBounds),
      );
    }
  }

  void _handleOnMapTap(BuildContext context, LatLng point) {
    final Itinerary? tappedItinerary = itineraryForPoint(
        widget.trufiMapController.itineraries,
        widget.trufiMapController.state.unselectedPolylinesLayer!.polylines,
        point);
    if (tappedItinerary != null) {
      context.read<MapRouteCubit>().selectItinerary(tappedItinerary);
    }
  }

  void onMapPress(LatLng location) {
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    setState(() {
      tempMarker =
          mapConfiguratiom.markersConfiguration.buildToMarker(location);
    });
    widget.trufiMapController.move(
      center: location,
      zoom: mapConfiguratiom.chooseLocationZoom,
      tickerProvider: this,
    );
    _showBottomMarkerModal(
      location: location,
    ).then((value) {
      setState(() {
        tempMarker = null;
      });
    });
  }

  Future<void> _showBottomMarkerModal({
    required LatLng location,
  }) async {
    return showTrufiModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (buildContext) => LoadLocation(
        location: location,
        onFetchPlan: () => _callFetchPlan(context),
      ),
    );
  }

  Future<void> _callFetchPlan(BuildContext context) async {
    final mapRouteCubit = context.read<MapRouteCubit>();
    final mapRouteState = mapRouteCubit.state;
    if (mapRouteState.toPlace == null || mapRouteState.fromPlace == null) {
      return;
    }
    widget.asyncExecutor.run(
      context: context,
      onExecute: mapRouteCubit.fetchPlan,
      onFinish: (_) {
        AppReviewProvider().incrementReviewWorthyActions();
      },
    );
  }
}

class TrackingModal extends StatelessWidget {
  const TrackingModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final trackingCubit = context.watch<TrackingCubit>();
    final trackingCubitState = trackingCubit.state;
    return (trackingCubitState.status == BlocLoadStatus.waiting)
        ? const TrackingHomeScreen()
        : (trackingCubitState.status == BlocLoadStatus.tracking)
            ? const TrackingRouteScreen()
            : const Center(
                child: CircularProgressIndicator(),
              );
  }
}
