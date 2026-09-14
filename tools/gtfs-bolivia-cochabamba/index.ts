/**
 * Cochabamba GTFS generator.
 *
 * Uses trufi-gtfs-builder as a library. Output goes to ./out/.
 * The resulting gtfs.zip is what gets shipped to:
 *   - trufi-app/assets/routing/cochabamba.gtfs.zip (offline routing in the APK)
 *   - trufi-server-otp/cochabamba.gtfs.zip (OTP servers)
 *
 * Starting point: upstream example at
 * https://github.com/trufi-association/trufi-gtfs-builder/tree/v2.16.0/examples/Bolivia-Cochabamba
 *
 * Cochabamba-specific tweaks live below — adjust them here, not in upstream.
 */

import { osmToGtfs, OSMOverpassDownloader, OSMPBFReader } from 'trufi-gtfs-builder';
import type { RouteFare, TripDurationResolver } from 'trufi-gtfs-builder';
import * as path from 'path';
import * as fs from 'fs';

type DataSource = 'overpass' | 'pbf';

const DATA_SOURCE: DataSource = 'pbf';

const PBF_FILE = path.join(__dirname, '..', 'pbf-bolivia-cochabamba', 'out', 'cochabamba.osm.pbf');

const BOUNDING_BOX = {
  south: -17.709721,
  west: -66.440262,
  north: -17.261759,
  east: -65.577835,
};

// ── Travel times ─────────────────────────────────────────────────────────
// stop_times are estimates (timepoint=0). When the OSM relation carries a
// plausible `duration=*` (Mi Tren's lines do), the builder spreads that
// running time over the stops and the speed below is not used. Otherwise
// the trip is timed at an average speed per OSM route type:
//  - bus / minibus / share_taxi (micros and trufis): 20 km/h. The municipal
//    Dirección de Tráfico y Vialidad measured 10–11 km/h in congestion and
//    calls 25 km/h "satisfactory" (Opinión, 2017-03-09); the former 40 km/h
//    placeholder gave 30-minute estimates for micro H rides that take about
//    an hour (trufi-gtfs-builder#9).
//  - light_rail (Mi Tren): 32 km/h — what Línea Verde's `duration=00:51`
//    over 27 km implied when this was calibrated (May 2026 OSM; the current
//    PBF tags Verde `01:15` and Roja `00:20`, i.e. 22–25 km/h, and those
//    OSM values are what their trips use). The speed is only the fallback
//    for a missing or rejected duration — today, Línea Amarilla (see
//    `tripDuration` below).
//  - aerialway (Teleférico Cristo de la Concordia): 11 km/h — the line's
//    own top speed, 3 m/s (860 m of cable, 18 people per cabin; operator
//    figures as reported by Red Uno, 2025). The 0.76 km between its two
//    stops therefore takes ~4 min. Its OSM `duration=02:00` (two hours) is
//    rejected by the builder's plausibility guard until OSM says `00:05`.
// Interprovincial trufis (Punata, Sipe Sipe, Vinto…) share the 20 km/h of
// the urban lines on purpose: their real running times belong in OSM as
// `duration=*`, not in a second guessed speed here. Santiváñez (`00:45`) and
// Colomi (`01:00`) already carry one and are timed from it; Punata (46 km)
// does not yet and comes out at ~2 h 20 until it is tagged.
const SPEED_KMH_BY_ROUTE_TYPE: Record<string, number> = {
  light_rail: 32,
  aerialway: 11,
};
const DEFAULT_SPEED_KMH = 20;

// Floor for an OSM `duration=*` on a rail line, in km/h. The builder's own
// guard only rejects running times slower than walking (3 km/h) or faster
// than the mode's validator threshold, so Línea Amarilla's `duration=00:36`
// (relations 11678428 / 19604339: 5.6 km → 9.3 km/h) gets through and would
// publish a 36-minute trip for a ride of 12–16 minutes (the tag said `00:16`
// until May 2026; Unitel and Opinión time the ride at 12 and 16 min). No
// urban light rail averages below 15 km/h, so anything slower is treated as
// a tagging error and the trip is timed at the 32 km/h above (~10.5 min)
// until OSM is corrected — the fix belongs in OSM, this is the safety net.
const MIN_LIGHT_RAIL_KMH = 15;

