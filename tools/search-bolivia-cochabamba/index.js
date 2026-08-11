const searchDataExport = require('osm-search-data-export');
const { pbfInput, jsonCompactOutput } = searchDataExport;

// Reads the sibling tool's PBF and writes the search index the app bundles
// as assets/search/search.json (streets + junctions). Compact format:
// rows are positional arrays described by the _fields header — it's what
// OfflineSearchDataService parses.
//
// POIs are excluded on purpose: the service never reads them (places are
// Photon's job by design) and they were 51% of the file (trufi-app#45).
// Two mechanisms are needed: the empty poiTypeTags whitelist drops the
// non-street WAYS with POI tags, while named NODES land in `pois`
// unconditionally — the output wrapper below strips those.
const writeCompact = jsonCompactOutput({ outPath: './out/search.json' });
searchDataExport(
  pbfInput({ inPath: '../pbf-bolivia-cochabamba/out/cochabamba.osm.pbf' }),
  (data) => {
    data.pois = [];
    writeCompact(data);
  },
  { poiTypeTags: [] },
);
