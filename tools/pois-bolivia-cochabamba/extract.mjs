/**
 * Cochabamba POI extractor.
 *
 * Runs trufi-server-poi_extractor as a library over the Cochabamba PBF
 * (the sibling pbf-bolivia-cochabamba tool's output) with the categories in
 * ./categories.json, clipped to the bbox the app has always shipped. Output
 * goes to ./out/; the resulting files are what gets copied to assets/pois/
 * (the map's POI layers, read by trufi_core_poi_layers).
 *
 * Why a script and not `poi-extractor -c categories.json`: the CLI's custom
 * categories loader calls `require('fs')` from an ES module, so the file
 * silently fails to load and the defaults are used instead (upstream bug in
 * loadCategories, src/categories.ts). The CLI also cannot clip a PBF to a
 * bbox; the library call can.
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { configureIcons, extractFromPBF } from 'trufi-server-poi_extractor';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const PBF_FILE = path.join(__dirname, '..', 'pbf-bolivia-cochabamba', 'out', 'cochabamba.osm.pbf');
const OUT_DIR = path.join(__dirname, 'out');
const CATEGORIES_FILE = path.join(__dirname, 'categories.json');

// The city bbox the POI files have carried since they were first generated
// (metadata.json `bbox`, south/west/north/east). The PBF covers the whole
// metropolitan area (see ../pbf-bolivia-cochabamba/.env); the extractor
// drops the nodes outside this box, and with them the ways and relations
// that are not at least 90 % inside it.
const BBOX = { south: -17.45, west: -66.25, north: -17.3, east: -66.1 };

if (!fs.existsSync(PBF_FILE)) {
  throw new Error(
    `PBF file not found: ${PBF_FILE}\n` +
      `Generate it with the sibling tool: cd ../pbf-bolivia-cochabamba && docker compose up --build`,
  );
}

const categories = JSON.parse(fs.readFileSync(CATEGORIES_FILE, 'utf-8'));

// The npm package does not ship the extractor's icons/ folder (its `files`
// list leaves it out), so every maki SVG this config references lives in
// ./icons/maki — the upstream set plus the ones this config adds.
configureIcons({ iconsDir: path.join(__dirname, 'icons') });

fs.rmSync(OUT_DIR, { recursive: true, force: true });

console.log('Extracting POIs for Cochabamba...');
const { metadata, poisByCategory } = await extractFromPBF({
  inputFile: PBF_FILE,
  outputDir: OUT_DIR,
  categories,
  bbox: BBOX,
  verbose: true,
});

// The extractor pretty-prints the GeoJSON files; rewrite them minified so the
// app parses and ships less (whitespace was 47 % of the committed files) and
// the diff of a regeneration is about data, not indentation. metadata.json
// stays as the extractor wrote it (pretty, small).
for (const [name, pois] of Object.entries(poisByCategory)) {
  fs.writeFileSync(
    path.join(OUT_DIR, `${name}.geojson`),
    JSON.stringify({ type: 'FeatureCollection', features: pois }),
  );
}

// ── Report ─────────────────────────────────────────────────────────────
console.log('');
console.log('POIs per category (named / total):');
for (const category of metadata.categories) {
  const pois = poisByCategory[category.name];
  const named = pois.filter((p) => p.properties.name).length;
  console.log(`  ${category.name.padEnd(12)} ${String(named).padStart(5)} / ${String(pois.length).padStart(5)}`);
  for (const sub of category.subcategories ?? []) {
    const subPois = pois.filter((p) => p.properties.subcategory === sub.name);
    const subNamed = subPois.filter((p) => p.properties.name).length;
    console.log(`    ${sub.name.padEnd(16)} ${String(subNamed).padStart(5)} / ${String(subPois.length).padStart(5)}`);
  }
}
console.log(`  total        ${String(metadata.total).padStart(5)}`);
console.log('');
console.log(`Done. Output in ${OUT_DIR}`);
