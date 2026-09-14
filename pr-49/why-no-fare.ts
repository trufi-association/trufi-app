// Which isIntermunicipal() signal fires for every route relation of the PBF
// that carries no charge=*, plus the relations with charge=* / duration=*.
// Run from the tool folder (needs its node_modules):
//   npx ts-node why-no-fare.ts <path/to/cochabamba.osm.pbf>
import { OSMPBFReader } from 'trufi-gtfs-builder';
const OTHER = ['Sacaba','Quillacollo','Vinto','Sipe Sipe','Tiquipaya','Colcapirhua','Itapaya','Punata','Santiváñez','Colomi'];
function why(t: Record<string, any>): string[] {
  const out: string[] = [];
  const network = String(t.network || '');
  if (network.split(';').some((n) => n.startsWith('BO:C:') && n !== 'BO:C:Cochabamba')) out.push(`network=${network}`);
  const ref = parseInt(String(t.ref || ''), 10);
  if (ref >= 200 && ref <= 299) out.push(`ref=${t.ref} (2xx)`);
  const op = String(t.operator || '');
  const m = OTHER.filter((x) => op.includes(x));
  if (m.length) out.push(`operator="${op}" (${m.join(',')})`);
  return out;
}
async function main() {
  const reader = new OSMPBFReader(process.argv[2]);
  const routes = await reader.getRoutes(['bus', 'share_taxi', 'minibus', 'aerialway', 'light_rail']);
  const rels = Object.values(routes) as any[];
  console.log('route relations:', rels.length);
  const rows: string[] = [];
  for (const r of rels) {
    const w = why(r.tags);
    if (w.length && !r.tags.charge) rows.push(`${String(r.tags.ref || '').padStart(10)} rel ${String(r.id).padEnd(9)} ${String(r.tags.name || '').slice(0, 50).padEnd(50)} -> ${w.join(' | ')}`);
  }
  rows.sort();
  console.log(`\n-- ${rows.length} relations without charge=* flagged by isIntermunicipal():`);
  console.log(rows.join('\n'));
  console.log('\n-- relations with charge=*');
  for (const r of rels) if (r.tags.charge) console.log(`${String(r.tags.ref || '').padStart(10)} rel ${r.id} charge=${r.tags.charge} duration=${r.tags.duration || '-'} name=${r.tags.name}`);
  console.log('\n-- relations with duration=*');
  for (const r of rels) if (r.tags.duration) console.log(`${String(r.tags.ref || '').padStart(10)} rel ${r.id} route=${r.tags.route} duration=${r.tags.duration} name=${r.tags.name}`);
}
main().catch((e) => { console.error(e); process.exit(1); });
