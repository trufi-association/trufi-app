@Timeout(Duration(minutes: 3))
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi/main.dart'
    show cochabambaPlannerConfig, cochabambaWebPlannerConfig;
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// Issue #65: the offline planner boards only at the `maxStopCandidates`
/// stops nearest to the origin and to the destination, and with the default
/// of 150 that pool falls short of the 800 m walking radius at half of
/// Cochabamba's stops (synthetic stops ~100 m apart). A line whose nearest
/// stop is inside the radius but beyond the pool cannot be boarded at all.
///
/// Plans two trips found by the sweep of #65 against the bundled feed, with
/// the app's exact configuration and with smaller pools, through the same
/// provider the app wires:
///
/// - **A, truncated at the origin.** Calle Oruro (downtown, 712 stops within
///   800 m: the 150th is 285 m away, the 600th 725 m) → Avenida Camilo
///   Torrez. The Trufi 148 boards at Calle 16 de Julio y Calle Federico
///   Blanco, 787 m from the origin (the 693rd stop), and alights 207 m from
///   the destination: a direct ride, first of the ten the app offers, that
///   pools of 150 and 600 never see (they answer 13, 010, 138, 110, 5).
/// - **B, truncated at the destination.** Calle Achanq'ara y Calle Quripacha
///   (north, 157 stops within 800 m) → Avenida Valle Hermoso (250 stops
///   within 800 m, the 150th at 630 m). The Trufi 010 boards 72 m from the
///   origin and alights at Avenida Los Angeles, 684 m from the destination
///   (the 170th stop): with 150 only the 110 is offered.
///
/// The app's config but for the pool, so the comparison stays honest if the
/// app's radius or transfer limit ever changes.
TrufiPlannerConfig withPool(int pool) => TrufiPlannerConfig.local(
  gtfsAsset: cochabambaPlannerConfig.gtfsAsset!,
  maxWalkingDistance: cochabambaPlannerConfig.maxWalkingDistance,
  maxTransfers: cochabambaPlannerConfig.maxTransfers,
  maxStopCandidates: pool,
  persistIndex: false,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Stops of the feed (the sweep's endpoints) — see the doc above.
  const calleOruro = LatLng(-17.3838933, -66.1587556);
  const avenidaCamiloTorrez = LatLng(-17.4280795, -66.1323526);
  const calleAchanqara = LatLng(-17.3502091, -66.1661988);
  const avenidaValleHermoso = LatLng(-17.4400795, -66.1230961);
  const line148 = '148'; // route_id 123, "Trufi 148"
  const line010 = '010'; // route_id 48 / 133, "Trufi 010"

  final appProvider = TrufiPlannerProvider(config: cochabambaPlannerConfig);
  final oldPool = TrufiPlannerProvider(config: withPool(150));
  final pool600 = TrufiPlannerProvider(config: withPool(600));

  Future<List<Itinerary>> planWith(
    TrufiPlannerProvider provider,
    LatLng from,
    LatLng to,
  ) async {
    final plan = await provider.fetchPlan(
      from: RoutingLocation(position: from, description: 'from'),
      to: RoutingLocation(position: to, description: 'to'),
      numItineraries: 20, // the app's RoutingEngineManager.maxItineraries
      dateTime: DateTime(2026, 10, 30, 12), // the app pins searches to 12:00
    );
    expect(plan.type, isNot('PLANNER_ERROR'));
    return (plan.itineraries ?? const [])
        .where((it) => it.legs.any((leg) => leg.transitLeg))
        .toList();
  }

  List<String> linesOf(Itinerary it) => [
    for (final leg in it.legs)
      if (leg.transitLeg) leg.route?.shortName ?? leg.shortName ?? '?',
  ];

  bool offers(List<Itinerary> its, String line) =>
      its.any((it) => linesOf(it).contains(line));

  test('the app plans with every stop within 800 m (pool of 800)', () {
    expect(cochabambaPlannerConfig.isLocal, isTrue);
    expect(cochabambaPlannerConfig.maxWalkingDistance, 800);
    expect(cochabambaPlannerConfig.maxTransfers, 1);
    // No point of this feed has more than 778 stops within 800 m.
    expect(cochabambaPlannerConfig.maxStopCandidates, 800);
    // The web planner searches with the same knobs (trufi-server-planner
    // reads them from the request since trufi-server-planner#10).
    expect(cochabambaWebPlannerConfig.isRemote, isTrue);
    expect(
      cochabambaWebPlannerConfig.maxStopCandidates,
      cochabambaPlannerConfig.maxStopCandidates,
    );
    expect(
      cochabambaWebPlannerConfig.maxWalkingDistance,
      cochabambaPlannerConfig.maxWalkingDistance,
    );
    expect(
      cochabambaWebPlannerConfig.maxTransfers,
      cochabambaPlannerConfig.maxTransfers,
    );
  });

  test('no stop of the bundled feed has more neighbours within the walking '
      'radius than the pool', () async {
    // The guard that keeps the value honest across feed refreshes (#53):
    // if a denser feed ever puts more stops than the pool within 800 m of
    // a stop, the pool truncates the radius again — raise it (any value
    // above the stops in range costs the same per query).
    await appProvider.initialize();
    final spatial = appProvider.dataSource.spatialIndex!;
    final stops = appProvider.dataSource.data!.stops.values;
    final radius = cochabambaPlannerConfig.maxWalkingDistance;
    var densest = 0;
    String densestStop = '';
    for (final stop in stops) {
      final n = spatial.findStopsInRadius(LatLng(stop.lat, stop.lon), radius);
      if (n.length > densest) {
        densest = n.length;
        densestStop = stop.name;
      }
    }
    expect(stops.length, greaterThan(20000));
    expect(
      densest,
      lessThanOrEqualTo(cochabambaPlannerConfig.maxStopCandidates),
      reason:
          '$densest stops within $radius m of "$densestStop": '
          'raise maxStopCandidates in lib/main.dart',
    );
  });

  test('A: from Calle Oruro the 148 is offered as a direct ride', () async {
    final its = await planWith(appProvider, calleOruro, avenidaCamiloTorrez);
    expect(offers(its, line148), isTrue, reason: its.map(linesOf).toString());
    final direct = its.firstWhere((it) => linesOf(it).contains(line148));
    expect(linesOf(direct), [line148]);
    // Boards inside the radius, beyond what a pool of 600 reaches (725 m).
    final walkToStop = direct.legs.first;
    expect(walkToStop.transitLeg, isFalse);
    expect(walkToStop.distance, greaterThan(725));
    expect(
      walkToStop.distance,
      lessThanOrEqualTo(cochabambaPlannerConfig.maxWalkingDistance),
    );
  });

  test('A: with a pool of 150 or 600 the 148 disappears', () async {
    for (final provider in [oldPool, pool600]) {
      final its = await planWith(provider, calleOruro, avenidaCamiloTorrez);
      expect(its, isNotEmpty);
      expect(
        offers(its, line148),
        isFalse,
        reason:
            'pool ${provider.config.maxStopCandidates}: '
            '${its.map(linesOf)}',
      );
    }
  });

  test('B: towards Avenida Valle Hermoso the 010 is offered', () async {
    final its = await planWith(
      appProvider,
      calleAchanqara,
      avenidaValleHermoso,
    );
    expect(offers(its, line010), isTrue, reason: its.map(linesOf).toString());
    final direct = its.firstWhere((it) => linesOf(it).contains(line010));
    expect(linesOf(direct), [line010]);
    // Alights inside the radius, beyond what a pool of 150 reaches (630 m).
    final walkFromStop = direct.legs.last;
    expect(walkFromStop.transitLeg, isFalse);
    expect(walkFromStop.distance, greaterThan(630));
  });

  test('B: with the old pool of 150 the 010 disappears', () async {
    final its = await planWith(oldPool, calleAchanqara, avenidaValleHermoso);
    expect(its, isNotEmpty);
    expect(offers(its, line010), isFalse, reason: its.map(linesOf).toString());
  });
}