const tripDuration: TripDurationResolver = (route, osmSeconds, lengthMeters) => {
  if (osmSeconds === undefined) return undefined;
  if (route.properties.route === 'light_rail' && lengthMeters > 0) {
    const impliedKmh = (lengthMeters / osmSeconds) * 3.6;
    if (impliedKmh < MIN_LIGHT_RAIL_KMH) {
      console.warn(
        `duration="${route.properties.duration}" on https://www.osm.org/relation/${route.properties.id} ` +
          `implies ${impliedKmh.toFixed(1)} km/h over ${(lengthMeters / 1000).toFixed(2)} km, below the ` +
          `${MIN_LIGHT_RAIL_KMH} km/h floor for light rail; timing the trip from vehicleSpeed instead`,
      );
      return undefined;
    }
  }
  return osmSeconds;
};

// ── Fares ────────────────────────────────────────────────────────────────
// Official tariff of the Cercado (the Cochabamba municipality): Bs 3 general,
// issued by Movilidad Urbana — the same figure trufi-app shows on its fares
// screen. It only holds INSIDE the Cercado: the trufi-bus syndicates based in
// the neighbouring municipalities (Quillacollo, Sacaba, Vinto, Sipe Sipe,
// Tiquipaya, …) charge their own fares, which we don't know, so their lines
// get no fare row at all unless OSM carries `charge=*` on the relation (Mi
// Tren, the teleférico, Trufi 130 and the long-distance trufis already do).
// Never write 0 for "unknown": in GTFS a price of 0 means the ride is free.
//
// The exception rule (`isIntermunicipal` below) is NAME-BASED, not
// geographic: it reads the operator, the `network` tag and the `ref` series,
// never the shape. Lines of Cercado-based operators that do cross into
// Colcapirhua, Quillacollo or Sacaba (micros E/L, trufis 8/14/25/46/106/
// 150/W, Cotapachi, micro Q) therefore still get Bs 3, and refs 200/252,
// whose mapped shape stays inside the Cercado, get none. Micros H and S are
// Cercado lines too, but their relations carry `network=BO:C:Cochabamba;
// BO:C:Sacaba` / `…;BO:C:Colcapirhua`, so signal 1 leaves them without a
// row — same outcome as the builder's own Cochabamba example for micro H.
// Same rule as examples/Bolivia-Cochabamba in trufi-gtfs-builder (#15).
const CERCADO_FARE: RouteFare = { price: 3, currency: 'BOB' };

// Municipalities of the metropolitan region other than Cochabamba itself.
const OTHER_MUNICIPALITIES = [
  'Sacaba', 'Quillacollo', 'Vinto', 'Sipe Sipe', 'Tiquipaya', 'Colcapirhua',
  'Itapaya', 'Punata', 'Santiváñez', 'Colomi',
];

/**
 * A line run by one of the intermunicipal syndicates, by any of three OSM
 * signals — all of them names, none of them geometry:
 *   1. `network=BO:C:<municipality>;…` lists a municipality other than
 *      Cochabamba (e.g. `BO:C:Cochabamba;BO:C:Sacaba`).
 *   2. `ref` 200-299 — the metropolitan trufi-bus series. Every 2xx ref in
 *      the data belongs to an operator based outside the Cercado (Urkupiña,
 *      1ro de mayo, 15 de agosto, El Paso, Santa Rosa de Lima, 3 de
 *      noviembre, Sacaba, Vinto, Sipe Sipe, Tiquipaya, Itapaya) or to an
 *      untagged variant of one of them (relation 20768907).
 *   3. The operator is named after another municipality
 *      ("Sindicato mixto de autotransporte Sacaba", "… trufibuses Vinto").
 */
