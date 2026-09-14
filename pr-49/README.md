# Evidencia — trufi-app PR de velocidades (tools/gtfs-bolivia-cochabamba, builder v2.13.4 → v2.16.0)

Mismo PBF en las tres corridas: `tools/pbf-bolivia-cochabamba/out/cochabamba.osm.pbf` versionado (05/08/2026, 17 459 774 bytes, **no se refrescó**). Node 26.0.0, npm 11.12.1. El clon `projects/trufi-app/trufi-app` quedó en `main` sin tocar; todo se hizo en el worktree `wt-app-speeds` (rama `chore/gtfs-tool-2.16.0-speeds`) y en copias scratch de la herramienta.

| corrida | builder | config | resultado |
|---|---|---|---|
| `before/` | v2.13.4 (`npm ci` con el lock de `main`) | `index.ts` de `main` (`vehicleSpeed: () => 40`, sin tarifas) | los **11 archivos GTFS byte-idénticos al `out/gtfs` versionado** (`before/cmp-vs-committed.txt`) → el feed de `main` es reproducible y sirve de «antes» |
| `control/` | v2.16.0 | la misma de `main` (solo cambia el pin, `control/package.json`) | vs `before/`: 9 archivos idénticos; `stop_times` difiere **solo en los 4 viajes de Mi Tren Verde/Roja** (toman su `duration=*`; Amarilla a 36 min por el guard de 3 km/h; Teleférico rechazado, 2 warnings) y las tarifas pasan de 657 filas a 8 (solo las 6 relaciones con `charge=*`: sin config de tarifas no hay Bs 3) — `diff-trips-before-control.txt`, `control/run.log` |
| `run-after.log` | v2.16.0 | la de la rama (velocidades por tipo + `tripDuration` + tarifas) | 4 warnings exactos: Teleférico ×2 (`tripDuration=7200s … implies 0.4 km/h`, guard de la librería) + Amarilla ×2 (`duration="00:36" … 9.3 km/h, below the 15 km/h floor`, resolver de la herramienta) |

## Comparación de archivos (`cmp.txt`)

before vs after: `agency`, `calendar`, `feed_info`, `frequencies`, `routes`, `shapes`, `stops`, `trips` **idénticos**; `stop_times.txt` difiere (104 592 filas + cabecera en ambos; md5 `4626aef3…` → `1761b7b3…`); `fare_attributes.txt` 657 → 37 filas; `fare_rules.txt` 657 → 99.

## Duraciones (`analyze-before-after.txt`; distancia = suma de tramos rectos entre paradas)

| | before (40 km/h) | after |
|---|---|---|
| 657 viajes: min / mediana / media / máx | 1,2 / 30,9 / 31,2 / 74,4 min | 4,1 / 60,2 / 60,8 / 143,4 min |
| 649 viajes de bus (route_type 3) | 3,4 / **31,1** / 31,3 / 74,4 min · 38,3 km/h | 6,7 / **60,5** / 61,2 / 143,4 min · 19,6 km/h |
| 6 viajes light_rail (route_type 0) | 8,4 / 12,7 / 20,7 / 40,9 min · 39,8 km/h | 10,5 / 20,0 / 35,2 / 75,0 min · 26,2 km/h |
| 2 viajes aerialway (route_type 6) | 1,2 min · 38,8 km/h | 4,1 min · 10,9 km/h |
| viajes no monotónicos | 0 | 0 |
| viajes cuyos `stop_times` cambian | — | 657 de 657 |

Histograma bus (bins de 15 min) — antes `0-15: 29 · 15-30: 273 · 30-45: 298 · 45-60: 45 · 60-75: 4`; después `0-15: 11 · 15-30: 19 · 30-45: 86 · 45-60: 202 · 60-75: 188 · 75-90: 104 · 90-105: 25 · 105-120: 12 · 135-150: 2`.

| trip | línea | km | paradas | antes (min · km/h) | después (min · km/h) |
|---|---|---|---|---|---|
| 5457000 / 5457001 | **micro H** | 19,16 / 18,47 | 146 / 160 | 29,9 / 29,0 · 38,5 | **58,7 / 56,6 · 19,6** |
| 14576926 / 9074378 | Mi Tren **V** (OSM `01:15`) | 27,1 | 26 / 25 | 40,9 · 39,8 | **75,0 · 21,7** |
| 14576927 / 9083839 | Mi Tren **R** (OSM `00:20`) | 8,4 | 11 | 12,7 · 39,7 | **20,0 · 25,2** |
| 11678428 / 19604339 | Mi Tren **A** (OSM `00:36` rechazado) | 5,58 | 6 | 8,4 · 39,9 | **10,5 · 31,9** (fallback 32 km/h) |
| 6925236 / 6925237 | Teleférico | 0,76 / 0,75 | 4 | 1,2 · 38,9 | **4,1 · 11,0** |
| 20141710 | Trufi Santiváñez (OSM `00:45`) | — | — | 42,1 | **45,0** |
| 20967965 | Bus Colomi (OSM `01:00`, 47,7 km) | 47,7 | — | 74,4 | **60,0** |
| 16648043 / 21116245 | Trufi Punata / E. Punata (sin `duration`) | 46,2 / 46,8 | — | 72,3 / 73,3 | 141,6 / 143,4 |
| 9124161 · 9184012 · 9715360 · 4204592 · 10786928 · 4443362 · 11104191 · 5457263 | 1 · 10 · 130 · 270 · 3 · E · L · Q | | | 26,6 · 28,9 · 34,8 · 16,2 · 25,2 · 31,2 · 34,0 · 34,6 | 51,7 · 56,6 · 68,2 · 31,8 · 49,4 · 61,1 · 66,7 · 67,7 |

