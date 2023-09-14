import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pf_user_tracking/translations/user_tracking_localizations.dart';
import 'package:routemaster/routemaster.dart';
import 'package:pf_user_tracking/bloc/tracking/tracking_cubit.dart';
import 'package:pf_user_tracking/screens/tracking_home_screen.dart';
import 'package:pf_user_tracking/screens/tracking_route_screen.dart';
import 'package:trufi/pages/tracking/maps/map_tracking_provider.dart';
import 'package:trufi_core/base/widgets/drawer/menu/default_pages_menu.dart';

class TrackingScreen extends StatelessWidget {
  static const String route = "/TrackingScreen";
  static final menuPage = MenuPageItem(
    id: TrackingScreen.route,
    selectedIcon: (context) => Icon(
      Icons.alt_route,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
    ),
    notSelectedIcon: (context) => const Icon(
      Icons.alt_route,
      color: Colors.grey,
    ),
    name: (context) {
      return UserTrackingLocalization.of(context).menuTraceRoute;
    },
  );

  final Widget Function(BuildContext) drawerBuilder;
  final MapTrackingProvider mapRouteProvider;

  const TrackingScreen({
    Key? key,
    required this.drawerBuilder,
    required this.mapRouteProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = UserTrackingLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.menuTraceRoute),
      ),
      drawer: drawerBuilder(context),
      body: Stack(
        children: [
          mapRouteProvider.mapChooseLocationBuilder(context),
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

class OverlayGPSButton extends StatelessWidget {
  const OverlayGPSButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = UserTrackingLocalization.of(context);
    return Positioned(
      bottom: 25,
      left: 10,
      child: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 4, 0),
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF4fa6a6),
                child: const Icon(
                  Icons.alt_route,
                  color: Colors.white,
                ),
                onPressed: () {
                  Routemaster.of(context).push(TrackingScreen.route);
                },
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                message: localization.trackingInfoButton,
                showDuration: const Duration(seconds: 10),
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(horizontal: 50,vertical: 0),
                preferBelow: false,
                textStyle: const TextStyle(color: Color(0xFF4fa6a6)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: const Color(0xFF4fa6a6),
                    style: BorderStyle.solid,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 2.0,
                      spreadRadius: 1.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF4fa6a6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
