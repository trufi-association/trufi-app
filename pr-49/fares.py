"""Fares before/after: rows, currencies, prices, routes without a fare row.
Usage: python3 fares.py <before/gtfs> <after/gtfs>"""
import csv, collections, sys
def load(d):
    routes = {r['route_id']: r for r in csv.DictReader(open(f'{d}/routes.txt'))}
    agencies = {a['agency_id']: a['agency_name'] for a in csv.DictReader(open(f'{d}/agency.txt'))}
    attrs = list(csv.DictReader(open(f'{d}/fare_attributes.txt')))
    rules = list(csv.DictReader(open(f'{d}/fare_rules.txt')))
    return routes, agencies, attrs, rules
def report(label, d):
    routes, agencies, attrs, rules = load(d)
    print(f'== {label}: {d}')
    print(f'routes={len(routes)} fare_attributes rows={len(attrs)} fare_rules rows={len(rules)}')
    print('columns fare_attributes:', list(attrs[0].keys()) if attrs else '-')
    pc = collections.Counter((a["price"], a["currency_type"]) for a in attrs)
    print('price/currency histogram:', sorted(pc.items(), key=lambda kv: -kv[1]))
    tc = collections.Counter(a.get('transfers', '<absent>') for a in attrs)
    print('transfers histogram:', dict(tc))
    by_route = collections.defaultdict(list)
    for r in rules: by_route[r['route_id']].append(r['fare_id'])
    multi = {k: v for k, v in by_route.items() if len(v) > 1}
    print('routes with >1 fare rule:', len(multi))
    without = sorted((rid for rid in routes if rid not in by_route), key=int)
    print(f'routes WITHOUT fare row: {len(without)}')
    for rid in without:
        r = routes[rid]
        print(f"   route {rid:>4} {r['route_short_name']:>6} {r['route_long_name'][:48]:<48} agency={agencies.get(r['agency_id'], r['agency_id'])[:40]}")
    return routes, by_route, attrs
rb, brb, ab = report('BEFORE', sys.argv[1])
print()
ra, arb, aa = report('AFTER', sys.argv[2])
print()
fa = {a['fare_id']: a for a in aa}
print('== AFTER fares by price (routes):')
pr = collections.defaultdict(list)
for rid, fids in arb.items():
    a = fa[fids[0]]; pr[(a['price'], a['currency_type'])].append(ra[rid]['route_short_name'])
for k, v in sorted(pr.items(), key=lambda kv: -len(kv[1])):
    print(f'   {k[0]} {k[1]}: {len(v)} routes: {" ".join(sorted(v))[:200]}')