Las 15 más largas y todos los viajes de las rutas sin tarifa, con su duración: `intercity-after.txt`.

## Tarifas (`fares-before-after.txt`, `why-no-fare.txt`)

| | before | after |
|---|---|---|
| `fare_attributes` / `fare_rules` | 657 / 657 (una por viaje) | 37 / 99 (una por `route_id`) |
| moneda | `USD` (todas) | `BOB` (todas) |
| precios | 645 × `0`, 4 × 7, 4 × 3, 2 × 2,5, 1 × 6, 1 × 15 | 94 rutas × 3 BOB; Teleférico y Verde 7; Roja 2,50; Santiváñez 6; Colomi 15 |
| columna `transfers` | ausente | `0` en las 37 |
| rutas sin fila | 0 | **45** |

Las 45 rutas sin tarifa y la señal que las marca (`why-no-fare.ts` recorre las 657 relaciones del PBF): 326 relaciones por `ref` 2xx, 219 por `operator` con municipio (Sacaba, Tiquipaya, Vinto, Sipe Sipe…), 30 por `network` con otro municipio (incluye **micro H** `BO:C:Cochabamba;BO:C:Sacaba`, **micro S** `…;BO:C:Colcapirhua`, micro Q solo en 2 de 4 variantes → warning `fare: route Q … using the fare of the others`). Diferencia con las 43 del example en #15 (PBF de mayo): −Santiváñez (ahora trae `charge=6 BOB/persona`), +micro S (`network` nuevo), +222 (Sindicato de taxi trufis trufi buses Sacaba) y +E. Punata (Sindicato Expreso Punata), rutas nuevas en este PBF. Relaciones con `charge=*` en el PBF: Teleférico ×2, Verde ×2, Roja ×2, Amarilla ×2, Trufi 130 ×2, Santiváñez, Colomi (12). Con `duration=*`: las 8 de Mi Tren/Teleférico + Santiváñez `00:45` + Colomi `01:00`; **ninguna `route=bus`**.

## gtfs-validator (`validator/`)

MobilityData 8.0.2-SNAPSHOT, imagen `ghcr.io/mobilitydata/gtfs-validator:latest`, `-c bo`, sobre `assets/routing/cochabamba.gtfs.zip` de `main` (before) y el zip final de la rama (after; md5 `5fbd279a…` = el commiteado). **Mismos 7 notices, 0 errores, ningún `fast_travel_*`** en ambos: `mixed_case_recommended_field` ×2, `route_long_name_contains_short_name` ×2, `stops_match_shape_out_of_order` ×2 (WARNING); `service_extends_far_in_the_future` ×2, `service_window_outside_feed_period` ×2, `trip_headsign_matches_intermediate_stop` ×211, `unknown_column` ×1 (INFO). Conteos: 657 shapes, 23 679 stops, 144 routes, 657 trips, 47 agencies.

## Harness del planner de la app (`harness/`)

`common_dump.dart` de core PR #992/#999 (copiado a `packages/trufi_core_planner/tool/` de un worktree desechable de trufi-core en `origin/main` `f2057f91`, Flutter 3.44.1 vía fvm, `flutter pub get` + `melos bootstrap`), 340 pares (40 con semilla 42 + 300 con semilla 7, sobre las mismas 23 679 paradas), `maxWalk` 800 m, sobre el zip de `main` y el zip final de la rama:

- `strip-compare.txt`: **340 consultas / 1 241 itinerarios, BYTE-IDENTICAL=YES** (sha256 `012aa7b2…` ambos, quitando solo los campos de tiempo).
- `compare.txt`: 340/340 idénticas, 0 keys perdidas, 0 peores, 0 nuevas; 2 608 421 conexiones en ambos; 18 consultas sin ruta en ambos.

Confirma lo que dice el código: `GtfsRoutingService._buildSegmentForPattern` estima el tiempo a bordo como `transit / 5` m/s (18 km/h, `gtfs_routing_service.dart:963-967`) y no lee `stop_times` ni `fare_*` → **el APK no cambia sus tiempos** hasta trufi-core#997; el cambio visible está en OTP 2.8.1 tras reconstruir el grafo.

## Archivos

- `before/`: `run.log`, `npm-ci.log`, `cmp-vs-committed.txt`. `control/`: `run.log`, `package.json`. `run-after.log`: corrida final de la rama.
- `cmp.sh` + `cmp.txt`; `analyze.py` + `analyze-before-after.txt`; `diff-trips.py` + `diff-trips-before-control.txt`; `fares.py` + `fares-before-after.txt`; `intercity.py` + `intercity-after.txt`; `why-no-fare.ts` + `why-no-fare.txt` (se ejecuta desde la carpeta de la herramienta: `npx ts-node why-no-fare.ts ../pbf-bolivia-cochabamba/out/cochabamba.osm.pbf`).
- `validator/`: `report-{before,after}.{json,html}`, `validator-{before,after}.log`.
- `harness/`: `common_dump.dart`, `compare.py`, `strip_timing_compare.py`, `before.json`, `after.json`, `compare.txt`, `strip-compare.txt`, `{before,after}-run.log`.
- `description.md`: cuerpo del PR tal como se publicó.
