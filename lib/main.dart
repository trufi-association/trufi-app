import 'package:flutter/material.dart';
import 'package:trufi/configuration_service.dart';
import 'package:trufi/drawer_menu/drawer_menu.dart';
import 'package:trufi/map_leyers.dart';
import 'package:trufi/theme/theme.dart';
import 'package:trufi_core/services/plan_request/online_graphql_repository/graphql_client/hive_init.dart';
import 'package:trufi_core/trufi_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  runApp(
    TrufiApp(
      configuration: setupConfiguration(),
      theme: mainTheme,
      bottomBarTheme: bottomBarTheme,
      menuItems: menuItems,
      mapTileProviders: [
        MapLayer(MapLayerIds.streets),
        MapLayer(MapLayerIds.satellite),
        MapLayer(MapLayerIds.terrain),
      ],
    ),
  );
}
