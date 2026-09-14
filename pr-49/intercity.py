"""Longest trips of the AFTER feed and the routes the fare rule left without a
fare (the intermunicipal syndicates), with their end-to-end durations.
Usage: python3 intercity.py <after/gtfs>"""
import csv, math, collections, sys
d = sys.argv[1]
def hav(a, b):
    R = 6371.0088
    la1, lo1 = map(math.radians, a); la2, lo2 = map(math.radians, b)
    x = math.sin((la2-la1)/2)**2 + math.cos(la1)*math.cos(la2)*math.sin((lo2-lo1)/2)**2
    return 2*R*math.asin(math.sqrt(x))
def secs(t):
    h, m, s = map(int, t.split(':')); return h*3600+m*60+s
stops = {r['stop_id']: (float(r['stop_lat']), float(r['stop_lon'])) for r in csv.DictReader(open(f'{d}/stops.txt'))}
trips = {r['trip_id']: r for r in csv.DictReader(open(f'{d}/trips.txt'))}
routes = {r['route_id']: r for r in csv.DictReader(open(f'{d}/routes.txt'))}
agencies = {a['agency_id']: a['agency_name'] for a in csv.DictReader(open(f'{d}/agency.txt'))}
fare_routes = {r['route_id'] for r in csv.DictReader(open(f'{d}/fare_rules.txt'))}
st = collections.defaultdict(list)
for r in csv.DictReader(open(f'{d}/stop_times.txt')):
    st[r['trip_id']].append((int(r['stop_sequence']), r['stop_id'], r['arrival_time']))
rows = []
for tid, v in st.items():
    v.sort()
    km = sum(hav(stops[v[i-1][1]], stops[v[i][1]]) for i in range(1, len(v)))
    mins = secs(v[-1][2]) / 60
    t = trips[tid]; r = routes[t['route_id']]
    rows.append((km, mins, tid, r['route_short_name'], r['route_long_name'], t.get('trip_headsign', ''), agencies.get(r['agency_id'], ''), t['route_id'] in fare_routes))
rows.sort(reverse=True)
print(f"{'km':>6} {'min':>6} {'trip':>9} {'ref':>5} route_long_name / headsign / agency / fare")
print('-- 15 longest trips (end-to-end, straight segments between stops)')
for km, mins, tid, ref, ln, hs, ag, fare in rows[:15]:
    print(f'{km:6.1f} {mins:6.1f} {tid:>9} {ref:>5} {ln[:34]:<34} → {hs[:22]:<22} {ag[:38]:<38} {"Bs3/OSM" if fare else "no fare"}')
print()
print('-- trips of routes WITHOUT a fare row (intermunicipal rule), longest first')
for km, mins, tid, ref, ln, hs, ag, fare in rows:
    if not fare:
        print(f'{km:6.1f} {mins:6.1f} {tid:>9} {ref:>5} {ln[:34]:<34} → {hs[:22]:<22} {ag[:38]}')
