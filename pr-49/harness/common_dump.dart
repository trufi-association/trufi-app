// Fresh-review harness that compiles against BOTH main and the PR branch
// (public API common to both). Dumps the connection table and the results
// of a fixed query set to JSON so two builds can be diffed offline.
//
//   dart run tool/common_dump.dart <feed.zip> <out.json> <maxWalk> [--conns out.txt] [--sanaa]
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';

const kResults = 5;
const kPool = 150;

final sanaaCases = <(String, LatLng, LatLng)>[
  ('A-fwd', LatLng(15.29408, 44.26392), LatLng(15.33736, 44.19833)),
  ('A-rev', LatLng(15.33736, 44.19833), LatLng(15.29408, 44.26392)),
  ('B-fwd', LatLng(15.2952334, 44.2623529), LatLng(15.3536032, 44.1786948)),
  ('B-rev', LatLng(15.3536032, 44.1786948), LatLng(15.2952334, 44.2623529)),
];

Future<void> main(List<String> args) async {
  final feed = args[0];
  final out = args[1];
  final maxWalk = double.parse(args[2]);
  final connsOut =
      args.contains('--conns') ? args[args.indexOf('--conns') + 1] : null;
  final isSanaa = args.contains('--sanaa');

  var sw = Stopwatch()..start();
  final data = await GtfsParser.parseFromFile(feed);
  final parseMs = sw.elapsedMilliseconds;
  sw = Stopwatch()..start();
  final spatial = GtfsSpatialIndex(data.stops);
  final spatialMs = sw.elapsedMilliseconds;
  sw = Stopwatch()..start();
  final index = GtfsRouteIndex(data);
  final buildMs = sw.elapsedMilliseconds;
  final service = GtfsRoutingService(
    data: data,
    spatialIndex: spatial,
    routeIndex: index,
  );

  var conns = 0;
  final sink = connsOut != null ? File(connsOut).openWrite() : null;
  for (var p = 0; p < index.patternCount; p++) {
    for (final c in index.getConnectionsFor(p)) {
      conns++;
      sink?.writeln('$p ${c.myStopIdx} ${c.otherPatternId} ${c.otherStopIdx}');
    }
  }
  await sink?.close();

  final fingerprints = <String>[];
  for (var p = 0; p < index.patternCount; p++) {
    final pat = index.patternById(p);
    fingerprints.add(
      '${pat.routeId}:${pat.stopIds.length}:${pat.stopIds.first}>${pat.stopIds.last}',
    );
  }

  final qs = <(String, LatLng, LatLng)>[];
  if (isSanaa) qs.addAll(sanaaCases);
  final stops = data.stops.values.toList();
  for (final (seed, count) in [(42, 40), (7, 300)]) {
    final rnd = Random(seed);
    for (var i = 0; i < count; i++) {
      qs.add((
        'rnd$seed-$i',
        stops[rnd.nextInt(stops.length)].position,
        stops[rnd.nextInt(stops.length)].position,
      ));
    }
  }

  final queries = <Map<String, dynamic>>[];
  var totalUs = 0;
  var maxUs = 0;
  for (final q in qs) {
    final t = Stopwatch()..start();
    final paths = service.findRoutes(
      origin: q.$2,
      destination: q.$3,
      maxWalkDistance: maxWalk,
      maxResults: kResults,
      maxStopCandidates: kPool,
      maxDirects: kResults,
      maxTransferPaths: kResults,
    );
    final us = t.elapsedMicroseconds;
    totalUs += us;
    if (us > maxUs) maxUs = us;
    queries.add({
      'id': q.$1,
      'from': [q.$2.latitude, q.$2.longitude],
      'to': [q.$3.latitude, q.$3.longitude],
      'us': us,
      'paths': [
        for (final p in paths)
          {
            'key': p.segments.map((s) => s.route.id).join('>'),
            'names': p.segments.map((s) => s.route.shortName.trim()).join('>'),
            'legs': [
              for (final s in p.segments)
                {
                  'r': s.route.id,
                  'p': s.pattern.id,
                  'from': s.fromStop.id,
                  'fi': s.fromIdx,
                  'to': s.toStop.id,
                  'ti': s.toIdx,
                  'transit': s.transitDistance.round(),
                  'stops': s.stops.length,
                  'shape': s.shapePoints.length,
                },
            ],
            'ow': p.originWalkDistance.round(),
            'dw': p.destinationWalkDistance.round(),
            'score': p.score.round(),
            'transfers': p.transfers,
          },
      ],
    });
  }

  final result = {
    'feed': feed,
    'stops': data.stops.length,
    'routes': data.routes.length,
    'patterns': index.patternCount,
    'connections': conns,
    'parseMs': parseMs,
    'spatialMs': spatialMs,
    'buildMs': buildMs,
    'fingerprints': fingerprints,
    'avgQueryMs': totalUs / 1000 / qs.length,
    'maxQueryMs': maxUs / 1000,
    'queries': queries,
  };
  File(out).writeAsStringSync(jsonEncode(result));
  stderr.writeln(
    'feed=$feed stops=${data.stops.length} patterns=${index.patternCount} '
    'connections=$conns parse=${parseMs}ms spatial=${spatialMs}ms '
    'build=${buildMs}ms queries=${qs.length} avg=${(totalUs / 1000 / qs.length).toStringAsFixed(2)}ms max=${(maxUs / 1000).toStringAsFixed(1)}ms',
  );
}
