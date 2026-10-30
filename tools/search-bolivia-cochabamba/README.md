# search-bolivia-cochabamba

Generates the Cochabamba offline search index using
[`trufi-association/osm-search-data-export`](https://github.com/trufi-association/osm-search-data-export)
as a Node library. The app bundles the output as `assets/search/search.json`,
where `OfflineSearchDataService` (trufi-core ≥ v5.21) reads it to answer
street and street-corner queries ("Ayacucho y Heroínas") offline —
something no online geocoder answers (trufi-core#745).

## Run

```bash
npm install          # Node >= 22 (better-sqlite3 13 ships prebuilt binaries)
npm start
cp out/search.json ../../assets/search/search.json
```

The exporter is pinned to a GitHub tag (`github:trufi-association/osm-search-data-export#v1.2.0`);
bump the tag in `package.json` to pick up a new version. Since 1.2.0 every street carries its
municipality (`region`, from the OSM `admin_level=8` boundaries) and a name that exists in several
municipalities is one entry per municipality, each with its own centre and corners — trufi-core
≥ v5.27.0 shows the municipality under the street and corner rows (trufi-core#972).

Output: `./out/search.json` (not committed: `out/` is ignored — the copy
under `assets/search/` is the one the app ships and the only one tracked,
so a refresh is a one-file diff). Contains `streets` and
`streetJunctions` keyed for prefix search — `pois` is stripped on
purpose (the app's search service never reads it; places come from
Photon); only the empty `pois` key and its `_fields` header remain,
which `OfflineSearchDataService` ignores.

## Input

Reads `../pbf-bolivia-cochabamba/out/cochabamba.osm.pbf` (committed; generated
by the sibling tool). If it isn't there, run that tool first.

## After a PBF refresh

The app bundles four snapshots derived from this PBF, and they have to come
from the same file: the GTFS feed (`../gtfs-bolivia-cochabamba` →
`assets/routing/`), the POI layers (`../pois-bolivia-cochabamba` →
`assets/pois/`), the offline map tiles (`../mbtiles-bolivia-cochabamba` →
`assets/offline/cochabamba.mbtiles`, #77) and this index (→ `assets/search/`).
Whenever `../pbf-bolivia-cochabamba` is re-run, regenerate the four together
and commit them in the same change. A refresh that skips this tool leaves
the new streets routable but unsearchable: #53 refreshed the PBF and the
GTFS only, and 101 streets with their corners were missing from the search
until #75 regenerated the index.
