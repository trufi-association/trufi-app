/**
 * Cochabamba offline search data generator.
 *
 * Uses osm-search-data-export as a library — no fork, no submodule; the
 * pinned version lives in package.json. Output goes to ./out/.
 *
 * The resulting search.json is what feeds street search and, above all,
 * the street-junction flow ("Av. X y Calle Y"): the app looks up a
 * street and then offers its intersections, which is how people in
 * Cochabamba actually describe where they are (trufi-core#745).
 *
 * Reads the PBF produced by the sibling tool pbf-bolivia-cochabamba.
 */

const path = require('path');
const fs = require('fs');
const searchDataExport = require('osm-search-data-export');
const { pbfInput, jsonCompactOutput } = searchDataExport;

const PBF_FILE = path.join(
  __dirname, '..', 'pbf-bolivia-cochabamba', 'out', 'cochabamba.osm.pbf',
);
const OUT_FILE = path.join(__dirname, 'out', 'search.json');

if (!fs.existsSync(PBF_FILE)) {
  console.error(
    `Missing ${PBF_FILE}\nRun the pbf-bolivia-cochabamba tool first.`,
  );
  process.exit(1);
}

// json-compact is the shape Trufi-Core apps expect for search.json
// (see the exporter's README): arrays instead of objects, with the field
// order declared in _fields.
// The exporter is callback-driven (input streams items, output writes on
// complete) — it returns nothing, so the summary runs from the output's
// own completion rather than from a promise.
searchDataExport(
  pbfInput({ inPath: PBF_FILE }),
  (result) => {
    jsonCompactOutput({ outPath: OUT_FILE })(result);
    summarise();
  },
);

function summarise() {
  const data = JSON.parse(fs.readFileSync(OUT_FILE, 'utf8'));
  const streets = Object.keys(data.streets || {}).length;
  const junctions = Object.values(data.streetJunctions || {})
    .reduce((n, list) => n + list.length, 0);
  const size = (fs.statSync(OUT_FILE).size / 1024 / 1024).toFixed(1);
  console.log(
    `search.json: ${(data.pois || []).length} POIs, ${streets} streets, ` +
    `${junctions} junctions — ${size} MB`,
  );
  console.log('Copy it to assets/search/ and bump the version to ship it.');
}
