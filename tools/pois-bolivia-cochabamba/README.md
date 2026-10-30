# pois-bolivia-cochabamba

Generates the Cochabamba POI files (`assets/pois/*.geojson` + `metadata.json`)
with [`trufi-association/trufi-server-poi_extractor`](https://github.com/trufi-association/trufi-server-poi_extractor)
used as a Node library — no fork, no submodule. The pinned commit lives in
[`package.json`](package.json).

The files feed the map's POI layers: `trufi_core_poi_layers` reads
`metadata.json` (categories, subcategories, `displayName:es/en/de`, inline
SVG icons, colours, `defaultActive`) and one GeoJSON per category, listed by
the category `name`. The offline place search of this app does not read
them (`OfflineSearchDataService` indexes streets and corners from
`assets/search/search.json`; places come from Photon).

## Run

```bash
npm ci
npm start
rm ../../assets/pois/*.geojson
cp out/*.geojson out/metadata.json ../../assets/pois/
```

`npm ci` installs exactly what `package-lock.json` resolved. The extractor is a
git dependency pinned by commit, and npm skips the lock's `integrity` field for
git dependencies by design (npm/cli#4468, it prints `skipping integrity check
for git dependency`): the SHA in `resolved` is the pin. `npm install` works
too, but may rewrite the lock.

`npm start` prints the POI count per category and subcategory (named /
total); compare it with the previous `metadata.json` before committing.
`out/` is not committed (the copy under `assets/pois/` is the one the app
ships), like the sibling `search-bolivia-cochabamba`.

## Input

Reads `../pbf-bolivia-cochabamba/out/cochabamba.osm.pbf` (committed; generated
by the sibling tool) and clips it to the city bbox the POI files have always
carried, `south -17.45, west -66.25, north -17.3, east -66.1`
(`BBOX` in [`extract.mjs`](extract.mjs); the PBF covers the whole
metropolitan area). Regenerate the POIs whenever the PBF is refreshed.

The first files (2026-02) came from the Overpass API with the same bbox.
Reading the PBF instead is deterministic and offline, and it changes one
thing in what the extractor keeps: from a PBF, an **unnamed** way or
relation only becomes a POI when its outline has at least 15 nodes
(upstream's `pbf-extractor.ts`; the Overpass path keeps every closed way).
That drops the unnamed private swimming pools, pitches and gardens that
`recreation` used to carry (~900 of them) and nothing with a name.

Two more things the PBF path skips that the Overpass path emitted as
points: ways with fewer than 3 nodes, and relations that are not
multipolygons (`type=site`). In Cochabamba that is 12 named places — eight
footbridges and a zip line mapped as two-node `tourism=attraction` ways
(Puente del Amor, Puente de Piedra, Tirolesa Parque del Bicentenario, …),
the stop "Aroma", and the three `Letrero de Cochabamba / Colcapirhua /
Sacaba` signs. Reported upstream as trufi-server-poi_extractor#3; they come
back with that fix and a regeneration.

## Categories

[`categories.json`](categories.json) is the extractor's default category set
(the twelve categories the app shipped, with their en/es/de names, icons
and colours unchanged) plus:

| Category | What this config adds |
| --- | --- |
| religion | a `place_of_worship` subcategory with the category's own matchers, colour and icon. The layer sheet of `trufi_core_poi_layers` only renders toggles for subcategories, so a category without any (the extractor's default for `religion`) is a dead tile: it cannot be switched on. |
| toilets | `amenity=toilets` (trufi-app #41 / trufi-core#674), same names, maki `toilet` icon and colour as the committed metadata. |
| government | `office=diplomatic` added to the `embassy` sub-category, relabelled "Embassies & Consulates": the six consulates, which the obsolete `amenity=embassy` alone never matched (they fell into `services/company`). |
| services (new) | trufi-sanaa's category (trufi-sanaa#24): `telecom` (`office=telecommunication`, internet cafés), `industry` (`man_made=works`, `industrial=*`, `building=industrial`), `crafts` = every `craft=*`, `company` = every remaining `office=*`. Cochabamba maps ~1 350 of these (metalworking shops, companies, NGOs, security firms, factories), none of which the previous files had. `amenity=telephone` is left out (unnamed phone booths). |

Order matters: the extractor assigns a POI to the first category and
subcategory whose matcher hits, so `services` comes last and its
`office=*` / `craft=*` catch-alls only take what `government`
(`office=government`, `office=diplomatic`) and the other categories did not.

## Icons

`icons/maki/` holds the [Maki](https://github.com/mapbox/maki) icons the
categories reference (CC0 1.0): the 37 the extractor ships (copied from its
`icons/maki/`, byte-identical to the SVGs in the previous `metadata.json`),
`toilet` (the SVG the committed metadata carried since #41) and
`commercial`, `telephone`, `industry`, `hardware` for `services` (from
trufi-sanaa's tool). They have to live here because the npm package does
not include the extractor's `icons/` folder. `npm start` reports
`missing: 0` when every referenced icon was found.

## Why not `poi-extractor -c categories.json`

The CLI's `-c` option is broken in the pinned version: `loadCategories()`
calls `require('fs')` from an ES module, the `ReferenceError` is swallowed
and the run silently continues with the defaults (it prints
`Warning: Could not load custom categories … using defaults`). The CLI can
also not clip a PBF to a bbox. The script passes both through the library
API instead.

## Pin

`package.json` pins `trufi-server-poi_extractor` to commit
`c408bdaf7e1b8dd6ae45a0d4b9c0765eda336446`, the head of its `main` on
2026-10-29: the merge of upstream PR #2, which types a POI from a
classifying tag (`amenity`, `office`, `craft`, …) instead of the first tag
of the feature. The previous files, made before that fix, had
`properties.type = "Cochabamba"` (the `addr:city`) on 121 government
offices and dozens of other POIs. `v1.0.0` predates it. Bump the SHA to
upgrade.

Known limitations of the pinned version, reported as
trufi-server-poi_extractor#3: the OSM `type=*` tag is spread over the
computed `properties.type`, so every multipolygon relation comes out
`type: "multipolygon"` (168 features here) and a stray `type=heritage`
wins over `building=church`; and the named two-node ways / `type=site`
relations described under *Input* are dropped. Nothing in the app reads
`type`. The pin moves when that lands.
