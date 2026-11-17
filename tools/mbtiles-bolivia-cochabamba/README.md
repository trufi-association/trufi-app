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
name the PBF (commit and md5) in its message. The output is reproducible: the
same PBF and the same image give the same bytes (in #77 the tileset of #21 came
out byte for byte from the PBF of #18, six months later), so the md5 of the
asset can be checked against a fresh run.

## Cochabamba tweaks

City-specific values live in [`.env`](.env): `CITY_NAME`, `BBOX`, `MAX_ZOOM` (14 recommended for transit), `MIN_ZOOM`, `JAVA_MEMORY`, `THREADS`.

## Pin

The image tag is `openmaptiles/planetiler-openmaptiles:3.16` — the latest stable (non-SNAPSHOT) tag. Bump it when a newer stable tag ships.
