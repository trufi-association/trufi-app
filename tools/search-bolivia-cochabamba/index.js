const searchDataExport = require('osm-search-data-export');
const { pbfInput, jsonCompactOutput } = searchDataExport;

// Reads the sibling tool's PBF and writes the search index the app bundles
// as assets/search/search.json (streets + junctions + POIs). Compact
// format: rows are positional arrays described by the _fields header —
// it's what OfflineSearchDataService parses.
searchDataExport(
  pbfInput({ inPath: '../pbf-bolivia-cochabamba/out/cochabamba.osm.pbf' }),
  jsonCompactOutput({ outPath: './out/search.json' }),
);
