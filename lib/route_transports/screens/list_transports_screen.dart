import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi/route_transports/route_transports_cubit/route_transports_cubit.dart';
import 'package:trufi/route_transports/screens/widgets/tile_transport.dart';
import 'package:trufi/route_transports/screens/transport_overview_screen.dart';
import 'package:trufi_core/models/menu/default_pages_menu.dart';
import 'package:trufi_core/services/models_otp/pattern.dart';
import 'package:trufi_core/widgets/fetch_error_handler.dart';
import 'package:trufi_core/widgets/trufi_drawer.dart';

class ListTransportsScreen extends StatelessWidget {
  static const String route = "/list-transports";

  static MenuPageItem menuitem = MenuPageItem(
    id: route,
    selectedIcon: (context) => Icon(
      Icons.bus_alert,
      color: Colors.grey,
    ),
    notSelectedIcon: (context) => Icon(
      Icons.bus_alert,
      color: Colors.grey,
    ),
    name: (context) => Localizations.localeOf(context).languageCode == "en"
        ? "List of transports"
        : "List of transports",
  );

  const ListTransportsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routeTransportsCubit = RouteTransportsCubit();
    routeTransportsCubit.init().catchError(
          (error) => onFetchError(context, error as Exception),
        );
    ;
    return BlocBuilder<RouteTransportsCubit, RouteTransportsState>(
      bloc: routeTransportsCubit,
      builder: (context, state) {
        final listTransports = state.transports;
        return Scaffold(
          appBar: AppBar(
            title: Text("List of transport"),
            actions: [
              IconButton(
                onPressed: () => routeTransportsCubit.refresh().catchError(
                      (error) => onFetchError(context, error as Exception),
                    ),
                icon: Icon(Icons.refresh),
              ),
              SizedBox(width: 10),
            ],
          ),
          body: listTransports.length > 0
              ? ListView.builder(
                  itemCount: listTransports.length,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  itemBuilder: (buildCOntext, index) {
                    final PatternOtp transport = listTransports[index];
                    return Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 15),
                          child: TileTransport(
                            patternOtp: transport,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: routeTransportsCubit,
                                    child: TransportOverviewScreen(
                                        transport: transport),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
          drawer: const TrufiDrawer(ListTransportsScreen.route),
        );
      },
    );
  }
}
