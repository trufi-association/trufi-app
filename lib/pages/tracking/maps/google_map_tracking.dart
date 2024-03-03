// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:pf_user_tracking/bloc/tracking/tracking_cubit.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// import 'package:trufi_core/base/models/trufi_latlng.dart';
// import 'package:trufi_core/base/widgets/base_maps/google_maps/google_map.dart';
// import 'package:trufi_core/base/widgets/base_maps/google_maps/google_map_controller.dart';
// import 'package:trufi_core/base/widgets/base_maps/google_maps/widget_marker/marker_generator.dart';

// class GoogleMapTracking extends StatelessWidget {
//   final TGoogleMapController trufiMapController;

//   const GoogleMapTracking({
//     Key? key,
//     required this.trufiMapController,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final trackingCubit = context.watch<TrackingCubit>();
//     final trackingCubitState = trackingCubit.state;
//     final routes = trackingCubitState.currentRouteId == ""
//         ? <TrufiLatLng>[]
//         : trackingCubitState.routes[trackingCubitState.currentRouteId]!.routes
//             .map((e) => TrufiLatLng.fromLatLng(e.toLatLng()))
//             .toList();
//     final current = !trackingCubitState.lastTrack.fake
//         ? trackingCubitState.lastTrack.toLatLng()
//         : null;

//     Set<Polyline> polylines = {
//       trufiMapController.addPolyline(
//         points: TrufiLatLng.toListGoogleLatLng(routes),
//         polylineId: 'currentTracking',
//         color: Colors.green,
//         strokeWidth: 1,
//       ),
//     };

//     trufiMapController.onReady.then((value) {
//       if (current != null) {
//         trufiMapController.move(
//             center: TrufiLatLng.fromLatLng(current), zoom: 16);
//       }
//     });
//     return Stack(
//       children: [
//         MarkerGenerator(
//           widgetMarkers: [
//             if (routes.isNotEmpty)
//               WidgetMarker(
//                 position: routes.last.toGoogleLatLng(),
//                 markerId: const MarkerId('trackingmarker'),
//                 anchor: const Offset(0.5, 0.5),
//                 consumeTapEvents: true,
//                 widget: Container(
//                   height: 5,
//                   width: 5,
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               )
//           ],
//           onMarkerGenerated: (_markers, _listIdsRemove) {
//             trufiMapController.onMarkerGenerated(
//               _markers,
//               _listIdsRemove,
//               newPolylines: polylines,
//             );
//           },
//         ),
//         TGoogleMap(
//           trufiMapController: trufiMapController,
//           onCameraMove: (cameraPosition) {},
//         ),
//       ],
//     );
//   }
// }
