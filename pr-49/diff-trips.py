"""List the trips whose stop_times differ between two generated GTFS folders.
Usage: python3 diff-trips.py <main/out/gtfs> <rework/out/gtfs>"""
import csv, collections, math, sys
def secs(t):
    h, m, s = map(int, t.split(':')); return h * 3600 + m * 60 + s
def hav(a, b):
    R = 6371.0088
    la1, lo1 = map(math.radians, a); la2, lo2 = map(math.radians, b)
    d = math.sin((la2 - la1) / 2) ** 2 + math.cos(la1) * math.cos(la2) * math.sin((lo2 - lo1) / 2) ** 2
    return 2 * R * math.asin(math.sqrt(d))
def load(d):
    st = collections.defaultdict(list)
    for r in csv.DictReader(open(f'{d}/stop_times.txt')):
        st[r['trip_id']].append((int(r['stop_sequence']), r['stop_id'], r['arrival_time'], r['departure_time']))
    for v in st.values(): v.sort()
    return st
A, B = sys.argv[1], sys.argv[2]
stops = {r['stop_id']: (float(r['stop_lat']), float(r['stop_lon'])) for r in csv.DictReader(open(f'{A}/stops.txt'))}
trips = {r['trip_id']: r for r in csv.DictReader(open(f'{A}/trips.txt'))}
routes = {r['route_id']: r for r in csv.DictReader(open(f'{A}/routes.txt'))}
a = load(A); b = load(B)
print('trips:', len(a), len(b), '| rows:', sum(map(len, a.values())), sum(map(len, b.values())))
changed = sorted((t for t in a if a[t] != b[t]), key=int)
print('trips whose stop_times differ:', len(changed), changed)
print('trips byte-identical:', len(a) - len(changed))
print()
print(f"{'trip_id':>9} {'ref':>4} {'type':>4} {'stops':>5} {'km':>6} | {'A last':>9} {'B last':>9} | {'A min':>6} {'B min':>6} {'delta':>6} | {'A kmh':>6} {'B kmh':>6}")
for t in changed:
    rt = routes[trips[t]['route_id']]; rows = a[t]
    km = sum(hav(stops[rows[i - 1][1]], stops[rows[i][1]]) for i in range(1, len(rows)))
    ma = secs(a[t][-1][2]); mb = secs(b[t][-1][2])
    print(f"{t:>9} {rt['route_short_name']:>4} {rt['route_type']:>4} {len(rows):5d} {km:6.2f} | {a[t][-1][2]:>9} {b[t][-1][2]:>9} | {ma/60:6.1f} {mb/60:6.1f} {(mb-ma)/60:+6.1f} | {km/(ma/3600):6.1f} {km/(mb/3600):6.1f}")
print()
for t in changed:
    print(t, 'A', [r[2] for r in a[t]])
    print(t, 'B', [r[2] for r in b[t]])
print('\nnon-monotonic trips in B:', sum(1 for t in b for i in range(1, len(b[t])) if secs(b[t][i][2]) < secs(b[t][i - 1][2])))
