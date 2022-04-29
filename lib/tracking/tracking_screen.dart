import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routemaster/routemaster.dart';
import 'package:pf_user_tracking/bloc/tracking/tracking_cubit.dart';
import 'package:pf_user_tracking/screens/tracking_home_screen.dart';
import 'package:pf_user_tracking/screens/tracking_route_screen.dart';
import 'package:trufi/tracking/maps/map_tracking_provider.dart';

class TrackingScreen extends StatelessWidget {
  static const String route = "/TrackingScreen";
  final Widget Function(BuildContext) drawerBuilder;
  final MapTrackingProvider mapRouteProvider;

  const TrackingScreen({
    Key? key,
    required this.drawerBuilder,
    required this.mapRouteProvider,
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
          mapRouteProvider.mapChooseLocationBuilder(context),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Stack(
              children: const [
                TrackingModal(),
              ],
            ),
          ),
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

class OverlayGPSButton extends StatelessWidget {
  const OverlayGPSButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 5,
      child: FloatingActionButton(
        backgroundColor: const Color(0xFF4fa6a6),
        child: const Icon(Icons.alt_route),
        onPressed: () {
          Navigator.pop(context);
          Routemaster.of(context).push(TrackingScreen.route);
        },
      ),
    );
  }
}
