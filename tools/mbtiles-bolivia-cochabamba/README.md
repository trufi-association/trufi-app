# mbtiles-bolivia-cochabamba

Generates the Cochabamba `.mbtiles` (vector tiles for offline maps) using `openmaptiles/planetiler-openmaptiles`. Compose mirrors [`trufi-association/trufi-mbtiles-generator`](https://github.com/trufi-association/trufi-mbtiles-generator) with the input mount adjusted to read the sibling tool's PBF.

## Run

```bash
docker compose up
```

Output: `./out/cochabamba.mbtiles` (not committed: `out/*` is ignored — the copy
under `assets/offline/` is the one the app ships and the only one tracked). First run downloads Natural Earth + water polygon sources (~200 MB) which planetiler caches in the container.

## Propagate

```bash
cp out/cochabamba.mbtiles ../../assets/offline/cochabamba.mbtiles   # offline map tiles in the APK
```

The asset is the bundled copy and the one under version control; the file in
`out/` is only the tool's scratch output, so a refresh without this step never
reaches the repo (or the APK).

## Input

Reads `../pbf-bolivia-cochabamba/out/cochabamba.osm.pbf` (mounted read-only). Generate it first with the sibling tool.

## Cochabamba tweaks

City-specific values live in [`.env`](.env): `CITY_NAME`, `MAX_ZOOM` (14 recommended for transit), `MIN_ZOOM`, `JAVA_MEMORY`, `THREADS`.

## Pin

The image tag is `openmaptiles/planetiler-openmaptiles:3.16` — the latest stable (non-SNAPSHOT) tag. Bump it when a newer stable tag ships.
