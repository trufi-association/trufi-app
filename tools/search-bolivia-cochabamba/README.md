# search-bolivia-cochabamba

Generates Cochabamba's **offline search data** — POIs, streets and, the part
that matters most here, **street junctions** — using
[`trufi-association/osm-search-data-export`](https://github.com/trufi-association/osm-search-data-export)
as a Node library (no fork, no submodule; the pinned version lives in
[`package.json`](package.json)).

## Why

People in Cochabamba give directions as intersections ("Ayacucho y Heroínas"),
not as street numbers. The old Trufi Core searched a street and then offered
its junctions; that flow lost its data source in the v5 migration and is
tracked in [trufi-core#745](https://github.com/trufi-association/trufi-core/issues/745).
This tool brings the data back.

## Run

```bash
npm install
npm start
```

Input: `../pbf-bolivia-cochabamba/out/cochabamba.osm.pbf` (run that tool first).
Output: `./out/search.json` in the exporter's `json-compact` shape, which is
what Trufi-Core based apps expect.

## Shipping it

```bash
cp out/search.json ../../assets/search/search.json
```

…and bump the app version. Same trap as the GTFS refresh: **generating is not
shipping** — if the copy step is skipped, the app keeps the old data.
