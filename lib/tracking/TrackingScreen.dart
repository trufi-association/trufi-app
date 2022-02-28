import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:pf_user_tracking/bloc/tracking/tracking_cubit.dart';
import 'package:pf_user_tracking/screens/tracking_home_screen.dart';
import 'package:pf_user_tracking/screens/tracking_route_screen.dart';

import './tracking_map.dart';

class TrackingScreen extends StatelessWidget {
  static const String route = "/TrackingScreen";
  final Widget Function(BuildContext) drawerBuilder;
  final String mapTilesUrl;
  const TrackingScreen({
    Key? key,
    required this.drawerBuilder,
    required this.mapTilesUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UserTracking"),
      ),
      drawer: drawerBuilder(context),
      body: Stack(
        children: [
          TrackingMap(
            mapTilesUrl: mapTilesUrl,
          ),
          const TrackingModal(),
        ],
      ),
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
