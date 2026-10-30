# pbf-bolivia-cochabamba

Generates a Cochabamba `.osm.pbf` extract using [`trufi-association/trufi-pbf-extractor`](https://github.com/trufi-association/trufi-pbf-extractor). The extractor's image is built on the fly from the upstream repo, pinned to a commit in [`docker-compose.yml`](docker-compose.yml) — no fork, no submodule.

## Run

```bash
docker compose up --build
```

Output: `./out/cochabamba.osm.pbf` (committed to the repo; everything else under `out/` is gitignored). Takes a couple of minutes — most of the time is the ~160 MB Bolivia download from Geofabrik.

## What it does

```bash
wget https://download.geofabrik.de/south-america/bolivia-latest.osm.pbf
osmium extract --bbox="$BBOX" --set-bounds bolivia-latest.osm.pbf --output cochabamba.osm.pbf
```

Values come from [`.env`](.env).

## Bounding box

The bbox in `.env` covers the **metropolitan area** of Cochabamba:

```
west=-66.440262, south=-17.709721, east=-65.577835, north=-17.261759
```

This is intentionally larger than the city-center example shown in trufi-pbf-extractor's README — the metro area is what we need for transit routing.

## Pin

`docker-compose.yml` pins the upstream image to commit `b9e04c32ced29f0925d956dd12ad3271a4bce392`. The repo has no tags; bump the SHA when you want a newer build. Buildkit requires the full 40-character SHA.

## After a refresh

The committed PBF is the single source of three snapshots the app bundles.
Regenerate all of them from the new file and commit them together with it:

| Tool | Output the app ships |
|---|---|
| [`../gtfs-bolivia-cochabamba`](../gtfs-bolivia-cochabamba) | `assets/routing/cochabamba.gtfs.zip` (and the tracked `out/gtfs/*.txt`) |
| [`../pois-bolivia-cochabamba`](../pois-bolivia-cochabamba) | `assets/pois/*.geojson` + `metadata.json` |
| [`../search-bolivia-cochabamba`](../search-bolivia-cochabamba) | `assets/search/search.json` |

A snapshot left behind shows up as data that exists for one feature and not
for another (#75: the search index stayed one PBF behind the GTFS, so 101
streets could be routed along but not found by the offline search).

## Inspect the PBF

```bash
docker run --rm -v "$PWD/out:/d" stefda/osmium-tool fileinfo /d/cochabamba.osm.pbf
```
