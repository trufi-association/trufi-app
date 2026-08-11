const searchDataExport = require('osm-search-data-export');
const { pbfInput, jsonCompactOutput } = searchDataExport;

// Reads the sibling tool's PBF and writes the search index the app bundles
// as assets/search/search.json (streets + junctions). Compact format:
// rows are positional arrays described by the _fields header — it's what
// OfflineSearchDataService parses. POIs are excluded on purpose: the
// service never reads them (places are Photon's job) and they were 55%
// of the file (trufi-app#45).
// OfflineSearchDataService only reads `streets` and `streetJunctions`
// (places are Photon's job by design) — the pois payload was 55% of the
// file for zero consumers (trufi-app#45). The empty whitelist drops
// tag-based POIs; the output wrapper strips the named non-street ways
// that land in `pois` regardless.
const writeCompact = jsonCompactOutput({ outPath: './out/search.json' });
searchDataExport(
  pbfInput({ inPath: '../pbf-bolivia-cochabamba/out/cochabamba.osm.pbf' }),
  (data) => {
    data.pois = [];
    writeCompact(data);
  },
  { poiTypeTags: [] },
);
