# mbtiles-bolivia-cochabamba

Generates the Cochabamba `.mbtiles` (vector tiles for offline maps) using `openmaptiles/planetiler-openmaptiles`. Compose follows [`trufi-association/trufi-mbtiles-generator`](https://github.com/trufi-association/trufi-mbtiles-generator) with three differences: the PBF is read from the sibling tool (its own read-only mount, output in `./out`), the image is pinned to `3.16` where upstream runs `latest`, and the bbox is passed as `--bounds` (see [Bounds](#bounds)).

## Run

```bash
docker compose up
cp out/cochabamba.mbtiles ../../assets/offline/cochabamba.mbtiles   # see Propagate
docker compose down                                                  # always: see below
```

Output: `./out/cochabamba.mbtiles` (not committed: `out/*` is ignored — the copy
under `assets/offline/` is the one the app ships and the only one tracked).

Every run that succeeds first downloads three sources, 1.45 GB in all (water
polygons 933 MB, Natural Earth 433 MB, lake centerlines 81 MB), and then builds
the tiles in about half a minute. Nothing is reused from one run to the next.

**Do not run `docker compose up` twice in a row.** The second run on the same
container deletes `out/cochabamba.mbtiles` and fails with
`/tmp/sources/lake_centerline.shp.zip does not exist`: `--download_dir=/tmp/sources`
sits inside `--tmpdir=/tmp`, which planetiler wipes at start, after it has found
the zips of the previous run and skipped the download. Until that is fixed, copy
the output (next section) and end every run with `docker compose down`, which
also frees the 1.5 GB the stopped container keeps; after a run that failed this
way, `docker compose up` once more downloads again and works.

## Propagate

```bash
cp out/cochabamba.mbtiles ../../assets/offline/cochabamba.mbtiles   # offline map tiles in the APK
```

The asset is the bundled copy and the one under version control; the file in
`out/` is only the tool's scratch output, so a refresh without this step never
reaches the repo (or the APK).

## Input

Reads `../pbf-bolivia-cochabamba/out/cochabamba.osm.pbf` (mounted read-only). Generate it first with the sibling tool.

## Bounds

`BBOX` in [`.env`](.env) is passed to planetiler as `--bounds`; keep it equal to
the `BBOX` of [`../pbf-bolivia-cochabamba/.env`](../pbf-bolivia-cochabamba/.env).
Without `--bounds` planetiler takes the area from the PBF header and, when the
header has none, from the envelope of every node in the file. The extract keeps
whole the ways that cross the bbox, so that envelope is
`-67.92,-19.00,-64.77,-16.55` (3.2° × 2.5° around a 0.86° × 0.45° bbox). The
PBF of #53 is the first one without header bounds (it went through
`osmium apply-changes`, which does not write them), and #77 ran into it: built
without `--bounds`, the tileset had 6 067 tiles instead of 4 708, the extra
ones holding only fragments of those ways, and the `bounds` and `center` of
its metadata no longer described the city.

## Provenance

The file does not say which PBF it was built from:
`planetiler:osm:osmosisreplicationtime` is `1970-01-01T00:00:00Z` (the extract
has no replication header), and `planetiler:buildtime` and
`planetiler:githash` identify the planetiler build inside the image, not the
run. The record is the commit that updates `assets/offline/cochabamba.mbtiles`:
name the PBF (commit and md5) in its message.

A run has three inputs: the PBF, the image, and the three sources it downloads,
which nothing pins. Natural Earth and the lake centerlines are files of
November 2022; the water polygons (oceans and seas) are regenerated from OSM,
and the file served on 2026-11-17 was of that day. What was measured in #77
that day: runs repeated over the same PBF gave the same bytes, and the tileset
of #21, built in May, came out byte for byte from the PBF of #18 with the
downloads of November. So a fresh run that gives the md5 of the asset confirms
the PBF it came from. A different md5 does not by itself mean a different PBF:
a source that changed can change the bytes too. Between May and November 2026
that did not happen for this bbox.

## Cochabamba tweaks

City-specific values live in [`.env`](.env): `CITY_NAME`, `BBOX`, `MAX_ZOOM` (14 recommended for transit), `MIN_ZOOM`, `JAVA_MEMORY`, `THREADS`.

## Pin

The image tag is `openmaptiles/planetiler-openmaptiles:3.16` — the latest stable (non-SNAPSHOT) tag. Bump it when a newer stable tag ships.

A tag can be re-pushed, so the image is an input that the tag alone does not pin. The committed tileset was built (and rebuilt byte for byte on 2026-11-18) with the image of digest `sha256:9c95d3fec85ac28380f25b85e6c887b88c1b1478809e7410cc74b022be28e099`; `docker image inspect --format '{{index .RepoDigests 0}}' openmaptiles/planetiler-openmaptiles:3.16` shows the one you have.