function isIntermunicipal(tags: Record<string, any>): boolean {
  const network = String(tags.network || '');
  if (network.split(';').some((n) => n.startsWith('BO:C:') && n !== 'BO:C:Cochabamba')) {
    return true;
  }
  const refNumber = parseInt(String(tags.ref || ''), 10);
  if (refNumber >= 200 && refNumber <= 299) return true;
  const operator = String(tags.operator || '');
  return OTHER_MUNICIPALITIES.some((municipality) => operator.includes(municipality));
}

function getOsmDataGetter() {
  if (DATA_SOURCE === 'pbf') {
    if (!fs.existsSync(PBF_FILE)) {
      throw new Error(
        `PBF file not found: ${PBF_FILE}\n` +
        `Generate it with the sibling tool: cd ../pbf-bolivia-cochabamba && docker compose up --build`,
      );
    }
    return new OSMPBFReader(PBF_FILE);
  }
  return new OSMOverpassDownloader(BOUNDING_BOX);
}

async function main() {
  console.log(`Generating GTFS for Cochabamba (source: ${DATA_SOURCE})...`);

  await osmToGtfs({
    outputFiles: {
      outputDir: path.join(__dirname, 'out'),
      gtfs: true,
      gtfsZip: true,
      readme: true,
      log: true,
      stops: true,
      routes: false,
      trufiTPData: false,
    },
    geojsonOptions: {
      osmDataGetter: getOsmDataGetter(),
      transformTypes: ['bus', 'share_taxi', 'minibus', 'aerialway', 'light_rail'],
      // Routes excluded from the feed (problematic OSM relations).
      skipRoute: (route) =>
        ![2084702, 16533147, 17193322, 16648003, 17193322].includes(route.id),
    },
    gtfsOptions: {
      agencyTimezone: 'America/La_Paz',
      agencyUrl: 'https://www.cochabamba.bo/',
      cityName: 'cochabamba',
      defaultCalendar: () => 'Mo-Su 06:00-22:00',
      frequencyHeadway: () => 300,
      vehicleSpeed: (route: any) =>
        SPEED_KMH_BY_ROUTE_TYPE[route.properties.route] ?? DEFAULT_SPEED_KMH,
      tripDuration,
      // Most Cochabamba minibus lines have no physical stops mapped in
      // OSM, so they get `fakeStops` (a stop per shape node, then
      // segment-merge + gap-fill at `fakeStopsGapThreshold` density).
      // The few routes listed below DO have stops mapped in OSM and use
      // them directly.
      stopsConfig: (route: any) => {
        const ROUTES_WITH_OSM_STOPS = [
          11678428,
          19604339,
          9083839,
          14576927,
          9074378,
          14576926,
          6925236,
          6925237,
        ];
        if (ROUTES_WITH_OSM_STOPS.includes(route.properties.id)) {
          return { mode: 'osmStops', forceEndpointStops: true };
        }
        return { mode: 'fakeStops' };
      },
      fakeStopsGapThreshold: 100,
      // Currency assumed when a `charge=*` value has no ISO code. The
      // price itself comes from `fare` below (OSM first, then Bs 3 unless
      // the line belongs to an intermunicipal syndicate, then nothing).
      defaultFares: { currencyType: 'BOB' },
      fare: (route: any, osmFare: RouteFare | undefined) => {
        if (osmFare) return osmFare;
        if (isIntermunicipal(route.properties)) return undefined;
        return CERCADO_FARE;
      },
      stopNameBuilder: (stops: string[] | undefined) => {
        if (!stops || stops.length === 0) {
          stops = ['Innominada'];
        }
        return stops.join(' y ');
      },
      feed: {
        publisherName: 'Trufi Association',
        publisherUrl: 'https://www.trufi-association.org/',
        lang: 'es',
        version: '1.0',
        contactEmail: 'info@trufi-association.org',
        contactUrl: 'https://www.trufi-association.org/',
        startDate: '20240101',
        endDate: '20261231',
        id: 'cochabamba',
      },
    },
  });

  console.log(`Done. Output in ${path.join(__dirname, 'out')}`);
}

main().catch((err) => {
  console.error('GTFS generation failed:', err);
  process.exit(1);
});
